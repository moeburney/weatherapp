//
//  WeatherSearchViewController.swift
//  weatherapp
//
//  Created by Burney, Moe (AU - Sydney) on 26/11/19.
//  Copyright © 2019 Burney, Moe (AU - Sydney). All rights reserved.
//

import UIKit

fileprivate extension String {
    static let inputPlaceholderText = "Enter city or zip code"
    static let fieldAccessibilityLabel = "Search weather by location"
}

final class WeatherSearchViewController: UIViewController, UISearchResultsUpdating, UISearchControllerDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)

    var cities:[City] = []
    var filteredCities: [City] = []
    
    var viewModel: WeatherSearchViewModel? {
        didSet {
            viewModel?.delegate = self
        }
    }
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupTableView()
        viewModel = WeatherSearchViewModel()
        viewModel?.loadCities()
    }
    
    func setupSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = String.inputPlaceholderText
        navigationItem.searchController = searchController
        definesPresentationContext = true
        self.tableView.tableHeaderView = searchController.searchBar
    }
    
    func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }

    func filterContentForSearchText(_ searchText: String) {
      filteredCities = cities.filter { (city: City) -> Bool in
        return city.name.lowercased().contains(searchText.lowercased())
      }
      tableView.reloadData()
    }
}

extension WeatherSearchViewController: WeatherSearchViewModelDelegate {
    func weatherSearchViewStateDidUpdate(
        _ viewState: WeatherSearchViewState) {
        switch viewState {
        case .loading:
            break;
        case .loaded(let cities):
            DispatchQueue.main.async {
                self.cities = cities
                self.tableView.reloadData()
            }
        case .enteredCity(let city, let id):
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "weatherDetail") as! WeatherDetailViewController
            vc.viewModel = WeatherDetailViewModel(city: city, id: id)
            self.show(vc, sender: nil)
        case .enteredZipCode(let zipCode):
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "weatherDetail") as! WeatherDetailViewController
            //    vc.viewModel = WeatherDetailViewModel(with zipCode: zipCode)
            navigationController?.pushViewController(vc, animated: true)
        case .error:
            break;
        }
    }
}

extension WeatherSearchViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
          return filteredCities.count
        }
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let city: City
        if isFiltering {
            city = filteredCities[indexPath.row]
        }
        else {
            city = cities[indexPath.row]
        }
        cell.textLabel?.text = city.name
        cell.detailTextLabel?.text = city.country
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.didEnterSearch(city: cities[indexPath.row].name, id: cities[indexPath.row].id)
    }
}
