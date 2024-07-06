//
//  CalendarTableView.swift
//  ToDoApp
//
//  Created by Владимир on 05.07.2024.
//

import Foundation
import UIKit
import SwiftUI

final class CalendarItemsView: UITableView {
    private let openDetailScreen: () -> Void
    var lastVisibleSection = -1
    var isScrollingProgrammatically = false
    private weak var viewModel: CalendarItemsViewModel?
    private weak var datesView: CalendarDatesView?
    
    init(viewModel: CalendarItemsViewModel, datesView: CalendarDatesView, openDetailScreen: @escaping () -> Void) {
        self.viewModel = viewModel
        self.datesView = datesView
        self.openDetailScreen = openDetailScreen
        super.init(frame: .zero, style: .insetGrouped)
        configureTableView()
        self.dataSource = self
        self.delegate = self
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func scrollToRow(at indexPath: IndexPath, at scrollPosition: UITableView.ScrollPosition, animated: Bool, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.scrollToRow(at: indexPath, at: scrollPosition, animated: animated)
        CATransaction.commit()
    }
    
    private func configureTableView() {
        register(TodoItemCell.self, forCellReuseIdentifier: TodoItemCell.reuseIdentifier)
        sectionFooterHeight = 0
        backgroundColor = UIColor(Color.Back.Primary.color)
    }
    
}

extension CalendarItemsView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.uniqueDeadlines.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let deadLine = viewModel?.uniqueDeadlines[section] ?? "0"
        let itemsCount = viewModel?.itemsDict[deadLine]?.count ?? 0
        return itemsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TodoItemCell.reuseIdentifier, for: indexPath)
        guard let cell = cell as? TodoItemCell else {
            return UITableViewCell()
        }
        let deadLine = viewModel?.uniqueDeadlines[indexPath.section] ?? "0"
        let item = viewModel?.itemsDict[deadLine]?[indexPath.row]
        if let item = item {
            cell.configureCell(item: item)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel?.uniqueDeadlines[section]
    }
}

extension CalendarItemsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TodoItemCell {
            viewModel?.selectItemById(itemId: cell.itemId)
            openDetailScreen()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isScrollingProgrammatically {
            return
        }
        guard let visibleIndexPaths = indexPathsForVisibleRows else { return }
        let sortedIndexPaths = visibleIndexPaths.sorted()
        guard let firstVisibleIndexPath = sortedIndexPaths.first else { return }
        let currentVisibleSection = firstVisibleIndexPath.section
        if currentVisibleSection != lastVisibleSection {
            let lastIndexPath = IndexPath(row: lastVisibleSection, section: 0)
            let indexPath = IndexPath(row: currentVisibleSection, section: 0)
            datesView?.scrollToItem(at: indexPath, at: .left, animated: true)
            if let lastCell = datesView?.cellForItem(at: lastIndexPath) as? DateCell {
                lastCell.deselect()
            }
            if let cell = datesView?.cellForItem(at: indexPath) as? DateCell {
                cell.select()
            }
            lastVisibleSection = currentVisibleSection
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if isScrollingProgrammatically {
            isScrollingProgrammatically = false
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let doneAction = UIContextualAction(style: .normal, title: "") { [weak self] (_,_,completionHandler) in
            guard let self = self else { return }
            if let cell = tableView.cellForRow(at: indexPath) as? TodoItemCell {
                if let item = self.viewModel?.getItemById(itemId: cell.itemId) {
                    UIView.animate(withDuration: 0.1, animations: {
                        cell.contentView.frame.origin.x = 0
                    }, completion: { _ in
                        self.viewModel?.updateItem(item, true)
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                        completionHandler(true)
                    })
                }
            }
        }
        
        doneAction.backgroundColor = UIColor(Color.Palette.Green.color)
        doneAction.image = UIImage(systemName: "checkmark.circle.fill")
        return UISwipeActionsConfiguration(actions: [doneAction])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let notDoneAction = UIContextualAction(style: .normal, title: "") { [weak self] (_,_,completionHandler) in
            guard let self = self else { return }
            if let cell = tableView.cellForRow(at: indexPath) as? TodoItemCell {
                if let item = self.viewModel?.getItemById(itemId: cell.itemId) {
                    self.viewModel?.updateItem(item, false)
                    UIView.animate(withDuration: 0.1, animations: {
                        cell.contentView.frame.origin.x = 0
                    }, completion: { _ in
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                        completionHandler(true)
                    })
                }
            }
        }
        
        notDoneAction.backgroundColor = UIColor(Color.Palette.Red.color)
        notDoneAction.image = UIImage(systemName: "xmark.circle.fill")
        return UISwipeActionsConfiguration(actions: [notDoneAction])
    }
}
