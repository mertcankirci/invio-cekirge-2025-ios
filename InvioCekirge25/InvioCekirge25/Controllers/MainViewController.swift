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
    private let service = APIService()
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVC()
        configureTableView()
        
        configureUI()
    }
    
    func configureVC() {
        view.backgroundColor = .systemGroupedBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Invio Cekirge 2025"
        
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.accent]
        
        let favButton = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(favButtonTapped))
        navigationItem.rightBarButtonItems = [favButton]
    }
    
    func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .systemGroupedBackground

        tableView.backgroundView?.backgroundColor = .systemGroupedBackground
        
        tableView.estimatedRowHeight = 120
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
        page += 1
        guard let totalPage = totalPage, page <= totalPage, !fetching else { return }
        fetching = true
        
        Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let result = try await self.service.fetchData(for: page)
                await MainActor.run {
                    
                    if self.cities == nil {
                        self.cities = []
                    }
                    
                    self.tableView.performBatchUpdates {
                        let startIndex = self.cities?.count ?? 0
                        self.cities?.append(contentsOf: result.data)
                        let endIndex = startIndex + result.data.count
                        let indexSet = IndexSet(integersIn: startIndex..<endIndex)
                        self.tableView.insertSections(indexSet, with: .none)
                    } completion: { _ in
                        self.fetching = false
                    }
                }
            } catch {
                self.fetching = false
                presentAlert(errorMessage: error.localizedDescription)
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
        
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CityTableViewCell.reuseId) as? CityTableViewCell else { return UITableViewCell() }
            
            cell.delegate = self ///Setting the delegate for communication
            cell.set(city: city)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LocationTableViewCell.reuseId) as? LocationTableViewCell else { return UITableViewCell() }
            let locationIndex = indexPath.row - 1
            let location = city.locations[locationIndex]
            cell.set(location: location)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CityTableViewCell else { return }

        guard indexPath.row == 0 else { return }
        guard let cityCount = cities?[indexPath.section].locations.count, cityCount > 0 else { return }
        
        cities?[indexPath.section].isExpanded.toggle()
        
        if let city = cities?[indexPath.section] {
            if city.isExpanded {
                let indexPaths = (1...city.locations.count).map { 
                    IndexPath(row: $0, section: indexPath.section)
                }
                DispatchQueue.main.async {
                    tableView.insertRows(at: indexPaths, with: .fade)
                    cell.onSelectPerform(isExpanded: true)
                }
            } else {
                let indexPaths = (1...city.locations.count).map { 
                    IndexPath(row: $0, section: indexPath.section)
                }
                DispatchQueue.main.async {
                    tableView.deleteRows(at: indexPaths, with: .fade)
                    cell.onSelectPerform(isExpanded: false)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cities = cities else { return }
        if indexPath.section == cities.count - 2 {
            fetchNextPage()
        }
    }
}

///Cell extensions
extension MainViewController: CityTableViewCellDelegate {
    func didTapNavigationButton(from city: CityModel) {
        coordinator?.navigateToMapDetailScreen(animated: true, title: city.city, locations: city.locations)
    }
}
