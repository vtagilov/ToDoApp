//
//  View.swift
//  ToDoApp
//
//  Created by Владимир on 28.06.2024.
//

import Foundation
import SwiftUI

extension View {
    func primaryBackground() -> some View {
        return self
            .background(
                RoundedRectangle(cornerRadius: 16.0)
                    .fill(Color.Back.Secondary.color)
                    .padding(-16)
            )
            .padding(32)
    }
}
