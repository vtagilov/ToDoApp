//
//  OptionsView.swift
//  ToDoApp
//
//  Created by Владимир on 28.06.2024.
//

import Foundation
import SwiftUI

struct OptionsView: View {
    @Binding var importance: TodoItem.Importance
    @Binding var isSaveButtonAvailable: Bool
    @Binding var deadline: Date?
    @Binding var category: TodoItem.Category
    @State var isCalendarHidden = true
    @State var isDeadlineDefined: Bool = false
    
    var deleteAction: () -> Void
    
    var body: some View {
        VStack {
            importanceView
            Divider()
            deadlineView
            Divider()
            categoryPicker
        }
        .primaryBackground()
        .onAppear(perform: {
            isDeadlineDefined = deadline != nil
        })
        deleteButton
        Spacer()
    }
    
    var importanceView: some View {
        HStack {
            Text("Важность")
            Spacer()
            Picker("", selection: $importance) {
                Image(systemName: "arrow.down")
                    .tag(TodoItem.Importance.unimportant)
                    .frame(width: 16, height: 20)
                Text("нет")
                    .tag(TodoItem.Importance.common)
                Text("‼")
                    .tag(TodoItem.Importance.important)
                    .frame(width: 16, height: 20)
            }
            .onChange(of: importance, {
                isSaveButtonAvailable = true
            })
            .frame(maxWidth: 150)
            .pickerStyle(.segmented)
        }
    }
    
    var deadlineView: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Сделать до")
                    if let deadline = deadline, isDeadlineDefined {
                        Text(DateFormatter.convertToStringDayMonthYear(deadline))
                            .foregroundStyle(Color.Palette.Blue.color)
                            .transition(.opacity)
                    }
                }
                .onTapGesture {
                    if isDeadlineDefined {
                        withAnimation {
                            isCalendarHidden.toggle()
                        }
                    }
                }
                Spacer()
                Toggle("", isOn: $isDeadlineDefined)
                    .onChange(of: isDeadlineDefined) {
                        if deadline == nil {
                            deadline = Date.startOfNextDay()
                        }
                        if !isDeadlineDefined {
                            deadline = nil
                        }
                        withAnimation {
                            isSaveButtonAvailable = true
                        }
                    }
            }
            if !isCalendarHidden {
                DatePicker(
                    "Выберите дату",
                    selection: Binding(
                        get: {
                            deadline ?? Date()
                        },
                        set: {
                            deadline = $0
                            isSaveButtonAvailable = true
                        }
                    ),
                    displayedComponents: .date
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .labelsHidden()
            }
        }
        .animation(.easeInOut, value: isDeadlineDefined)
        .animation(.easeInOut, value: isCalendarHidden)
    }
    
    var deleteButton: some View {
        Button(action: {
            deleteAction()
        }, label: {
            Text("Удалить")
                .foregroundColor(Color.Palette.Red.color)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.Back.Secondary.color)
                .cornerRadius(8)
        })
        .padding(.horizontal)
    }
        
    var categoryPicker: some View {
        HStack {
            Text("Категория")
            Spacer()
            Picker(
                "",
                selection: $category) {
                    ForEach([TodoItem.Category.work, TodoItem.Category.study, TodoItem.Category.hobby, TodoItem.Category.other]) { category in
                        HStack {
                            Text(category.rawValue.capitalized)
                                .foregroundColor(category.color != .clear ? category.color : Color.Label.Primary.color)
                            Circle()
                                .foregroundStyle(category.color)
                                .frame(width: 10, height: 10)
                        }
                        .tag(category)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .scaledToFit()
        }
        .frame(maxHeight: 100)
    }
}
