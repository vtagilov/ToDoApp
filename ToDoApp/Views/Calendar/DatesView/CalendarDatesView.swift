//
//  CalendarDatesView.swift
//  ToDoApp
//
//  Created by Владимир on 06.07.2024.
//

import Foundation
import UIKit
import SwiftUI

final class CalendarDatesView: UICollectionView {
    weak var itemsView: CalendarItemsView?
    
    private weak var viewModel: CalendarItemsViewModel?
    private var selectedDateIndex: IndexPath? = IndexPath(row: 0, section: 0)
    
    init(viewModel: CalendarItemsViewModel, itemsView: CalendarItemsView?) {
        self.viewModel = viewModel
        self.itemsView = itemsView
        super.init(frame: .zero, collectionViewLayout: CalendarDatesView.configureLayout())
        configureCollectionView()
        self.dataSource = self
        self.delegate = self
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCollectionView() {
        showsHorizontalScrollIndicator = false
        allowsSelection = true
        register(DateCell.self, forCellWithReuseIdentifier: DateCell.reuseIdentifier)
        backgroundColor = UIColor(Color.Back.Primary.color)
    }
    
    static func configureLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 85, height: 75)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        return layout
    }
}

extension CalendarDatesView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.uniqueDeadlines.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DateCell.reuseIdentifier, for: indexPath)
        guard let cell = cell as? DateCell else {
            return UICollectionViewCell()
        }
        let date = viewModel?.uniqueDeadlines[indexPath.row] ?? ""
        cell.configureCell(date: date)
        if selectedDateIndex == indexPath {
            cell.select()
        }
        return cell
    }
}


extension CalendarDatesView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedIndexPath = selectedDateIndex {
            if let cell = collectionView.cellForItem(at: selectedIndexPath) as? DateCell {
                cell.deselect()
            }
        }
        if let cell = collectionView.cellForItem(at: indexPath) as? DateCell {
            cell.select()
            selectedDateIndex = indexPath
        }
        self.itemsView?.lastVisibleSection = indexPath.row
        itemsView?.isScrollingProgrammatically = true
        itemsView?.scrollToRow(at: IndexPath(row: 0, section: indexPath.row), at: .top, animated: true)
    }
}
