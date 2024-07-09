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
    private let circle = UIView()
    
    func configureCell(item: TodoItem) {
        contentView.addSubview(label)
        contentView.addSubview(circle)
        itemId = item.id
        circle.backgroundColor = UIColor(item.category.color)
        circle.layer.cornerRadius = 7.5
        circle.layer.shadowColor = UIColor.black.cgColor
        circle.layer.shadowOpacity = 0.3
        circle.layer.shadowRadius = 7
        
        if item.isDone {
            let text = NSMutableAttributedString(string: item.text)
            text.addAttribute(
                .strikethroughStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSRange(location: 0, length: text.length)
            )
            label.attributedText = text
        } else {
            let text = NSMutableAttributedString(string: item.text)
            label.attributedText = text
        }
        configureConstraints()
    }
    
    private func configureConstraints() {
        label.translatesAutoresizingMaskIntoConstraints = false
        circle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25),
            label.trailingAnchor.constraint(equalTo: circle.leadingAnchor, constant: -10),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            label.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            
            circle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -25),
            circle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            circle.heightAnchor.constraint(equalToConstant: 15),
            circle.widthAnchor.constraint(equalToConstant: 15)
        ])
    }
}
