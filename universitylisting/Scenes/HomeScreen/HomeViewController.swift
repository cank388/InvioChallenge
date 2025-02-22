//
//  HomeViewController.swift
//  universitylisting
//
//  Created by Can Kalender on 20.02.2025.
//

import UIKit
import SafariServices

final class HomeViewController: UIViewController, UISearchBarDelegate {
    
    var viewModel: HomeViewModelProtocol
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.placeholder = "Üniversite ara..."
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.delegate = self
        controller.searchBar.showsCancelButton = true
        controller.hidesNavigationBarDuringPresentation = false
        return controller
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        table.delegate = self
        table.separatorStyle = .none
        table.dataSource = self
        return table
    }()
    
    init(_ viewModel: HomeViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = HomeViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.viewModel.delegate = self
        tableView.register(UINib(nibName: "CityTableViewCell", bundle: nil), forCellReuseIdentifier: "CityTableViewCell")
        tableView.register(LoadingCell.self, forCellReuseIdentifier: LoadingCell.identifier)
    }
    
    private func setupUI() {
        title = "Üniversiteler"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let favoritesButton = UIBarButtonItem(
            image: UIImage(systemName: "heart"),
            style: .plain,
            target: self,
            action: #selector(favoritesButtonTapped)
        )
        navigationItem.rightBarButtonItem = favoritesButton
    }
    
    @objc private func favoritesButtonTapped() {
        // TODO: Favoriler sayfasına yönlendirme
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = viewModel.cellViewModels[indexPath.row]
        
        switch cellViewModel {
        case let model as CityTableViewCellModel:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "CityTableViewCell",
                for: indexPath
            ) as! CityTableViewCell
            cell.delegate = self
            cell.configure(with: model)
            return cell
            
        case _ as LoadingCellViewModel:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: LoadingCell.identifier,
                for: indexPath
            ) as! LoadingCell
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.cellViewModels.count - 1 {
            viewModel.loadNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
}

// MARK: - UISearchBarDelegate
extension HomeViewController {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Arama metnini temizle butonunu göster/gizle
        searchBar.setShowsCancelButton(!searchText.isEmpty, animated: true)
        
        // Add delay before search
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSearch), object: nil)
        perform(#selector(performSearch), with: nil, afterDelay: 0.5)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        viewModel.searchUniversities(with: "")
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }
    
    @objc private func performSearch() {
        guard let searchText = searchController.searchBar.text else { return }
        viewModel.searchUniversities(with: searchText)
    }
}

// MARK: - HomeViewModelDelegate
extension HomeViewController: HomeViewModelDelegate {
    func universitiesDidUpdate() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func searchResultsDidUpdate() {
        tableView.reloadData()
    }
    
    func showLoading(_ show: Bool) {
        if show {
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.startAnimating()
            spinner.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
            tableView.tableFooterView = spinner
        } else {
            tableView.tableFooterView = nil
        }
    }
}

// MARK: - CityTableViewCellDelegate
extension HomeViewController: CityTableViewCellDelegate {
    func didTapExpand(for province: String) {
        viewModel.toggleExpansion(for: province)
        tableView.reloadData()
    }
    
    func didTapUniversityExpand(for university: University) {
        viewModel.toggleUniversityExpansion(for: university)
        tableView.reloadData()
    }
    
    func didTapFavorite(for university: University) {
        viewModel.toggleFavorite(for: university)
        tableView.reloadData()
    }
    
    func didTapWebsite(_ urlString: String, universityName: String) {
        let webViewController = UniversityWebViewController(urlString: urlString, universityName: universityName)
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    func didTapPhone(_ phoneNumber: String) {
        guard let url = URL(string: "tel://\(phoneNumber)") else { return }
        UIApplication.shared.open(url)
    }
}

// LoadingCell'i UniversityCell'den önce ekleyelim
class LoadingCell: UITableViewCell {
    static let identifier = "LoadingCell"
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(spinner)
        
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        spinner.startAnimating()
    }
}

class LoadingCellViewModel {
    init() {}
    
}
