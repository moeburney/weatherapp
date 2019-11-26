//
//  WeatherSearchViewModel.swift
//  weatherapp
//
//  Created by Burney, Moe (AU - Sydney) on 26/11/19.
//  Copyright © 2019 Burney, Moe (AU - Sydney). All rights reserved.
//

import Foundation

protocol WeatherSearchViewModelDelegate: WeatherSearchViewController {
    func weatherSearchViewStateDidUpdate(_ viewState: WeatherSearchViewState)
}

enum WeatherSearchViewState {
    case loading
    case loaded(cities: [City])
    case enteredCity(city:String, id: Int)
    case enteredZipCode(zipCode: String)
    case error
}

final class WeatherSearchViewModel {
    weak var delegate: WeatherSearchViewModelDelegate?

    private var state: WeatherSearchViewState = .loading {
        didSet {
            delegate?.weatherSearchViewStateDidUpdate(state)
        }
    }
    
    func loadCities() {
        APIClient.standard.getCities { (results) in
            switch results {
            case .success(let cities):
                self.state = .loaded(cities: cities)
            case .failure(_):
                self.state = .error
            }
        }
    }
    
    func didEnterSearch(city:String, id: Int) {
        state = .enteredCity(city: city, id: id)
    }
    
    func didEnterSearch(zipCode: String) {
        state = .enteredZipCode(zipCode: zipCode)
    }
}
