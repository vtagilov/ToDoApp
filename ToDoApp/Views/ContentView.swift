//
//  ContentView.swift
//  ToDoApp
//
//  Created by Владимир on 21.06.2024.
//

import SwiftUI

#Preview {
    ContentView()
}

struct ContentView: View {
    @State
    var items = [TodoItem]()
    
    var body: some View {
        MainScreen()
    }
}
