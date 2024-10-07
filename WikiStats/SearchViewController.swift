////
////  SearchViewController.swift
////  WikiStats
////
////  Created by Aaron Van Doren on 10/6/24.
////
//
//import UIKit
//
//class SearchViewController: UIViewController {
//    private let searchBar: CustomSearchBar
//    private let tableView: UITableView
//    private var searchResults: [Player] = []
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupViews()
//        setupConstraints()
//    }
//    
//    private func setupViews() {
//        // Initialize and configure searchBar and tableView
//    }
//    
//    private func setupConstraints() {
//        // Set up Auto Layout constraints
//    }
//}
//
//extension SearchViewController: UISearchBarDelegate {
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        // Implement autocomplete logic
//    }
//    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        // Handle search button tap
//    }
//}
//
//
//
//class PlayerStatsViewController: UIViewController {
//    private let playerNameLabel: UILabel
//    private let statisticsTableView: StatisticsTableView
//    private let player: Player
//    
//    init(player: Player) {
//        self.player = player
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupViews()
//        fetchPlayerStatistics()
//    }
//    
//    private func setupViews() {
//        // Initialize and configure views
//    }
//    
//    private func fetchPlayerStatistics() {
//        // Use WikipediaAPIService to fetch and parse statistics
//    }
//}
//
//import Foundation
//import Kanna
//
//class WikipediaAPIService {
//    static func fetchPlayerPage(for playerName: String, completion: @escaping (Result<String, Error>) -> Void) {
//        // Implement Wikipedia API call to fetch player's page HTML
//    }
//}
//
//import Foundation
//import Kanna
//
//class StatisticsParser {
//    static func parseStatistics(from html: String) -> Statistics? {
//        // Parse the HTML using Kanna and extract statistics
//    }
//}
//
//
//
//
//class StatisticsTableView: UITableView {
//    var statistics: Statistics? {
//        didSet {
//            reloadData()
//        }
//    }
//    
//    override init(frame: CGRect, style: UITableView.Style) {
//        super.init(frame: frame, style: style)
//        setupTableView()
//    }
//    
//    private func setupTableView() {
//        // Configure table view appearance and register cells
//    }
//}
//
//extension StatisticsTableView: UITableViewDataSource, UITableViewDelegate {
//    // Implement data source and delegate methods to display statistics
//}
