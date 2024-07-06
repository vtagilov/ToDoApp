//
//  CalendarViewController.swift
//  ToDoApp
//
//  Created by Владимир on 04.07.2024.
//

import UIKit
import SwiftUI

struct CalendarViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let calendarVC = CalendarViewController()
        let navigationController = UINavigationController(rootViewController: calendarVC)
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    }
}


final class CalendarViewController: UIViewController {
    private let viewModel = CalendarItemsViewModel()
    
    private var itemsView: CalendarItemsView!
    private var datesView: CalendarDatesView!
    
    private let plusButton: UIButton = {
        let plusImage = UIImage(systemName: "plus.circle.fill")?.withTintColor(UIColor(Color.Palette.White.color))
        let button = UIButton()
        button.setImage(plusImage, for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        return button
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(Color.Palette.Gray.color).withAlphaComponent(0.3)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setNavigationBar()
        setConstraints()
    }
    
    private func setUpUI() {
        self.view.backgroundColor = UIColor(Color.Back.Primary.color)
        
        datesView = CalendarDatesView(viewModel: viewModel, itemsView: nil)
        itemsView = CalendarItemsView(viewModel: viewModel, datesView: datesView, openDetailScreen: openDetailScreen)
        datesView.itemsView = itemsView
        
        plusButton.addTarget(self, action: #selector(openDetailScreen), for: .touchUpInside)
    }
    
    private func setNavigationBar() {
        self.title = "Мои дела"
        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: "list.bullet"),
            style: .plain,
            target: self,
            action: #selector(closeViewController)
        )
        self.navigationItem.leftBarButtonItem = closeButton
    }

    @objc private func closeViewController() {
        self.dismiss(animated: true)
    }
    
    @objc private func openDetailScreen() {
        let detailView = DetailScreen(
            item: viewModel.selectedItem,
            saveAction: { item in
                self.viewModel.addItem(item)
                self.itemsView.reloadData()
                self.datesView.reloadData()
            },
            deleteAction: { item in
                self.viewModel.removeItem(item)
                self.itemsView.reloadData()
                self.datesView.reloadData()
            }
        )
        let hostingController = UIHostingController(rootView: detailView)
        present(hostingController, animated: true, completion: {
            self.viewModel.selectedItem = nil
        })
    }
}

extension CalendarViewController {
    private func setConstraints() {
        for subview in [datesView, itemsView, plusButton, separatorView] {
            if let subview = subview {
                view.addSubview(subview)
                subview.translatesAutoresizingMaskIntoConstraints = false
            }
        }
        
        NSLayoutConstraint.activate([
            datesView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            datesView.heightAnchor.constraint(equalToConstant: 75),
            datesView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            datesView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.topAnchor.constraint(equalTo: datesView.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            itemsView.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            itemsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            itemsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            itemsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            plusButton.heightAnchor.constraint(equalToConstant: 44),
            plusButton.widthAnchor.constraint(equalToConstant: 44),
            plusButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plusButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
