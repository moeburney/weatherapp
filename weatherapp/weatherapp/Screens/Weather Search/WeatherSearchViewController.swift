//
//  WeatherSearchViewController.swift
//  weatherapp
//
//  Created by Burney, Moe (AU - Sydney) on 26/11/19.
//  Copyright © 2019 Burney, Moe (AU - Sydney). All rights reserved.
//

import UIKit
import CoreLocation

fileprivate extension String {
    static let inputPlaceholderText = "Enter city or zip code"
    static let inputPlaceholderTextWithGPS = "Enter city, zip code, or \"My Location\""

    static let fieldAccessibilityLabel = "Search weather by location"
}

// The entry point of the app,
// where user can search city, current location, or zip code to get current weather info
final class WeatherSearchViewController: UIViewController, UISearchResultsUpdating, UISearchControllerDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    // TODO: this is used in in another class, make it a separate VC to be reusable
    let loadingIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)

    var cities:[City] = []
    var filteredCities: [City] = []
    let locationManager = CLLocationManager()
    
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
        setupLoadingIndicator()
        setupLocationManager()
        viewModel = WeatherSearchViewModel()
        viewModel?.loadCities()
    }
    
    func setupSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = String.inputPlaceholderText
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.delegate = self

        //self.tableView.tableHeaderView = searchController.searchBar
    }
    
    func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func setupLoadingIndicator() {
        self.view.addSubview(loadingIndicator)
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupLocationManager() {
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
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
    
    // If user presses "search" instead of tapping on a city in the tableview,
    // check if the search is numerical. If it is, try to search by zip code.
    // Otherwise, do nothing.
    // TODO: the UX of this approach requires some discussion, since doing nothing
    // could confuse the user.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchBarText = searchBar.text,
        let _ = Int(searchBarText) {
            viewModel?.didEnterSearch(zipCode: searchBarText)
        }
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
}

extension WeatherSearchViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLoc: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        let userCoordinates = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
        let cityLocations = self.cities.map { $0.location }
        let closestCity = cityLocations.min(by:
        { $0.distance(from: userCoordinates) < $1.distance(from: userCoordinates) })
        let city = self.cities.filter {
            $0.location.coordinate.latitude == closestCity!.coordinate.latitude &&
                $0.location.coordinate.longitude == closestCity!.coordinate.longitude }.first
        if city != nil {
            let city1 = City(id: city!.id,
                             name: "My Location",
                             country: city!.country,
                             coord: city!.coord)
            // add a field to cities called "My Location" with city as the object
            self.cities.append(city1)
            DispatchQueue.main.async {
                self.searchController.searchBar.placeholder = String.inputPlaceholderTextWithGPS
                self.tableView.reloadData()
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func requestLocation() {
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.requestLocation()
        }
    }
}

extension WeatherSearchViewController: WeatherSearchViewModelDelegate {
    func weatherSearchViewStateDidUpdate(
        _ viewState: WeatherSearchViewState) {
        switch viewState {
        // The json file is loading, show spinner
        case .loading:
            DispatchQueue.main.async { [weak self] in
                self?.tableView.isHidden = true
                self?.loadingIndicator.startAnimating()
            }
        // The json file is loaded, reload table of cities
        case .loaded(let cities):
            DispatchQueue.main.async { [weak self] in
                self?.loadingIndicator.stopAnimating()
                self?.tableView.isHidden = false
                self?.cities = cities
                self?.tableView.reloadData()
                self?.requestLocation()
            }
        // User has tapped a city from the list, go to next screen and call API
        case .enteredCity(let city, let id):
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "weatherDetail") as! WeatherDetailViewController
            vc.viewModel = WeatherDetailViewModel(city: city, id: id)
            self.show(vc, sender: nil)
        // User has manually entered a zip code with keyboard, go to next screen and call API
        case .enteredZipCode(let zipCode):
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "weatherDetail") as! WeatherDetailViewController
            vc.viewModel = WeatherDetailViewModel(zipCode: zipCode)
            self.show(vc, sender: nil)
        // TODO: show an error
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
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Cell")

        let city: City
        // If there has been some search kehboard input, filter the cities based on that
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
        if isFiltering {
            viewModel?.didEnterSearch(city: filteredCities[indexPath.row].name,
                                      id: cities[indexPath.row].id)
        }
        else {
            viewModel?.didEnterSearch(city: cities[indexPath.row].name,
                                      id: cities[indexPath.row].id)
        }
    }
}
