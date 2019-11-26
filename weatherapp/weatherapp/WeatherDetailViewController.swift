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
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
}

struct Wind: Codable {
    let speed: Double
    let deg: Int
}


class WeatherDetailViewController: UIViewController {
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var summary: UILabel!
    var id:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getWeather { (weather, err) in
            // do something
        }
    }
    
    func getWeather(completion: @escaping (_ weather: CurrentLocalWeather?, _ error: Error?) -> Void) {
           let url = "https://samples.openweathermap.org/data/2.5/weather?id=2172797&appid=b6907d289e10d714a6e88b30761fae22"
           let objurl = URL(string: url)

           URLSession.shared.dataTask(with: objurl!) {(data, response, error) in
               do {
                   let weather = try JSONDecoder().decode(CurrentLocalWeather.self, from: data!)
                print(weather)
                print("")

               } catch {
                   print("Error")
               }

           }.resume()
    }
    
}
