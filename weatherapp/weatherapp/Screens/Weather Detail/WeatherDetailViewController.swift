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
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var summary: UILabel!
    
    var id:Int?
    
    let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
    let loadingIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    
    var viewModel: WeatherDetailViewModel? {
        didSet {
            viewModel?.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoadingIndicator()
        viewModel?.loadWeather()
    }
    
    func setupLoadingIndicator() {
        self.view.addSubview(loadingIndicator)
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension WeatherDetailViewController: WeatherDetailViewModelDelegate {
    func weatherDetailViewStateDidUpdate(
        _ viewState: WeatherDetailViewState) {
        switch viewState {
        case .loading:
            contentView.isHidden = true
            loadingIndicator.startAnimating()
        case .loaded(let currentWeather):
            contentView.isHidden = false
            loadingIndicator.stopAnimating()
            self.city.text = viewModel?.city
            self.temp.text = currentWeather.main.tempDescription()
            self.summary.text = currentWeather.summary()
        case .error:
            break;
        }
    }
}
