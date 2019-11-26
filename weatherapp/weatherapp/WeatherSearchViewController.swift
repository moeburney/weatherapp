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

class WeatherSearchViewController: UIViewController, UISearchResultsUpdating, UISearchControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var cities:[City] = []

    //var viewModel: WeatherSearchViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupTableView()
        loadCities()
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
        // update search results
    }
    
    func didTapLocation() {
        // push VC/VM loaded with location
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let city = cities[indexPath.row]
        cell.textLabel?.text = city.name
        cell.detailTextLabel?.text = city.country
        return cell
    }
    
    // TODO: put in view model
    func loadCities() {
        getCities { (results) in
            DispatchQueue.main.async {
                switch results {
                case .success(let cities):
                    self.cities = cities
                    self.tableView.reloadData()
                case .failure(_):
                    // show some error
                    break;
                }
            }
        }
    }
    
    // TODO: put in data controller
    func getCities(completion: @escaping (Result<[City],Error>)->()) -> Void {
        if let path = Bundle.main.path(forResource: "city.list", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                let json = try JSONSerialization.data(withJSONObject: jsonResponse) 
                let decoder = JSONDecoder()
                let results = try decoder.decode([City].self, from: json)
                completion(.success(results))
            } catch {
                // handle error
                print(error)
            }
        }
    }

}
