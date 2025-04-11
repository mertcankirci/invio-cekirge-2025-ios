//
//  FavouritesViewController.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 27.03.2025.
//

import UIKit

protocol FavouritesViewControllerDelegate: AnyObject {
    func didDeselectLocation(_ location: LocationModel)
}

class FavouritesViewController: UIViewController {
    weak var coordinator: FavouritesCoordinator?
    weak var delegate: FavouritesViewControllerDelegate?
    private let persistenceService = PersistenceService.shared
    var favorites = [LocationModel]()
    
    private let tableView = UITableView()
    private let emptyStateView = EmptyStateView(description: "Henüz hiçbir konumu favorilerine eklemedin!", imageName: "tray", frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureTableView()
        configureComponentVisibilty()
        
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorites()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if self.isMovingFromParent || self.isBeingDismissed {
            coordinator?.coordinatorDidFinish()
        }
    }
    
    private func configureComponentVisibilty() {
        let hasFavorites = !favorites.isEmpty

        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.emptyStateView.alpha = hasFavorites ? 0 : 1
            self?.tableView.alpha = hasFavorites ? 1 : 0
        }

        self.emptyStateView.isUserInteractionEnabled = !hasFavorites
        self.tableView.isUserInteractionEnabled = hasFavorites
    }
    
    func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundView?.backgroundColor = InvioColors.groupedBackground
        tableView.backgroundColor = InvioColors.groupedBackground
        
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(LocationTableViewCell.self, forCellReuseIdentifier: LocationTableViewCell.reuseId)
    }
    
    func configureViewController() {
        view.backgroundColor = InvioColors.groupedBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Favorilerim"
    }
    
    func configureUI() {
        [tableView, emptyStateView].forEach({ view.addSubview($0) })
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.heightAnchor.constraint(equalToConstant: 300),
        ])
    }
}

//tableview delegate methods
extension FavouritesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LocationTableViewCell.reuseId) as? LocationTableViewCell else { return UITableViewCell() }
        let location = favorites[indexPath.row]
        let isFav = persistenceService.isFavorite(location: location)
        
        cell.delegate = self
        cell.set(location: location, isFavorite: isFav)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let _ = tableView.dequeueReusableCell(withIdentifier: LocationTableViewCell.reuseId, for: indexPath) as? LocationTableViewCell else { return }
        let location = favorites[indexPath.row]
        coordinator?.navigateToMapDetailView(with: location)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let locationCell = cell as? LocationTableViewCell {
            let isLast = indexPath.row == favorites.count - 1
            let isFirst = indexPath.row == 0
            
            ///A cell could be both first and last at the same time.
            if isFirst && isLast {
                locationCell.ifOnlyCellPerform()
            } else {
                if isFirst {
                    locationCell.ifFirstCellPerform()
                }
                if isLast {
                    locationCell.ifLastCellPerform()
                }
            }

        }
    }
}

//custom functions
extension FavouritesViewController {
    private func loadFavorites() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.favorites = persistenceService.favoriteLocations
            self.configureComponentVisibilty()
            self.tableView.reloadData()
        }
    }
    
    private func updateFirstLastCellStates() {
        let visibleIndexPaths = tableView.indexPathsForVisibleRows ?? []
        for indexPath in visibleIndexPaths {
            guard let cell = tableView.cellForRow(at: indexPath) as? LocationTableViewCell else { continue }

            let isFirst = indexPath.row == 0
            let isLast = indexPath.row == favorites.count - 1

            if isFirst && isLast {
                cell.ifOnlyCellPerform()
            } else {
                if isFirst { cell.ifFirstCellPerform() }
                if isLast { cell.ifLastCellPerform() }
            }

            let location = favorites[indexPath.row]
            let isFav = persistenceService.isFavorite(location: location)
            cell.set(location: location, isFavorite: isFav)
        }
    }
}

//cell extensions
extension FavouritesViewController: LocationTableViewCellDelegate {
    func removedFavorite(_ fav: LocationModel) {
        guard let index = favorites.firstIndex(where: { $0.id == fav.id }) else { return }
        favorites.remove(at: index)
        
        let indexPath = IndexPath(row: index, section: 0)
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.updateFirstLastCellStates()
            self?.delegate?.didDeselectLocation(fav)
            self?.configureComponentVisibilty()
        }
    }
    
    func errorOccured(with errorMessage: String) {
        self.presentAlert(errorMessage: errorMessage)
    }
}
