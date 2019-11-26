//
//  APIClient.swift
//  weatherapp
//
//  Created by Burney, Moe (AU - Sydney) on 26/11/19.
//  Copyright © 2019 Burney, Moe (AU - Sydney). All rights reserved.
//

import Foundation

class APIClient {
    static let standard = APIClient()

    func getWeather(for id: Int, completion: @escaping (Result<CurrentLocalWeather,Error>)->()) -> Void {
           let url = "https://api.openweathermap.org/data/2.5/weather?id=\(id)&units=metric&appid=95d190a434083879a6398aafd54d9e73"

           URLSession.shared.dataTask(with: URL(string: url)!) {(data, response, error) in
               do {
                   let weather = try JSONDecoder().decode(CurrentLocalWeather.self, from: data!)
                print(weather)
                print("")
                completion(.success(weather))
               } catch {
                completion(.failure(error))
               }
           }.resume()
    }
    
    
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
}
