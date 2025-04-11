//
//  MainViewController.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 27.03.2025.
//

import UIKit

class MainViewController: UIViewController {
    
    weak var coordinator: RootCoordinator? 
    
    var cities: [CityModel]?
    var totalPage: Int?
    ///for pagination
    private var page: Int = 1
    private var fetching: Bool = false ///Variable to indicate wether if the function is fetching or not to ensure pagination correctness.
    private let apiService = APIService()
    private let persistenceService = PersistenceService.shared
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVC()
        configureTableView()
        
        configureUI()
    }
    
    func configureVC() {
        view.backgroundColor = InvioColors.groupedBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Önemli Konumlar"
        
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.accent]
        
        let favButton = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(favButtonTapped))
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark.circle"), style: .plain, target: self, action: #selector(closeButtonTapped))
        navigationItem.rightBarButtonItems = [favButton, closeButton]
    }
    
    func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = InvioColors.groupedBackground
        tableView.backgroundView?.backgroundColor = InvioColors.groupedBackground
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.separatorStyle = .none
        
        tableView.register(CityTableViewCell.self, forCellReuseIdentifier: CityTableViewCell.reuseId)
        tableView.register(LocationTableViewCell.self, forCellReuseIdentifier: LocationTableViewCell.reuseId)
    }
    
    func configureUI() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
///API functions
extension MainViewController {
    private func fetchNextPage() {
        guard let totalPage = totalPage, page <= totalPage, !fetching else { return }
       
        fetching = true
        page += 1
        
        Task.detached { [weak self] in
            guard let self = self else { return }

            
            do {
                let result = try await self.apiService.fetchData(for: page)
                if await self.cities == nil {
                    await MainActor.run {
                        self.cities = []
                    }
                }
                let startIndex = await self.cities?.count ?? 0
                
                await MainActor.run {
                    self.cities?.append(contentsOf: result.data)
                }
                
                let endIndex = startIndex + result.data.count

                await MainActor.run {
                    let indexSet = IndexSet(integersIn: startIndex..<endIndex)
                    self.tableView.performBatchUpdates {
                        self.tableView.insertSections(indexSet, with: .none)
                    } completion: { _ in
                        self.fetching = false
                    }
                    
                }
            } catch {
                await MainActor.run {
                    self.fetching = false
                    self.presentAlert(errorMessage: error.localizedDescription)
                }
            }
        }
    }
    
    private func updateFavoriteStatus(location: LocationModel, isFavorite: Bool) {
        guard let cities = cities else { return }
        for (sectionIndex, city) in cities.enumerated() {
            if let locationIndex = city.locations.firstIndex(where: { $0.id == location.id }) {
                let indexPath = IndexPath(row: locationIndex + 1, section: sectionIndex)

                if let cell = tableView.cellForRow(at: indexPath) as? LocationTableViewCell {
                    cell.set(location: location, isFavorite: isFavorite)
                }
                break
            }
        }
    }
}

///Button functions
extension MainViewController {
    @objc
    func favButtonTapped() {
        if let coordinator = coordinator {
            coordinator.navigateToFavouritesScreen(animated: true)
        }
    }
    
    @objc
    func closeButtonTapped() {
        guard var cities = cities else { return }

        var indexPathsToDelete: [IndexPath] = []

        for (sectionIndex, city) in cities.enumerated() {
            if city.isExpanded {
                city.isExpanded = false
                let indexPaths = (1...city.locations.count).map {
                    IndexPath(row: $0, section: sectionIndex)
                }
                indexPathsToDelete.append(contentsOf: indexPaths)
            }
            cities[sectionIndex] = city
        }

        self.cities = cities

        tableView.beginUpdates()
        tableView.deleteRows(at: indexPathsToDelete, with: .fade)
        tableView.endUpdates()

        for cell in tableView.visibleCells {
            if let indexPath = tableView.indexPath(for: cell),
               indexPath.row == 0,
               let cityCell = cell as? CityTableViewCell {
                cityCell.onSelectPerform(isExpanded: false)
            }
        }
    }
}

///Table View Functions
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let cities = cities else { return 0 }
        let city = cities[section]
        return city.isExpanded ? city.locations.count + 1 : 1 //Konumsuz sehir icin.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let cities = cities {
            return cities.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cities = cities else { return UITableViewCell() }
        let city = cities[indexPath.section]
        
        //indexPath.row == 0 means it's section.
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CityTableViewCell.reuseId) as? CityTableViewCell else { return UITableViewCell() }
            
            cell.delegate = self
            cell.set(city: city)
            cell.adjustImagesMaskedCorners(city.isExpanded) ///To ensure box like UI.
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LocationTableViewCell.reuseId) as? LocationTableViewCell else { return UITableViewCell() }
            let locationIndex = indexPath.row - 1
            let location = city.locations[locationIndex]
            let isFav = persistenceService.isFavorite(location: location)
            
            cell.delegate = self
            cell.set(location: location, isFavorite: isFav)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cities = cities else { return }
        let city = cities[indexPath.section]

        if indexPath.row == 0 {
            guard let cell = tableView.cellForRow(at: indexPath) as? CityTableViewCell else { return }
            guard city.locations.count > 0 else { return }

            cities[indexPath.section].isExpanded.toggle()

            let indexPaths = (1...city.locations.count).map {
                IndexPath(row: $0, section: indexPath.section)
            }

            tableView.beginUpdates()
            if city.isExpanded {
                tableView.insertRows(at: indexPaths, with: .fade)
                cell.onSelectPerform(isExpanded: true)
            } else {
                tableView.deleteRows(at: indexPaths, with: .fade)
                cell.onSelectPerform(isExpanded: false)
            }
            tableView.endUpdates()
        } else {
            let locationIndex = indexPath.row - 1
            let location = city.locations[locationIndex]
            coordinator?.navigateToLocationDetailScreen(animated: true, location: location, cityName: city.city)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cities = cities else { return }
        if indexPath.section == cities.count - 1 {
            fetchNextPage()
        }
        
        if let locationCell = cell as? LocationTableViewCell {
            let city = cities[indexPath.section]
            let isLast = indexPath.row == city.locations.count

            if isLast {
                locationCell.ifLastCellPerform()
            }
        }
    }
}

///Cell / view controller extensions
extension MainViewController: CityTableViewCellDelegate {
    func didTapNavigationButton(from city: CityModel) {
        coordinator?.navigateToMapDetailScreen(animated: true, title: city.city, locations: city.locations)
    }
}

extension MainViewController: LocationTableViewCellDelegate {
    func removedFavorite(_ fav: LocationModel) {}
    
    func errorOccured(with errorMessage: String) {
        self.presentAlert(errorMessage: errorMessage)
    }
}

extension MainViewController: LocationDetailVCDelegate {
    func didUpdateFavoriteStatus(for location: LocationModel, isFavorite: Bool) {
        updateFavoriteStatus(location: location, isFavorite: isFavorite)

    }
}

extension MainViewController: FavouritesViewControllerDelegate {
    func didDeselectLocation(_ location: LocationModel) {
        updateFavoriteStatus(location: location, isFavorite: false)
    }
}
