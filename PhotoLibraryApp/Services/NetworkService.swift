//
//  NetworkService.swift
//  PhotoLibraryApp
//
//  Created by Ana Dzebniauri on 07.09.25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case unknown(Error)
}

class NetworkService {
    
    static let shared = NetworkService()
    private let baseURL = "https://images-api.nasa.gov"
    private let searchTerms = ["space", "apollo", "mars", "earth", "galaxy", "nebula", "satellite", "astronaut", "moon", "jupiter", "saturn", "hubble", "telescope", "solar", "planet", "comet"]
    private var currentSearchIndex = 0
    
    private init() {}
    
    func fetchNASAImages(completion: @escaping (Result<[PhotoItem], NetworkError>) -> Void) {
        let searchTerm = getNextSearchTerm()
        let urlString = "\(baseURL)/search?q=\(searchTerm)&media_type=image&page_size=25"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.unknown(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let searchResponse = try JSONDecoder().decode(NASASearchResponse.self, from: data)
                let photoItems = searchResponse.collection.items.map { PhotoItem(from: $0) }
                completion(.success(photoItems))
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    private func getNextSearchTerm() -> String {
        let term = searchTerms[currentSearchIndex % searchTerms.count]
        currentSearchIndex += 1
        return term
    }
}
