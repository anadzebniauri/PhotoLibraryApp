//
//  PhotoCell.swift
//  PhotoLibraryApp
//
//  Created by Ana Dzebniauri on 07.09.25.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    static let reuseID = "PhotoCell"
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let dateLabel = UILabel()
    private let containerView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
        authorLabel.text = nil
        dateLabel.text = nil
    }
    
    func set(photoItem: PhotoItem) {
        titleLabel.text = photoItem.title ?? "Untitled"
        authorLabel.text = photoItem.photographer ?? "NASA"
        dateLabel.text = formatDate(photoItem.dateCreated)
        loadImage(from: photoItem.imageURL)
    }
    
    private func formatDate(_ dateString: String?) -> String {
        guard let dateString = dateString else { return "" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
        
        return dateString.prefix(10).replacingOccurrences(of: "-", with: "/")
    }
    
    private func loadImage(from urlString: String) {
        // Reset image first
        imageView.image = nil
        imageView.backgroundColor = .systemGray5
        
        guard let url = URL(string: urlString) else { 
            print("Invalid URL: \(urlString)")
            return 
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Image loading error: \(error)")
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else { 
                print("Failed to create image from data")
                return 
            }
            
            DispatchQueue.main.async {
                self?.imageView.image = image
                self?.imageView.backgroundColor = .clear
            }
        }.resume()
    }
    
    private func configure() {
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.shadowColor = UIColor.label.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
        contentView.layer.shadowOpacity = 0.1
        
        contentView.addSubviews(imageView, containerView)
        containerView.addSubviews(titleLabel, authorLabel, dateLabel)
        
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.contentMode = .scaleAspectFill
        
        containerView.backgroundColor = .systemBackground
        
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2
        
        authorLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        authorLabel.textColor = .secondaryLabel
        authorLabel.numberOfLines = 1
        
        dateLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        dateLabel.textColor = .tertiaryLabel
        dateLabel.numberOfLines = 1
    }
    
    private func setupConstraints() {
        let padding: CGFloat = 12
        let labelSpacing: CGFloat = 6
        
        NSLayoutConstraint.activate([
            // Image view constraints
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            
            // Container view for text
            containerView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: padding),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
            
            // Text labels
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: labelSpacing),
            authorLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            authorLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: labelSpacing),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            dateLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor)
        ])
    }
}

extension UIView {
    func addSubviews(_ views: UIView...) {
        for view in views {
            addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
    }
}
