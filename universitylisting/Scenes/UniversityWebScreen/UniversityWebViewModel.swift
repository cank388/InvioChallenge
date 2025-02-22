//
//  UniversityWebViewModel.swift
//  universitylisting
//
//  Created by Can Kalender on 22.02.2025.
//

import Foundation

protocol UniversityWebViewModelDelegate: AnyObject {
    func showLoading(_ show: Bool)
    func showError(_ message: String)
    func loadURL(_ url: URL)
}

protocol UniversityWebViewModelProtocol {
    var delegate: UniversityWebViewModelDelegate? { get set }
    func loadWebsite()
}

final class UniversityWebViewModel: UniversityWebViewModelProtocol {
    
    weak var delegate: UniversityWebViewModelDelegate?
    private let urlString: String
    
    init(urlString: String) {
        self.urlString = urlString
    }
    
    func loadWebsite() {
        delegate?.showLoading(true)
        
        var urlStringWithProtocol = urlString
        if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
            urlStringWithProtocol = "https://" + urlString
        }
        
        guard let url = URL(string: urlStringWithProtocol) else {
            delegate?.showLoading(false)
            delegate?.showError("Geçersiz website adresi")
            return
        }
        
        delegate?.loadURL(url)
    }
}
