//
//  weatherappTests.swift
//  weatherappTests
//
//  Created by Burney, Moe (AU - Sydney) on 26/11/19.
//  Copyright © 2019 Burney, Moe (AU - Sydney). All rights reserved.
//

import XCTest
@testable import weatherapp

class WeatherSearchViewModelTest: XCTestCase, WeatherSearchViewModelDelegate {
    weak private var citiesExpectation: XCTestExpectation?
    private var state: WeatherSearchViewState!
    var delegateCalled = false
    
    func testViewModelCallsDelegateAfterLoadCities() {
        citiesExpectation = expectation(description: "Cities")

        let vm = WeatherSearchViewModel()
        vm.delegate = self
        vm.loadCities()
        
        waitForExpectations(timeout: 100.0, handler: nil)
        XCTAssertTrue(state.isLoaded())
    }
    
    func testViewModelLoadsCities() {
        citiesExpectation = expectation(description: "Cities")

        let vm = WeatherSearchViewModel()
        vm.delegate = self
        vm.loadCities()
        
        waitForExpectations(timeout: 100.0, handler: nil)
        XCTAssertNotNil(state.getCities())
    }
    
    func weatherSearchViewStateDidUpdate(_ viewState: WeatherSearchViewState) {
        delegateCalled = true
        state = viewState
        citiesExpectation?.fulfill()
        citiesExpectation = nil
    }
}

class WeatherDetailViewModelTest: XCTestCase, WeatherDetailViewModelDelegate {
    weak private var weatherExpectation: XCTestExpectation?
    private var state: WeatherDetailViewState!
    var delegateCalled = false
    
    func testViewModelCallsDelegateAfterLoadCities() {
        weatherExpectation = expectation(description: "Weather")

        let vm = WeatherDetailViewModel(city: "Sydney", id: 1)
        vm.delegate = self
        vm.loadWeather()
        
        waitForExpectations(timeout: 100.0, handler: nil)
        XCTAssertTrue(state.isLoaded())
    }
    
    func testViewModelLoadsWeather() {
        weatherExpectation = expectation(description: "Weather")

        let vm = WeatherDetailViewModel(city: "Sydney", id: 1)
        vm.delegate = self
        vm.loadWeather()
        
        waitForExpectations(timeout: 100.0, handler: nil)
        XCTAssertNotNil(state.getWeather())
    }
    
    func weatherDetailViewStateDidUpdate(_ viewState: WeatherDetailViewState) {
        delegateCalled = true
        state = viewState
        weatherExpectation?.fulfill()
        weatherExpectation = nil
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
