//
//  MovieListViewModelTests.swift
//  MovieAppTests
//
//  Created by Nano Suarez on 18/12/2018.
//  Copyright © 2018 nano. All rights reserved.
//

import XCTest
@testable import MovieApp

class MovieListViewModelTests: XCTestCase {
    var sut: MovieListViewModel!
    var mockAPIService: MockAPIService!
    
    enum APIError: String, Error {
        case noNetwork = "No Network"
        case serverOverload = "Server is overloaded"
        case permissionDenied = "You don't have permission"
    }

    override func setUp() {
        mockAPIService = MockAPIService()
        mockAPIService.session = MockURLSession()
        
        sut = MovieListViewModel(apiService: mockAPIService)
    }

    override func tearDown() {
        sut = nil
        mockAPIService = nil
        super.tearDown()
    }

    func testFetchMovie() {
        let movies:Movies?
        
        movies = StubGenerator().stubMovies()
        
        // Given
        mockAPIService.completeMovies = movies
        
        // When
        sut.initFetch()
        
        // Assert
        XCTAssert(mockAPIService!.isFetchMoviesCalled)
    }
    
    func testCreateCellViewModel() {
        // Given
        let movies = StubGenerator().stubMovies()
        mockAPIService.completeMovies = movies
        let expect = XCTestExpectation(description: "reload closure triggered")
        
        sut.reloadCollectionViewClosure = { (indexPath) in
                expect.fulfill()
        }
        
        // When
        sut.initFetch()
        mockAPIService.fetchSuccess()
        
        // Number of cell view model is equal to the number of movies
        XCTAssertEqual(sut.numberOfCells, movies.movies.count)
        
        // XCTAssert reload closure triggered
        wait(for: [expect], timeout: 1.0)
    }
    
    func testLoadingWhenFetching() {
        
        //Given
        var loadingStatus = false
        let expect = XCTestExpectation(description: "Loading status updated")
        sut.updateLoadingStatus = { [weak sut] in
            loadingStatus = sut!.isLoading
            expect.fulfill()
        }
        
        //when fetching
        sut.initFetch()
        
        // Assert
        XCTAssertTrue( loadingStatus )
        
        // When finished fetching
        mockAPIService!.fetchSuccess()
        XCTAssertFalse( loadingStatus )
        
        wait(for: [expect], timeout: 1.0)
    }
    
    func testMovieCellViewModelWasCreatedProperly() {
        //Given movie
        let movie = StubGenerator().stubMovies().movies.first
        if let movie = movie {
            // When create cell view model
            let cellViewModel = sut!.createCellViewModel(movie: movie)
            
            // Assert the correctness of display information
            XCTAssertEqual( movie.title, cellViewModel.name )
            XCTAssertEqual( movie.image_url, cellViewModel.image_url)
        }
    }
}

class MockAPIService: APIServiceProtocol {
    var session = MockURLSession()
    var isFetchMoviesCalled = false
    var completeMovies: Movies?
    var completeClosure: ((Movies?, Error?) -> ())!
    
    func fetchMovies(page: Int, complete: @escaping ((Movies?, Error?) -> ())) {
        isFetchMoviesCalled = true
        completeClosure = complete
    }
    
    func fetchSuccess() {
        completeClosure( completeMovies, nil )
    }
    
    func fetchFail(error: Error?) {
        completeClosure( nil, error )
    }
}

class StubGenerator {
    func stubMovies() -> Movies {
        guard let path = Bundle(for: type(of: self)).url(forResource: "content", withExtension:"json")?.path else {
            fatalError("json file not found")
        }
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let movies = try! decoder.decode(Movies.self, from: data)
        return movies
    }
}

