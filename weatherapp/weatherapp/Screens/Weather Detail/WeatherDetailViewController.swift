//
//  WeatherDetailViewController.swift
//  weatherapp
//
//  Created by Burney, Moe (AU - Sydney) on 26/11/19.
//  Copyright © 2019 Burney, Moe (AU - Sydney). All rights reserved.
//

import UIKit

// Shows current weather info for a particular open weather ID (city) or zip code
final class WeatherDetailViewController: UIViewController {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var summary: UILabel!
    
    var id:Int?
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
        // loading weather info from network, show a spinner
        case .loading:
            DispatchQueue.main.async { [weak self] in
                self?.contentView.isHidden = true
                self?.loadingIndicator.startAnimating()
            }
        // weather info has been loaded
        case .loaded(let currentWeather):
            DispatchQueue.main.async { [weak self] in
                self?.contentView.isHidden = false
                self?.loadingIndicator.stopAnimating()
                self?.city.text = self?.viewModel?.city ?? self?.viewModel?.zipCode
                self?.temp.text = currentWeather.main.tempDescription()
                self?.summary.text = currentWeather.summary()
            }
        case .error:
            break;
        }
    }
}
