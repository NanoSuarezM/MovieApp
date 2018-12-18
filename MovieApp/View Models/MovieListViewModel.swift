//
//  MovieListViewModel.swift
//  MovieApp
//
//  Created by Nano Suarez on 14/12/2018.
//  Copyright © 2018 nano. All rights reserved.
//

import Foundation

final class MovieListViewModel {
    
    let apiService: APIServiceProtocol
    
    var movies: [Movie] = [Movie]()
    var selectedMovie: MovieCellViewModel?
    private var currentPage = 1
    private var total = 0
    private var indexPathsToReload: [IndexPath]?
    
    var cellViewModels: [MovieCellViewModel] = [MovieCellViewModel]() {
        didSet {
            self.reloadCollectionViewClosure?(self.indexPathsToReload)
        }
    }
    
    var currentCount: Int {
        return movies.count
    }
    
    var totalCount: Int {
        return total
    }
    
    var alertMessage: String? {
        didSet {
            self.showAlertMessage?()
        }
    }
    
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatus?()
        }
    }
    
    var numberOfCells: Int {
        return self.cellViewModels.count
    }
    
    var reloadCollectionViewClosure: ((_ withIndexpathToReload: [IndexPath]?)->())?
    var updateLoadingStatus: (()->())?
    var showAlertMessage: (()->())?
    
    
    //MARK: - Initializers
    
    init() {
        self.apiService = APIService()
    }
    
    // I use this init for testing.
    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }
    
    func initFetch() {
        self.isLoading = true
        self.apiService.fetchMovies(page: currentPage) { [weak self] (response, error) in
            
            self?.isLoading = false
            if let movies = response {
                self?.currentPage += 1
                self?.total = movies.totalResults!
                self?.processMovies(movies: movies)
            } else {
                if let error = error {
                    self?.alertMessage = error.localizedDescription
                    self?.cellViewModels.removeAll()
                }
            }
        }
    }
    
    private func calculateIndexPathsToReload(from newMovies: [Movie]) -> [IndexPath] {
        let startIndex = self.movies.count - newMovies.count
        let endIndex = startIndex + newMovies.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }

    
    func processMovies(movies: Movies) {
        self.movies.append(contentsOf: movies.movies)
        // create cell view model for each movie
        var movieCellViewModels = [MovieCellViewModel]()
        
        for movie in movies.movies {
            movieCellViewModels.append(createCellViewModel(movie: movie))
        }
        if let page = movies.page {
            if page > 1 {
                self.indexPathsToReload = self.calculateIndexPathsToReload(from: movies.movies)
            }
        }
        self.cellViewModels.append(contentsOf: movieCellViewModels)
    }
    
    func createCellViewModel(movie: Movie) -> MovieCellViewModel {
        return MovieCellViewModel(name: movie.title, image_url: movie.image_url ?? "", popularity: movie.popularity ?? 0.0, releaseDate: movie.releaseDate ?? "")
    }
}

extension MovieListViewModel {
    func userPressed( at indexPath: IndexPath ) {
        let movie = self.cellViewModels[indexPath.row]
            self.selectedMovie = movie
    }
}

