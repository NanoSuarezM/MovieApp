//
//  MovieListViewController.swift
//  MovieApp
//
//  Created by Nano Suarez on 14/12/2018.
//  Copyright © 2018 nano. All rights reserved.
//

import UIKit

class MovieListViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    lazy var movieListViewModel: MovieListViewModel = {
        return MovieListViewModel()
    }()
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredMovies = [MovieCellViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.prefetchDataSource = self
        self.setUpSearchController()
        self.setupBindings()
        self.movieListViewModel.initFetch()
    }
    
    func setUpSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Movies"
        navigationItem.searchController = searchController
        definesPresentationContext = true

    }
    
    func setupBindings() {
        self.movieListViewModel.reloadCollectionViewClosure = { [weak self] (withIndexpathToReload) in
            DispatchQueue.main.async {
                guard let newIndexPathsToReload = withIndexpathToReload else {
                    self?.activityIndicator?.stopAnimating()
                    self?.collectionView.isHidden = false
                    self?.collectionView.reloadData()
                    return
                }
            
                let indexPathsToReload = self?.visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
                self?.collectionView.reloadItems(at: indexPathsToReload!)
            }
        }
        
        self.movieListViewModel.updateLoadingStatus = { [weak self] () in
            DispatchQueue.main.async {
                let isLoading = self?.movieListViewModel.isLoading ?? false
                
                if isLoading {
                    self?.activityIndicator?.startAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.collectionView.alpha = 0.0
                    })
                }else {
                    self?.activityIndicator?.stopAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.collectionView.alpha = 1.0
                    })
                }
            }
        }
        
        self.movieListViewModel.showAlertMessage = { [weak self] () in
            DispatchQueue.main.async {
                if let message = self?.movieListViewModel.alertMessage {
                    self?.collectionView.setMessage(message: message)
                }
            }
        }
    }
    
    // MARK: - Private methods SearchController
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredMovies = self.movieListViewModel.cellViewModels.filter({( movie : MovieCellViewModel) -> Bool in
            return movie.name.lowercased().contains(searchText.lowercased())
        })
        
        if filteredMovies.isEmpty {
            self.collectionView.setMessage(message: "The text does not match with any movie, try again!")
        } else {
            self.collectionView.restore()
        }
        
        self.collectionView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}

//MARK: - UICollectionViewDataSource

extension MovieListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredMovies.count
        }
        return self.movieListViewModel.totalCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! MovieCollectionViewCell
        
        let movie: MovieCellViewModel
        
        if isFiltering() {
            movie = filteredMovies[indexPath.row]
        } else {
            if isLoadingCell(for: indexPath) {
                cell.indicatorView?.startAnimating()
                return cell
            } else {
                movie = self.movieListViewModel.cellViewModels[indexPath.row]
                cell.indicatorView?.stopAnimating()
            }
        }
        let baseUrl = "https://image.tmdb.org/t/p/w300/"
        let posterPath = movie.image_url
        let imageUrlString = baseUrl + posterPath
        
        if !posterPath.isEmpty {
            ImageLoader.image(for: imageUrlString) { image in
                if let image = image  {
                    cell.movieImageView.image = image
                }
            }
        }
        
        return cell
    }
}

extension MovieListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.movieListViewModel.userPressed(at: indexPath)
        performSegue(withIdentifier: "segueIdentifier", sender: indexPath)
    }
    
}

extension MovieListViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let movie: MovieCellViewModel
        let indexPath = sender as! IndexPath
        
        if isFiltering() {
            movie = self.filteredMovies[indexPath.row]
        } else {
            movie = self.movieListViewModel.selectedMovie!
        }
        if let vc = segue.destination as? MovieDetailViewController {
            vc.movie = movie
        }
    }
}

//MARK: - CollectionView Little Helpers

extension UICollectionView {
    func setMessage(message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.sizeToFit()
        messageLabel.isHidden = false
        
        self.backgroundView = messageLabel;
    }
    
    func restore() {
        self.backgroundView = nil
    }
}

extension MovieListViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            self.movieListViewModel.initFetch()
        }
    }
}

private extension MovieListViewController {
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= self.movieListViewModel.currentCount
    }
    
    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = self.collectionView.indexPathsForVisibleItems
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
}

extension MovieListViewController: UISearchResultsUpdating, UISearchBarDelegate {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        if !(searchController.searchBar.text?.isEmpty)! {
            self.filterContentForSearchText(searchController.searchBar.text!)
        } else {
            self.collectionView.restore()
            self.collectionView.reloadData()
        }
    }
}

