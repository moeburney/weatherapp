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
    var filteredCities: [City] = []
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }

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
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
    
    func didSearchCity(id: Int) {
        self.performSegue(withIdentifier: "weatherDetail", sender: nil)

        // push VC/VM loaded with location
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //guard let index = self.tableView.indexPathForSelectedRow else { return }
        //let city = cities[index.row]
        //let eventDetailViewModel = EventDetailViewModel(event: event)
        //guard let destVC = segue.destination as? WeatherDetailViewController else { return }
        //destVC.viewModel = eventDetailViewModel
    }
    
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
        // Call the API with this id
        print(cities[indexPath.row].id)
        didSearchCity(id: cities[indexPath.row].id)
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
    
    func filterContentForSearchText(_ searchText: String) {
      filteredCities = cities.filter { (city: City) -> Bool in
        return city.name.lowercased().contains(searchText.lowercased())
      }
      
      tableView.reloadData()
    }

}
