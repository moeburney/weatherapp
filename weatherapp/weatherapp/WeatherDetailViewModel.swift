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

    var id:Int?
    var zipCode:String?
    
    private var state: WeatherDetailViewState = .loading {
        didSet {
            delegate?.weatherDetailViewStateDidUpdate(state)
        }
    }

    init(id:Int) {
        self.id = id
    }
    
    init(zipCode:String) {
        self.zipCode = zipCode
    }
    
    func getWeather(for id: Int, completion: @escaping (Result<CurrentLocalWeather,Error>)->()) -> Void {
           let url = "https://api.openweathermap.org/data/2.5/weather?id=\(id)&units=metric&appid=95d190a434083879a6398aafd54d9e73"

           URLSession.shared.dataTask(with: URL(string: url)!) {(data, response, error) in
               do {
                   let weather = try JSONDecoder().decode(CurrentLocalWeather.self, from: data!)
                print(weather)
                print("")
                completion(.success(weather))
               } catch {
                   print("Error")
               }
           }.resume()
    }
    
    func loadWeather() {
        // TODO : self.id shouldn't be optional, use a guard
        getWeather(for: self.id ?? 0) { (results) in
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
