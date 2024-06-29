//
//  SubtitleView.swift
//  ToDoApp
//
//  Created by Владимир on 25.06.2024.
//

import Foundation
import SwiftUI

struct SubtitleView: View {
    @Binding var items: [TodoItem]
    @Binding var isComplitedHidden: Bool
    var body: some View {
        HStack {
            Text("Выполнено — \(items.filter { $0.isDone }.count)")
                .font(.subheadline)
                .foregroundColor(Color.Label.Tertiary.color)
                .scaledToFill()
                .textCase(.none)
            Button(action: {
                isComplitedHidden.toggle()
            }) {
                Text(isComplitedHidden ? "Показать" : "Скрыть")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .textCase(.none)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .foregroundColor(Color.Palette.Blue.color)
        }
    }
}
