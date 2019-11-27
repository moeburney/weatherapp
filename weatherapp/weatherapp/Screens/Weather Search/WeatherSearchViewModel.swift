//
//  WeatherSearchViewModel.swift
//  weatherapp
//
//  Created by Burney, Moe (AU - Sydney) on 26/11/19.
//  Copyright © 2019 Burney, Moe (AU - Sydney). All rights reserved.
//

import Foundation

protocol WeatherSearchViewModelDelegate: class {
    func weatherSearchViewStateDidUpdate(_ viewState: WeatherSearchViewState)
}

enum WeatherSearchViewState {
    case loading
    case loaded(cities: [City])
    case enteredCity(city:String, id: Int)
    case enteredZipCode(zipCode: String)
    case error
    
    // for testing if model was loaded
    func isLoaded() -> Bool {
        if case .loaded = self {
            return true
        }
        return false
    }
    
    // for testing if data was loaded
    func getCities() -> [City]? {
        if case .loaded(let cities) = self {
            return cities
        }
        return nil
    }
}

final class WeatherSearchViewModel {
    weak var delegate: WeatherSearchViewModelDelegate?

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
    
    // User selected a city in the local cities json file
    func didEnterSearch(city:String, id: Int) {
        state = .enteredCity(city: city, id: id)
    }
    
    // User manually entered a zip code
    func didEnterSearch(zipCode: String) {
        state = .enteredZipCode(zipCode: zipCode)
    }
}
