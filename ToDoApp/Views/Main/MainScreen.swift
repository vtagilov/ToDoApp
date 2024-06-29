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
    @State private var items: [TodoItem] = []
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
            .sheet(item: $selectedItem, content: { selectedItem in
                if let index = items.firstIndex(where: { $0.id == selectedItem.id}) {
                    DetailScreen(item: items[index]) { newItem in
                        if let index = items.firstIndex(where: { $0.id == newItem.id }) {
                            items[index] = newItem
                        } else {
                            items.append(newItem)
                        }
                    } deleteAction: { item in
                        items.removeAll(where: { $0.id == item.id })
                    }
                }
            })
            .sheet(isPresented: $isShowingDetailScreen, content: {
                DetailScreen { newItem in
                    items.append(newItem)
                } deleteAction: { item in
                    items.removeAll(where: { $0.id == item.id })
                }
            })
        }
    }
    
    var list: some View {
        List {
            Section {
                let presentedItems = items.filter({ isComplitedHidden && !$0.isDone || !isComplitedHidden })
                ForEach(presentedItems.indices, id: \.self) { index in
                    ItemView(
                        item: $items[index]) {
                            selectedItem = items[index]
                        } checkMarkAction: { isDone in
                            updateItem(index: index, isDone: isDone)
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                updateItem(index: index, isDone: true)
                            } label: {
                                Image(systemName: "checkmark.circle.fill")
                            }
                            .tint(Color.Palette.Green.color)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                items.remove(at: index)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .tint(Color.Palette.Red.color)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                selectedItem = items[index]
                            } label: {
                                Image(systemName: "info.circle.fill")
                            }
                        }
                        .tint(Color.Palette.GrayLight.color)
                        
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
                SubtitleView(items: $items, isComplitedHidden: $isComplitedHidden)
            }
        }
        .headerProminence(.increased)
        .frame(maxWidth: .infinity, alignment: .leading)
        .scrollContentBackground(.hidden)
        .background(Color.Back.Primary.color)
    }
    
    func updateItem(index: Int, isDone: Bool) {
        let currentItem = items[index]
        var newItems = items
        let updatedItem = TodoItem(
            id: currentItem.id,
            text: currentItem.text,
            importance: currentItem.importance,
            isDone: isDone,
            creationDate: currentItem.creationDate,
            deadline: currentItem.deadline,
            editedDate: currentItem.editedDate
        )
        newItems[index] = updatedItem
        items = newItems
    }
}
