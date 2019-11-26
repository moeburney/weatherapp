//
//  WeatherSearchViewController.swift
//  weatherapp
//
//  Created by Burney, Moe (AU - Sydney) on 26/11/19.
//  Copyright © 2019 Burney, Moe (AU - Sydney). All rights reserved.
//

import UIKit

fileprivate extension String {
    static let inputPlaceholderText = "Enter city or zip code"
    static let fieldAccessibilityLabel = "Search weather by location"
}

class WeatherSearchViewController: UIViewController, UISearchResultsUpdating, UISearchControllerDelegate {

    @IBOutlet weak var contentView: UIView!
    let searchController = UISearchController(searchResultsController: nil)

   // var viewModel: WeatherViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = String.inputPlaceholderText
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        contentView.addSubview(searchController.searchBar)
    }
    
//    func didPresentSearchController(_ searchController: UISearchController) {
//        searchController.searchBar.becomeFirstResponder()
//    }

    func updateSearchResults(for searchController: UISearchController) {
        // do something
    }
    

}
