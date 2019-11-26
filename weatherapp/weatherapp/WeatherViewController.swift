//
//  WeatherViewController.swift
//  weatherapp
//
//  Created by Burney, Moe (AU - Sydney) on 26/11/19.
//  Copyright © 2019 Burney, Moe (AU - Sydney). All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController, UISearchResultsUpdating, UISearchControllerDelegate {

    @IBOutlet weak var contentView: UIView!
    var searchText:String?
    let searchController = UISearchController(searchResultsController: nil)

   // var viewModel: WeatherViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Cities"
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
