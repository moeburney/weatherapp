//
//  weatherappTests.swift
//  weatherappTests
//
//  Created by Burney, Moe (AU - Sydney) on 26/11/19.
//  Copyright © 2019 Burney, Moe (AU - Sydney). All rights reserved.
//

import XCTest
import CoreLocation
@testable import weatherapp

class WeatherSearchViewModelTest: XCTestCase, WeatherSearchViewModelDelegate {
    private var citiesExpectation: XCTestExpectation!
    private var state: WeatherSearchViewState!
    private var delegateCalled: Bool = false
    
    func testGetNearestCityTo() {
        let vm = WeatherSearchViewModel()
        let coords = CLLocationCoordinate2D(latitude: 44.549999, longitude: 34.283333)
        let city = vm.getNearestCityTo(userLocation: coords,
                            cities: [City(id: 100,
                            name: "Hurzuf",
                            country: "UA",
                            coord: Coord(
                                lat: 44.549999,
                                lon: 34.283333))])
        XCTAssertEqual(city?.id, 100)
    }
    
    func testViewModelCallsDelegateAfterLoadCities() {
        citiesExpectation = expectation(description: "Cities")

        let vm = WeatherSearchViewModel()
        vm.delegate = self
        vm.loadCities()
        
        waitForExpectations(timeout: 100.0)
        XCTAssertTrue(delegateCalled)
    }
    
    func testViewModelLoadsCities() {
        citiesExpectation = expectation(description: "Cities")

        let vm = WeatherSearchViewModel()
        vm.delegate = self
        vm.loadCities()
        
        waitForExpectations(timeout: 100.0)
        XCTAssertNotNil(state.getCities())
        XCTAssertGreaterThan(state.getCities()!.count, 0)
    }
    
    func weatherSearchViewStateDidUpdate(_ viewState: WeatherSearchViewState) {
        state = viewState
        if case .loaded = state {
            delegateCalled = true
            citiesExpectation.fulfill()
        }
    }
}

class WeatherDetailViewModelTest: XCTestCase, WeatherDetailViewModelDelegate {
    private var weatherExpectation: XCTestExpectation!
    private var state: WeatherDetailViewState!
    private var delegateCalled: Bool = false
    
    // TODO: currently tests the real openweather API; should create a mock class instead
    func testViewModelCallsDelegateAfterLoadWeather() {
        weatherExpectation = expectation(description: "Weather")

        let vm = WeatherDetailViewModel(city: "Hurzuf", id: 707860)
        vm.delegate = self
        vm.loadWeather()
        
        waitForExpectations(timeout: 100.0)
        XCTAssertTrue(delegateCalled)
    }
    
    // TODO: currently tests the real openweather API; should create a mock class instead
    func testViewModelLoadsWeather() {
        weatherExpectation = expectation(description: "Weather")

        let vm = WeatherDetailViewModel(city: "Hurzuf", id: 707860)
        vm.delegate = self
        vm.loadWeather()
        
        waitForExpectations(timeout: 100.0)
        XCTAssertNotNil(state.getWeather())
    }
    
    func weatherDetailViewStateDidUpdate(_ viewState: WeatherDetailViewState) {
        state = viewState
        if case .loaded = state {
            delegateCalled = true
            weatherExpectation.fulfill()
        }
    }
}


class weatherappTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTempDescription() {
        let currentWeather = CurrentLocalWeather(weather: [],
                                                 wind: Wind(speed: 2.0, deg: 1),
                                                 name: "Sydney",
                                                 main: Main(temp: 20.7,
                                                            pressure: 1,
                                                            humidity: 2,
                                                            temp_min: 24.3,
                                                            temp_max: 25.6))
        XCTAssertEqual(currentWeather.main.tempDescription(), "21°")
    }
    
    func testWeatherSummary() {
        let currentWeather = CurrentLocalWeather(weather: [Weather(id: 2,
                                                                   main: "something",
                                                                   summary: "cloudy day")],
                                                 wind: Wind(speed: 2.0, deg: 1),
                                                 name: "Sydney",
                                                 main: Main(temp: 20.7,
                                                            pressure: 1,
                                                            humidity: 2,
                                                            temp_min: 24.3,
                                                            temp_max: 25.6))
        XCTAssertEqual(currentWeather.summary(), "cloudy day")
        
    }
    
    func testWeatherSummaryEmpty() {
        let currentWeather = CurrentLocalWeather(weather: [],
                                                 wind: Wind(speed: 2.0, deg: 1),
                                                 name: "Sydney",
                                                 main: Main(temp: 20.7,
                                                            pressure: 1,
                                                            humidity: 2,
                                                            temp_min: 24.3,
                                                            temp_max: 25.6))
        XCTAssertEqual(currentWeather.summary(), "")
        
    }
}
