//
//  WeatherDetailViewModel.swift
//  weatherapp
//
//  Created by Burney, Moe (AU - Sydney) on 26/11/19.
//  Copyright © 2019 Burney, Moe (AU - Sydney). All rights reserved.
//

import Foundation

protocol WeatherDetailViewModelDelegate: WeatherDetailViewController {
    func weatherDetailViewStateDidUpdate(_ viewState: WeatherDetailViewState)
}

enum WeatherDetailViewState {
    case loading
    case loaded(weather: CurrentLocalWeather)
    case error
}

final class WeatherDetailViewModel {
    weak var delegate: WeatherDetailViewModelDelegate?

    var city: String?
    var id:Int?
    var zipCode:String?
    
    private var state: WeatherDetailViewState = .loading {
        didSet {
            delegate?.weatherDetailViewStateDidUpdate(state)
        }
    }

    init(city: String, id:Int) {
        self.city = city
        self.id = id
    }
    
    init(zipCode:String) {
        self.zipCode = zipCode
    }
    
    // If open weather ID is available, call API with that, otherwise call by zip codes
    func loadWeather() {
        self.state = .loading
        if let id = self.id {
            loadWeather(id: id)
        }
        else if let zipCode = self.zipCode {
            loadWeather(zipCode: zipCode)
        }
    }
    
    // Call API to get local weather by ID representing a city
    func loadWeather(id: Int) {
        APIClient.standard.getWeather(id: id) { [weak self] (results) in
            DispatchQueue.main.async {
                switch results {
                case .success(let currentWeather):
                    self?.state = .loaded(weather: currentWeather)
                case .failure(_):
                    self?.state = .error
                }
            }
        }
    }
    
    // Call API to get local weather by zip code
    func loadWeather(zipCode: String) {
        APIClient.standard.getWeather(zipCode: zipCode) { [weak self] (results) in
            DispatchQueue.main.async {
                switch results {
                case .success(let currentWeather):
                    self?.state = .loaded(weather: currentWeather)
                case .failure(_):
                    self?.state = .error
                }
            }
        }
    }
}
