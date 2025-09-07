//
//  NASAImage.swift
//  PhotoLibraryApp
//
//  Created by Ana Dzebniauri on 07.09.25.
//

import Foundation

// MARK: - NASA API Response Models
struct NASASearchResponse: Codable {
    let collection: NASACollection
}

struct NASACollection: Codable {
    let items: [NASAItem]
}

struct NASAItem: Codable {
    let data: [NASAImageData]
    let links: [NASAImageLink]?
}

struct NASAImageData: Codable {
    let title: String
    let description: String?
    let dateCreated: String?
    let center: String?
    
    enum CodingKeys: String, CodingKey {
        case title, description, center
        case dateCreated = "date_created"
    }
}

struct NASAImageLink: Codable {
    let href: String
    let rel: String?
    let render: String?
}

// MARK: - Simplified Photo Model for UI
struct PhotoItem {
    let title: String?
    let description: String?
    let imageURL: String
    let dateCreated: String?
    let photographer: String?
    
    init(from nasaItem: NASAItem) {
        self.title = nasaItem.data.first?.title
        self.description = nasaItem.data.first?.description
        self.imageURL = nasaItem.links?.first?.href ?? ""
        self.dateCreated = nasaItem.data.first?.dateCreated
        self.photographer = nasaItem.data.first?.center
    }
}
