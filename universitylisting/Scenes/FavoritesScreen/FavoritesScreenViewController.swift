//
//  FavoritesScreenViewController.swift
//  universitylisting
//
//  Created by Can Kalender on 22.02.2025.
//

import UIKit

final class FavoritesScreenViewController: UIViewController {
    private let viewModel: FavoritesScreenViewModel
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.register(UINib(nibName: "CityTableViewCell", bundle: nil), 
                      forCellReuseIdentifier: "CityTableViewCell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "favorites_empty_screen".localized
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    init(viewModel: FavoritesScreenViewModel = FavoritesScreenViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = FavoritesScreenViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadFavorites()
    }
    
    private func setupUI() {
        title = "favorites".localized
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func updateEmptyState() {
        emptyStateLabel.isHidden = !viewModel.cellViewModels.isEmpty
        tableView.isHidden = viewModel.cellViewModels.isEmpty
    }
}

extension FavoritesScreenViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "CityTableViewCell",
            for: indexPath
        ) as! CityTableViewCell
        
        cell.configure(with: viewModel.cellViewModels[indexPath.row])
        cell.delegate = self
        return cell
    }
}

extension FavoritesScreenViewController: CityTableViewCellDelegate {
    func didTapExpand(for province: String) {
        // Not needed for favorites
    }
    
    func didTapUniversityExpand(for university: University) {
        viewModel.toggleUniversityExpansion(for: university)
    }
    
    func didTapFavorite(for university: University) {
        viewModel.toggleFavorite(for: university)
    }
    
    func didTapWebsite(_ urlString: String, universityName: String) {
        let webViewController = UniversityWebViewController(
            urlString: urlString,
            universityName: universityName
        )
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    func didTapPhone(_ phoneNumber: String) {
        guard let url = URL(string: "tel://\(phoneNumber)") else { return }
        UIApplication.shared.open(url)
    }
}

extension FavoritesScreenViewController: FavoritesScreenViewModelDelegate {
    func favoritesDidUpdate() {
        tableView.reloadData()
        updateEmptyState()
    }
}
