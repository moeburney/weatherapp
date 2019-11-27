//
//  WeatherSearchViewModel.swift
//  weatherapp
//
//  Created by Burney, Moe (AU - Sydney) on 26/11/19.
//  Copyright © 2019 Burney, Moe (AU - Sydney). All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherSearchViewModelDelegate: class {
    func weatherSearchViewStateDidUpdate(_ viewState: WeatherSearchViewState)
}

enum WeatherSearchViewState {
    case loading
    case loaded(cities: [City])
    case gpsLoaded
    case enteredCity(city:String, id: Int)
    case enteredZipCode(zipCode: String)
    case error

    // for testing if data was loaded
    func getCities() -> [City]? {
        if case .loaded(let cities) = self {
            return cities
        }
        return nil
    }
}

final class WeatherSearchViewModel {
    weak var delegate: WeatherSearchViewModelDelegate? {
        didSet {
            delegate?.weatherSearchViewStateDidUpdate(state)
        }
    }

    private var state: WeatherSearchViewState = .loading {
        didSet {
            delegate?.weatherSearchViewStateDidUpdate(state)
        }
    }
    
    // Load the cities json file from the local store
    func loadCities() {
        self.state = .loading
        APIClient.standard.getCities { [weak self] (results) in
            switch results {
            case .success(let cities):
                self?.state = .loaded(cities: cities)
            case .failure(_):
                self?.state = .error
            }
        }
    }
    
    func didLoadGPS() {
        state = .gpsLoaded
    }
    
    // User selected a city in the local cities json file
    func didEnterSearch(city:String, id: Int) {
        state = .enteredCity(city: city, id: id)
    }
    
    // User manually entered a zip code
    func didEnterSearch(zipCode: String) {
        state = .enteredZipCode(zipCode: zipCode)
    }
    
    func getNearestCityTo(userLocation: CLLocationCoordinate2D, cities: [City]) -> City? {
        let userCoordinates = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let cityLocations = cities.map { $0.location }
        let closestCity = cityLocations.min(by:
        { $0.distance(from: userCoordinates) < $1.distance(from: userCoordinates) })
        
        let city = cities.filter {
                $0.location.coordinate.latitude == closestCity!.coordinate.latitude &&
                $0.location.coordinate.longitude == closestCity!.coordinate.longitude }.first
        
        guard let userCity = city else { return nil }
        return City(id: userCity.id,
                    name: "My Location",
                    country: userCity.country,
                    coord: userCity.coord)
    }
}
