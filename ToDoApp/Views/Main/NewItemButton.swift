//
//  NewItemButton.swift
//  ToDoApp
//
//  Created by Владимир on 25.06.2024.
//

import Foundation
import SwiftUI

struct NewItemButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .frame(width: 44, height: 44)
                .foregroundColor(Color.Palette.Blue.color)
                .background(
                    Circle()
                        .foregroundStyle(Color.Palette.White.color)
                )
                .shadow(color: Color.Palette.Blue.color.opacity(0.2), radius: 8, x: 0, y: 8)
        }
    }
}
