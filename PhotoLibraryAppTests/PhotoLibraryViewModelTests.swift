//
//  PhotoLibraryAppTests.swift
//  PhotoLibraryAppTests
//
//  Created by Ana Dzebniauri on 07.09.25.
//

import XCTest
@testable import PhotoLibraryApp

// MARK: - Network Service Tests
class NetworkServiceTests: XCTestCase {
    var networkService: NetworkService!
    
    override func setUp() {
        super.setUp()
        networkService = NetworkService.shared
    }
    
    override func tearDown() {
        networkService = nil
        super.tearDown()
    }
    
    func testNetworkServiceSingleton() {
        XCTAssertTrue(NetworkService.shared === NetworkService.shared, "NetworkService should be a singleton")
    }
    
    func testNetworkErrorTypes() {
        let errors: [NetworkError] = [
            .invalidURL,
            .noData,
            .decodingError,
            .unknown(NSError(domain: "Test", code: 0))
        ]
        XCTAssertEqual(errors.count, 4, "All NetworkError types should be available")
    }
    
    func testFetchNASAImagesSuccess() {
        let expectation = XCTestExpectation(description: "Fetch NASA images")
        var result: Result<[PhotoItem], NetworkError>?
        
        networkService.fetchNASAImages { fetchResult in
            result = fetchResult
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
        
        switch result {
        case .success(let photos):
            XCTAssertGreaterThan(photos.count, 0, "Should fetch at least one photo")
            
            let firstPhoto = photos.first!
            XCTAssertFalse(firstPhoto.imageURL.isEmpty, "Image URL should not be empty")
            XCTAssertNotNil(firstPhoto.title, "Title should not be nil")
            
        case .failure(let error):
            XCTFail("Expected success but got error: \(error)")
            
        case .none:
            XCTFail("Result should not be nil")
        }
    }
    
    func testConcurrentNetworkRequests() {
        let expectation = XCTestExpectation(description: "Concurrent requests")
        expectation.expectedFulfillmentCount = 5
        
        var successCount = 0
        let queue = DispatchQueue.global(qos: .userInitiated)
        
        for _ in 0..<5 {
            queue.async {
                self.networkService.fetchNASAImages { result in
                    if case .success = result {
                        successCount += 1
                    }
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 30.0)
        XCTAssertGreaterThan(successCount, 2, "At least some concurrent requests should succeed")
    }
}

// MARK: - NASA Image Model Tests
class NASAImageModelTests: XCTestCase {
    
    func testNASAImageDataDecoding() {
        let json = """
        {
            "title": "Test Space Image",
            "description": "A beautiful space image",
            "date_created": "2023-01-01T12:00:00Z",
            "center": "JPL"
        }
        """
        
        let data = json.data(using: .utf8)!
        
        do {
            let nasaImageData = try JSONDecoder().decode(NASAImageData.self, from: data)
            
            XCTAssertEqual(nasaImageData.title, "Test Space Image")
            XCTAssertEqual(nasaImageData.description, "A beautiful space image")
            XCTAssertEqual(nasaImageData.dateCreated, "2023-01-01T12:00:00Z")
            XCTAssertEqual(nasaImageData.center, "JPL")
        } catch {
            XCTFail("Failed to decode NASAImageData: \(error)")
        }
    }
    
    func testPhotoItemInitialization() {
        let nasaImageData = NASAImageData(
            title: "Test Photo",
            description: "Test Description",
            dateCreated: "2023-01-01T12:00:00Z",
            center: "NASA"
        )
        
        let nasaImageLink = NASAImageLink(
            href: "https://example.com/image.jpg",
            rel: "preview",
            render: "image"
        )
        
        let nasaItem = NASAItem(
            data: [nasaImageData],
            links: [nasaImageLink]
        )
        
        let photoItem = PhotoItem(from: nasaItem)
        
        XCTAssertEqual(photoItem.title, "Test Photo")
        XCTAssertEqual(photoItem.description, "Test Description")
        XCTAssertEqual(photoItem.imageURL, "https://example.com/image.jpg")
        XCTAssertEqual(photoItem.dateCreated, "2023-01-01T12:00:00Z")
        XCTAssertEqual(photoItem.photographer, "NASA")
    }
    
    func testPhotoItemWithMissingData() {
        let nasaItem = NASAItem(data: [], links: nil)
        
        let photoItem = PhotoItem(from: nasaItem)
        
        XCTAssertNil(photoItem.title)
        XCTAssertNil(photoItem.description)
        XCTAssertEqual(photoItem.imageURL, "")
        XCTAssertNil(photoItem.dateCreated)
        XCTAssertNil(photoItem.photographer)
    }
    
    func testMalformedJSONHandling() {
        let malformedJSON = """
        {
            "collection": {
                "items": [
                    {
                        "data": [
                            {
                                "title": "Test",
                                "invalid_field": 
                            }
                        ]
                    }
                ]
            }
        """
        
        guard let data = malformedJSON.data(using: .utf8) else {
            XCTFail("Could not create data from malformed JSON")
            return
        }
        
        XCTAssertThrowsError(try JSONDecoder().decode(NASASearchResponse.self, from: data)) { error in
            XCTAssertTrue(error is DecodingError, "Should throw DecodingError for malformed JSON")
        }
    }
}

// MARK: - UI Component Tests
class UIComponentTests: XCTestCase {
    
    func testPhotoCellInitialization() {
        let photoCell = PhotoCell(frame: CGRect(x: 0, y: 0, width: 200, height: 320))
        
        XCTAssertNotNil(photoCell, "PhotoCell should initialize")
        XCTAssertEqual(photoCell.frame.width, 200, "Width should be set correctly")
        XCTAssertEqual(photoCell.frame.height, 320, "Height should be set correctly")
    }
    
    func testPhotoCellReuseIdentifier() {
        XCTAssertEqual(PhotoCell.reuseID, "PhotoCell", "Reuse identifier should be correct")
    }
    
    func testNASAPhotosViewControllerInitialization() {
        let viewController = NASAPhotosViewController()
        _ = viewController.view
        
        XCTAssertNotNil(viewController.view, "View should be loaded")
        XCTAssertEqual(viewController.title, "NASA Photos", "Title should be set correctly")
    }
    
    func testCollectionViewSetup() {
        let viewController = NASAPhotosViewController()
        _ = viewController.view
        viewController.viewDidLoad()
        
        let hasCollectionView = viewController.view.subviews.contains { $0 is UICollectionView }
        
        XCTAssertTrue(hasCollectionView, "Collection view should be added to view")
        
        if let collectionView = viewController.view.subviews.first(where: { $0 is UICollectionView }) as? UICollectionView {
            XCTAssertNotNil(collectionView.dataSource, "Collection view should have data source")
            XCTAssertNotNil(collectionView.delegate, "Collection view should have delegate")
            XCTAssertNotNil(collectionView.refreshControl, "Collection view should have refresh control")
        }
    }
}

// MARK: - Performance Tests
class PerformanceTests: XCTestCase {
    
    func testPhotoItemCreationPerformance() {
        let nasaItems = createMockNASAItems(count: 1000)
        
        measure {
            let photoItems = nasaItems.map { PhotoItem(from: $0) }
            XCTAssertEqual(photoItems.count, 1000)
        }
    }
    
    func testJSONDecodingPerformance() {
        let largeJSON = createLargeJSONResponse(itemCount: 100)
        guard let data = largeJSON.data(using: .utf8) else {
            XCTFail("Could not create JSON data")
            return
        }
        
        measure {
            do {
                let response = try JSONDecoder().decode(NASASearchResponse.self, from: data)
                XCTAssertEqual(response.collection.items.count, 100)
            } catch {
                XCTFail("JSON decoding failed: \(error)")
            }
        }
    }
    
    // MARK: - Helper Methods
    private func createMockNASAItems(count: Int) -> [NASAItem] {
        return (0..<count).map { index in
            let imageData = NASAImageData(
                title: "Performance Test Photo \(index)",
                description: "Description \(index)",
                dateCreated: "2023-01-01T12:00:00Z",
                center: "NASA"
            )
            
            let imageLink = NASAImageLink(
                href: "https://example.com/image\(index).jpg",
                rel: "preview",
                render: "image"
            )
            
            return NASAItem(data: [imageData], links: [imageLink])
        }
    }
    
    private func createLargeJSONResponse(itemCount: Int) -> String {
        let items = (0..<itemCount).map { index in
            """
            {
                "data": [
                    {
                        "title": "Performance Test Photo \(index)",
                        "description": "Description \(index)",
                        "date_created": "2023-01-01T12:00:00Z",
                        "center": "NASA"
                    }
                ],
                "links": [
                    {
                        "href": "https://example.com/image\(index).jpg",
                        "rel": "preview",
                        "render": "image"
                    }
                ]
            }
            """
        }.joined(separator: ",")
        
        return """
        {
            "collection": {
                "items": [\(items)]
            }
        }
        """
    }
}
