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
}


class WeatherDetailViewController: UIViewController {
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var summary: UILabel!
    var id:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWeather()

    }
    
    func getWeather(completion: @escaping (Result<CurrentLocalWeather,Error>)->()) -> Void {
           let url = "https://api.openweathermap.org/data/2.5/weather?id=2172797&units=metric&appid=95d190a434083879a6398aafd54d9e73"
           let objurl = URL(string: url)

           URLSession.shared.dataTask(with: objurl!) {(data, response, error) in
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
        getWeather { (results) in
            DispatchQueue.main.async {
                switch results {
                case .success(let currentWeather):
                    self.city.text = "Brisbane"
                    self.temp.text = currentWeather.main.temp.description
                    self.summary.text = currentWeather.weather[0].summary
                case .failure(_):
                    // show some error
                    break;
                }
            }
        }
    }
    
}
