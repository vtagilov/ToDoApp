//
//  MainScreen.swift
//  ToDoApp
//
//  Created by Владимир on 24.06.2024.
//

import Foundation
import SwiftUI

#Preview {
    MainScreen()
}

struct MainScreen: View {
    @StateObject private var viewModel = TodoItemsViewModel()
    @State private var selectedItem: TodoItem? = nil
    @State private var isShowingDetailScreen = false
    @State private var isComplitedHidden = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    list
                }
                VStack {
                    Spacer()
                    NewItemButton {
                        isShowingDetailScreen.toggle()
                    }
                    .padding(.bottom)
                }
            }
            .navigationTitle("Мои дела")
            .sheet(item: $selectedItem) { selectedItem in
                DetailScreen(
                    item: selectedItem,
                    saveAction: { newItem in
                        viewModel.addItem(newItem)
                    }, deleteAction: { item in
                        viewModel.removeItem(item)
                    })
            }
            .sheet(isPresented: $isShowingDetailScreen) {
                DetailScreen(
                    saveAction: { newItem in
                        viewModel.addItem(newItem)
                    }, deleteAction: { item in
                        viewModel.removeItem(item)
                    })
            }
        }
    }
    
    var list: some View {
        List {
            Section {
                let presentedItems = $isComplitedHidden.wrappedValue ? viewModel.uncompletedItems : viewModel.items
                ForEach(presentedItems) { item in
                    ItemView(
                        item: item,
                        itemAction: {
                            selectedItem = item
                        },
                        checkMarkAction: { isDone in
                            viewModel.updateItem(item, isDone)
                        })
                    .modifier(
                        SwipeModifier(
                            markItemAsDone: {
                                viewModel.updateItem(item, true)
                            },
                            removeItem: {
                                viewModel.removeItem(item)
                            },
                            selectItem: {
                                selectedItem = item
                            }
                        )
                    )
                }
                HStack {
                    Color.clear
                        .contentShape(Rectangle())
                        .frame(width: 38, height: 32)
                    Text("Новое")
                        .foregroundStyle(Color.Label.Tertiary.color)
                    Color.clear
                        .contentShape(Rectangle())
                }
                .onTapGesture {
                    selectedItem = nil
                    isShowingDetailScreen = true
                }
            } header: {
                SubtitleView(
                    itemsCounter: isComplitedHidden ? viewModel.uncompletedItems.count : viewModel.items.count,
                    isComplitedHidden: $isComplitedHidden
                )
            }
        }
        .headerProminence(.increased)
        .frame(maxWidth: .infinity, alignment: .leading)
        .scrollContentBackground(.hidden)
        .background(Color.Back.Primary.color)
    }
}

private struct SwipeModifier: ViewModifier {
    
    let markItemAsDone: () -> Void
    let removeItem: () -> Void
    let selectItem: () -> Void
    
    func body(content: Content) -> some View {
        content
            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                Button {
                    markItemAsDone()
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                }
                .tint(Color.Palette.Green.color)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button {
                    removeItem()
                } label: {
                    Image(systemName: "trash")
                }
                .tint(Color.Palette.Red.color)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button {
                    selectItem()
                } label: {
                    Image(systemName: "info.circle.fill")
                }
            }
    }
}
