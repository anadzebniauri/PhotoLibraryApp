//
//  NASAPhotosViewController.swift
//  PhotoLibraryApp
//
//  Created by Ana Dzebniauri on 07.09.25.
//

import UIKit

class NASAPhotosViewController: UIViewController {
    
    // MARK: - Properties
    private var collectionView: UICollectionView!
    private var photos: [PhotoItem] = []
    private var refreshControl: UIRefreshControl!
    private var isLoading = false
    private var currentPage = 1
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureCollectionView()
        loadNASAPhotos(isRefresh: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Configuration
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "NASA Photos"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func configureCollectionView() {
        setupCollectionView()
        setupRefreshControl()
        setupCollectionViewConstraints()
    }
    
    private func setupCollectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return layout
    }
    
    private func setupCollectionView() {
        let layout = setupCollectionViewLayout()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reuseID)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
    }
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshPhotos), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func setupCollectionViewConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadNASAPhotos(isRefresh: Bool = true) {
        guard !isLoading else { return }
        
        isLoading = true
        
        if isRefresh {
            currentPage = 1
        }
        
        NetworkService.shared.fetchNASAImages { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let photoItems):
                    if isRefresh {
                        self?.photos = photoItems
                        self?.refreshControl.endRefreshing()
                    } else {
                        self?.photos.append(contentsOf: photoItems)
                    }
                    self?.collectionView.reloadData()
                    self?.currentPage += 1
                case .failure(let error):
                    if isRefresh {
                        self?.refreshControl.endRefreshing()
                    }
                    self?.handleNetworkError(error)
                }
            }
        }
    }
    
    private func loadMorePhotosIfNeeded() {
        loadNASAPhotos(isRefresh: false)
    }
    
    private func handleNetworkError(_ error: NetworkError) {
        let alert = UIAlertController(title: "Error Loading Photos",
                                    message: "Unable to load NASA photos. Please try again.", 
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc func refreshPhotos() {
        loadNASAPhotos(isRefresh: true)
    }
}

// MARK: - UICollectionViewDataSource
extension NASAPhotosViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseID, for: indexPath) as! PhotoCell
        cell.set(photoItem: photos[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension NASAPhotosViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.bounds.width - 20
        let height: CGFloat = 320
        return CGSize(width: width, height: height)
    }
}

// MARK: - UICollectionViewDelegate
extension NASAPhotosViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        _ = photos[indexPath.item]
        // TODO: Present detailed view of the selected photo
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height * 1.5 && !isLoading && photos.count > 0 {
            loadMorePhotosIfNeeded()
        }
    }
}
