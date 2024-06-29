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
    @State var isCalendarHidden = true
    @State var isDeadlineDefined: Bool = false
    
    var deleteAction: () -> Void
    
    var body: some View {
        VStack {
            importanceView
            Divider()
            deadlineView
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
                    .tag(TodoItem.Importance.notImportant)
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
                VStack {
                    Text("Сделать до")
                        .padding(.trailing)
                    if let deadline = deadline, isDeadlineDefined {
                        Text(DateConverter.convertToStringDayMonthYear(deadline))
                            .frame(alignment: .leading)
                            .foregroundStyle(Color.Palette.Blue.color)
                    }
                }
                .onTapGesture {
                    if isDeadlineDefined {
                        isCalendarHidden.toggle()
                    }
                }
                Spacer()
                Toggle("", isOn: $isDeadlineDefined)
                    .onChange(of: isDeadlineDefined) {
                        isSaveButtonAvailable = true
                        if deadline == nil {
                            deadline = Date().addingTimeInterval(86400)
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
    }
    
    var deleteButton: some View {
        Button(action: {
            deleteAction()
        }, label: {
            Text("Удалить")
                .foregroundColor(Color.Palette.Red.color)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.Palette.White.color)
                .cornerRadius(8)
        })
        .padding(.horizontal)
    }
}
