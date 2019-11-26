//
//  WeatherDetailViewController.swift
//  weatherapp
//
//  Created by Burney, Moe (AU - Sydney) on 26/11/19.
//  Copyright © 2019 Burney, Moe (AU - Sydney). All rights reserved.
//

import UIKit

struct CurrentLocalWeather: Codable {
    let weather: [Weather]
    let wind: Wind
    let name: String
    let main: Main
    
    func summary() -> String {
        if weather.count > 0 {
            return weather[0].summary
        }
        return ""
    }
}

struct Weather: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case main
        case summary = "description"
    }
    let id: Int
    let main: String
    let summary: String
    
}

struct Wind: Codable {
    let speed: Double
    let deg: Int
}

struct Main: Codable {
    let temp: Double
    let pressure: Int
    let humidity: Int
    let temp_min: Double
    let temp_max: Double
    
    func tempDescription() -> String {
        return Int(temp).description + "°"
    }
}

class WeatherDetailViewController: UIViewController {
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var summary: UILabel!
    var id:Int?
    
    var viewModel: WeatherDetailViewModel? {
        didSet {
            viewModel?.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.loadWeather()
    }
}

extension WeatherDetailViewController: WeatherDetailViewModelDelegate {
    func weatherDetailViewStateDidUpdate(
        _ viewState: WeatherDetailViewState) {
        switch viewState {
        case .loading:
            break;
        case .loaded(let currentWeather):
            self.city.text = "Brisbane"
            self.temp.text = currentWeather.main.tempDescription()
            self.summary.text = currentWeather.summary()
        case .error:
            break;
        }
    }
}
