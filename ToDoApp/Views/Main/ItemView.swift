//
//  ItemView.swift
//  ToDoApp
//
//  Created by Владимир on 25.06.2024.
//

import Foundation
import SwiftUI

#Preview {
    MainScreen()
}

struct ItemView: View {
    @Binding var item: TodoItem
    @State var isDone: Bool = false
    @State var importance: TodoItem.Importance = .common
    
    var itemAction: () -> Void
    var checkMarkAction: (Bool) -> Void
    
    var body: some View {
        HStack {
            CheckMarkView(isDone: $isDone, importance: $importance, action: {
                checkMarkAction(!item.isDone)
            })
            .padding(.trailing)
            
            VStack(alignment: .leading) {
                if item.isDone {
                    Text(item.text)
                        .lineLimit(3)
                        .foregroundColor(Color.Label.Tertiary.color)
                        .strikethrough()
                } else {
                    if item.importance == .important {
                        Text("‼\(item.text)")
                            .lineLimit(3)
                    } else {
                        Text(item.text)
                            .lineLimit(3)
                    }
                    if let deadline = item.deadline {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundStyle(Color.Label.Tertiary.color)
                            Text(DateFormatter.convertToStringDayMonthYear(deadline))
                                .foregroundStyle(Color.Label.Tertiary.color)
                        }
                    }
                }
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .foregroundColor(Color.Palette.Gray.color)
        }
        .padding(.vertical, 6)
        .background(Color.clear)
        .contentShape(Rectangle())
        .onTapGesture {
            itemAction()
        }
        .onChange(of: item.importance) {
            self.importance = item.importance
        }
        .onChange(of: item.isDone) {
            self.isDone = item.isDone
        }
        .onAppear(perform: {
            self.isDone = item.isDone
            self.importance = item.importance
        })
    }
}

struct CheckMarkView: View {
    enum Status {
        case done
        case notDone
        case important
    }
    
    @Binding
    var isDone: Bool
    @Binding
    var importance: TodoItem.Importance
    
    var status: Status {
        if isDone {
            return .done
        } else {
            if importance == .important {
                return .important
            } else {
                return .notDone
            }
        }
    }
    
    var action: () -> Void
    
    var body: some View {
        statusImage(status: status)
            .onTapGesture {
                action()
                isDone.toggle()
            }
    }
    
    private func statusImage(status: Status) -> some View {
        let image: Image
        let foregroundColor: Color
        var backgroundColor: Color = .clear
        
        switch status {
        case .done:
            image = Image(systemName: "checkmark.circle.fill")
            foregroundColor = Color.Palette.Green.color
        case .notDone:
            image = Image(systemName: "circle")
            foregroundColor = Color.Support.Separator.color
        case .important:
            image = Image(systemName: "circle")
            foregroundColor = Color.Palette.Red.color
            backgroundColor = Color.Palette.Red.color
        }
        
        return image
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundStyle(foregroundColor)
            .backgroundStyle(backgroundColor)
    }
}
