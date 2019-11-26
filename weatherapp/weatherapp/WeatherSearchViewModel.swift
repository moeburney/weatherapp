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
    case enteredCity(id: Int)
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

    // TODO: remove this if not needed
    init() {
    }
    
    func loadCities() {
        getCities { (results) in
                switch results {
                case .success(let cities):
                    self.state = .loaded(cities: cities)
                case .failure(_):
                    self.state = .error
                }
        }
    }
    
    // TODO: create an API client class for this
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
    
    func didEnterSearch(for id: Int) {
        state = .enteredCity(id: id)
    }
    
    func didEnterSearch(for zipCode: String) {
        state = .enteredZipCode(zipCode: zipCode)
    }
}
