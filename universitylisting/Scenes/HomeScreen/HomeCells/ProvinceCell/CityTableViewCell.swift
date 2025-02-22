//
//  CityTableViewCell.swift
//  universitylisting
//
//  Created by Can Kalender on 21.02.2025.
//

import UIKit

class CityTableViewCell: UITableViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let titleStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let expandImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton()
        button.tintColor = .red
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        return button
    }()
    
    private let detailsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    weak var delegate: CityTableViewCellDelegate?
    private var model: CityTableViewCellModel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupGestures()
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        contentView.addSubview(containerView)
        containerView.addSubview(mainStackView)
        
        titleStackView.addArrangedSubview(expandImageView)
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(favoriteButton)
        
        mainStackView.addArrangedSubview(titleStackView)
        mainStackView.addArrangedSubview(detailsStackView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            mainStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            mainStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            mainStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            mainStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            expandImageView.widthAnchor.constraint(equalToConstant: 20),
            expandImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
    }
    
    func configure(with model: CityTableViewCellModel) {
        self.model = model
        
        switch model.type {
        case .province(let name, let isExpanded, let hasUniversities):
            setupAsProvince(name: name, isExpanded: isExpanded, hasUniversities: hasUniversities)
        case .university(let university, let isFavorite, let isExpanded):
            setupAsUniversity(university: university, isFavorite: isFavorite, isExpanded: isExpanded)
        }
    }
    
    private func setupAsProvince(name: String, isExpanded: Bool, hasUniversities: Bool) {
        if let indentationView = titleStackView.arrangedSubviews.first(where: {
            !($0 is UIImageView) && !($0 is UILabel) && !($0 is UIButton)
        }) {
            titleStackView.removeArrangedSubview(indentationView)
            indentationView.removeFromSuperview()
        }

        expandImageView.tintColor = .systemBlue
        expandImageView.isHidden = hasUniversities
        expandImageView.image = UIImage(systemName: isExpanded ? "minus" : "plus")
        
        titleLabel.text = name
        favoriteButton.isHidden = true
        detailsStackView.isHidden = true
    }
    
    private func setupAsUniversity(university: University, isFavorite: Bool, isExpanded: Bool) {
        let indentationView = UIView()
        indentationView.translatesAutoresizingMaskIntoConstraints = false
        indentationView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        titleStackView.insertArrangedSubview(indentationView, at: 0)
        
        expandImageView.tintColor = .black
        expandImageView.isHidden = false
        expandImageView.image = UIImage(systemName: isExpanded ? "minus" : "plus")
        
        if let searchText = model?.searchText, !searchText.isEmpty,
           let universityName = university.name {
            titleLabel.attributedText = highlightText(in: universityName, searchText: searchText)
        } else {
            titleLabel.text = university.name
        }
        
        favoriteButton.isHidden = false
        favoriteButton.setImage(UIImage(systemName: isFavorite ? "heart.fill" : "heart"), for: .normal)
        
        if isExpanded {
            detailsStackView.isHidden = false
            setupUniversityDetails(university)
        } else {
            detailsStackView.isHidden = true
        }
    }
    
    private func highlightText(in text: String, searchText: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        let textLowercased = text.lowercased()
        let searchTextLowercased = searchText.lowercased()
        
        var searchRange = NSRange(location: 0, length: textLowercased.count)
        while searchRange.location != NSNotFound {
            let range = (textLowercased as NSString).range(of: searchTextLowercased, options: [], range: searchRange)
            if range.location != NSNotFound {
                attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 16), range: range)
                searchRange.location = range.location + range.length
                searchRange.length = textLowercased.count - searchRange.location
            } else {
                break
            }
        }
        
        return attributedString
    }
    
    private func setupUniversityDetails(_ university: University) {
        detailsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Tappable label for phone
        if let phone = university.phone, !phone.isEmpty {
            let phoneLabel = createTappableLabel(text: "phone: \(phone)", type: .phone)
            detailsStackView.addArrangedSubview(phoneLabel)
        }
        
        // Tappable label for website
        if let website = university.website, !website.isEmpty {
            let websiteLabel = createTappableLabel(text: "website: \(website)", type: .website)
            detailsStackView.addArrangedSubview(websiteLabel)
        }
        
        let otherDetails: [(String, String?)] = [
            ("fax", university.fax),
            ("address", university.adress),
            ("rector", university.rector)
        ]
        
        for (title, value) in otherDetails {
            if let value = value, !value.isEmpty {
                let label = UILabel()
                label.text = "\(title): \(value)"
                label.font = .systemFont(ofSize: 14)
                label.numberOfLines = 0
                detailsStackView.addArrangedSubview(label)
            }
        }
    }
    
    private enum TappableLabelType {
        case website
        case phone
    }
    
    private func createTappableLabel(text: String, type: TappableLabelType) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textColor = .systemBlue
        label.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTappableLabel(_:)))
        label.addGestureRecognizer(tapGesture)
        
        // Webview is 1, phone is 2
        label.tag = type == .website ? 1 : 2
        
        return label
    }
    
    @objc private func handleTappableLabel(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel,
              case .university(let university, _, _) = model?.type else { return }
        
        if label.tag == 1 { // Website
            if let website = university.website {
                delegate?.didTapWebsite(website, universityName: university.name ?? "")
            }
        } else if label.tag == 2 { // Phone
            if let phone = university.phone {
                delegate?.didTapPhone(phone)
            }
        }
    }
    
    @objc private func cellTapped() {
        guard let model = model else { return }
        
        switch model.type {
        case .province(let name, _, _):
            delegate?.didTapExpand(for: name)
        case .university(let university, _, _):
            delegate?.didTapUniversityExpand(for: university)
        }
    }
    
    @objc private func favoriteTapped() {
        guard case .university(let university, _, _) = model?.type else { return }
        delegate?.didTapFavorite(for: university)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        model = nil
        titleLabel.text = nil
        expandImageView.image = nil
        favoriteButton.setImage(nil, for: .normal)
        detailsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        detailsStackView.isHidden = true
        
        if let indentationView = titleStackView.arrangedSubviews.first(where: {
            !($0 is UIImageView) && !($0 is UILabel) && !($0 is UIButton)
        }) {
            titleStackView.removeArrangedSubview(indentationView)
            indentationView.removeFromSuperview()
        }
    }
}
