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
    
    func loadWeather() {
        self.state = .loading

        // TODO : self.id shouldn't be optional, use a guard
        
        APIClient.standard.getWeather(for: self.id ?? 0) { (results) in
            DispatchQueue.main.async {
                switch results {
                case .success(let currentWeather):
                    self.state = .loaded(weather: currentWeather)
                case .failure(_):
                    // show some error
                    break;
                }
            }
        }
    }
}
