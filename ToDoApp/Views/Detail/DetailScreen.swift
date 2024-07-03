//
//  DetailScreen.swift
//  ToDoApp
//
//  Created by Владимир on 24.06.2024.
//

import Foundation
import SwiftUI

struct DetailScreen: View {
    var item: TodoItem?
    var saveAction: (TodoItem) -> Void
    var deleteAction: (TodoItem) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var text = ""
    @State private var importance: TodoItem.Importance = .common
    @State private var editedDate: Date?
    @State private var deadline: Date?
    @State private var isSaveButtonAvailable = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    textEditor
                    OptionsView(importance: $importance,
                                isSaveButtonAvailable: $isSaveButtonAvailable,
                                deadline: $deadline,
                                deleteAction: {
                        if let item = item {
                            deleteAction(item)
                            dismiss()
                        }
                    })
                    Color.Back.Primary.color
                        .scaledToFill()
                }
                .background(Color.Back.Primary.color.ignoresSafeArea())
                .modifier(
                    NavBarModifier(isSaveButtonAvaliable: $isSaveButtonAvailable,
                                   cancelAction: {
                                       dismiss()
                                   },
                                   saveAction: {
                                       if let item = item {
                                           let newItem = TodoItem(
                                            id: item.id,
                                            text: text,
                                            importance: importance,
                                            isDone: item.isDone,
                                            creationDate: item.creationDate,
                                            deadline: deadline,
                                            editedDate: Date()
                                           )
                                           saveAction(newItem)
                                           dismiss()
                                       } else {
                                           let newItem = TodoItem(
                                            text: text,
                                            importance: importance,
                                            isDone: item?.isDone ?? false,
                                            creationDate: item?.creationDate ?? Date(),
                                            deadline: deadline
                                           )
                                           saveAction(newItem)
                                           dismiss()
                                       }
                                   })
                )
            }
            .onAppear {
                if let item = item {
                    self.text = item.text
                    self.importance = item.importance
                    self.deadline = item.deadline
                }
            }
        }
    }
    
    var textEditor: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .frame(minHeight: 120, maxHeight: .infinity)
                .scrollContentBackground(.hidden)
                .onChange(of: text, { _, newValue in
                    isSaveButtonAvailable = !newValue.isEmpty
                })
                .padding(.vertical, -8)
                .padding(.horizontal, -6)
            if text.isEmpty {
                Text("Что надо сделать?")
                    .foregroundColor(Color.Palette.Gray.color)
                    .allowsHitTesting(false)
            }
        }
        .primaryBackground()
        .padding(.bottom, -16)
    }
}

private struct NavBarModifier: ViewModifier {
    @Binding
    var isSaveButtonAvaliable: Bool
    var cancelAction: () -> Void
    var saveAction: () -> Void
    
    func body(content: Content) -> some View {
        content
            .navigationTitle("Дело")
            .toolbarBackground(Color.Back.Primary.color, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        cancelAction()
                    } label: {
                        Text("Отменить")
                            .font(.body)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        saveAction()
                    } label: {
                        Text("Сохранить")
                            .font(.headline)
                    }
                    .disabled(!isSaveButtonAvaliable)
                }
            })
    }
}
