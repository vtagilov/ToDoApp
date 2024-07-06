//
//  DateCell.swift
//  ToDoApp
//
//  Created by Владимир on 05.07.2024.
//

import Foundation
import UIKit
import SwiftUI

final class DateCell: UICollectionViewCell {
    static let reuseIdentifier = "DateCell"
    private let label = UILabel()
    
    func configureCell(date: String) {
        contentView.addSubview(label)
        label.frame = CGRect(x: 3, y: 3, width: contentView.frame.width - 6, height: contentView.frame.height - 6)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.layer.borderWidth = 2
        label.clipsToBounds = true
        deselect()
        
        if date == "Другое" {
            label.text = date
        } else {
            let date = date.split(separator: " ").map({ String($0) })
            label.text = "\(date[0])\n\(date[1])"
        }
    }
    
    func select() {
        label.backgroundColor = UIColor(Color.Back.Primary.dark).withAlphaComponent(0.1)
        label.layer.borderColor = UIColor(Color.Palette.Gray.color).cgColor
    }
    
    func deselect() {
        label.backgroundColor = UIColor(.clear)
        label.layer.borderColor = UIColor(.clear).cgColor
    }
}
