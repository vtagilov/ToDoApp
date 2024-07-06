//
//  TodoItemCell.swift
//  ToDoApp
//
//  Created by Владимир on 05.07.2024.
//

import Foundation
import UIKit


final class TodoItemCell: UITableViewCell {
    static let reuseIdentifier = "TodoItemCell"
    var itemId = ""
    private let label = UILabel()
    
    func configureCell(item: TodoItem) {
        contentView.addSubview(label)
        itemId = item.id
        if item.isDone {
            let text = NSMutableAttributedString(string: item.text)
            text.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.length))
            label.attributedText = text
        } else {
            let text = NSMutableAttributedString(string: item.text)
            label.attributedText = text
        }
        configureConstraints()
    }
    
    private func configureConstraints() {
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -25),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            label.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
        ])
    }
}
