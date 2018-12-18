//
//  APIServiceTests.swift
//  MovieAppTests
//
//  Created by Nano Suarez on 17/12/2018.
//  Copyright © 2018 nano. All rights reserved.
//

import XCTest
@testable import MovieApp

class MockURLSession: URLSessionProtocol {
    
    var nextDataTask = MockURLSessionDataTask()
    var nextData: Data?
    var nextError: Error?
    
    private (set) var lastURL: URL?
    
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        lastURL = request.url
        
        completionHandler(nextData, successHttpURLResponse(request: request), nextError)
        return nextDataTask
    }
    
    func successHttpURLResponse(request: URLRequest) -> URLResponse {
        return HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
    }
    
}

class MockURLSessionDataTask: URLSessionDataTaskProtocol {
    private (set) var resumeWasCalled = false
    
    func resume() {
        resumeWasCalled = true
    }
}


class APIServiceTests: XCTestCase {
    var sut: APIService!
    var session = MockURLSession()

    override func setUp() {
        super.setUp()
        
        sut = APIService(session: session)
    }

    override func tearDown() {
        sut = nil
    }

    //The apiService should submit the request with the same URL as the assigned one.
    func testRequestLatestMoviesWithSameURL() {
        let apiKey = "Get an api key from the web"
        guard let url = URL(string: "https://api.themoviedb.org/3/discover/movie?&api_key=\(apiKey)&page=1&primary_release_date.gte=2018-09-15&primary_release_date.lte=2018-10-22") else  {
            fatalError("URL can't be empty")
        }
        sut.fetchMovies(page: 1) { (response, error) in
        }
        
        XCTAssert(session.lastURL == url)
    }
    
    func testGetResumeCalled() {
        let dataTask = MockURLSessionDataTask()
        session.nextDataTask = dataTask
        
        sut.fetchMovies(page: 1) { (response, error) in
        }
        XCTAssert(dataTask.resumeWasCalled)
    }
    
    func testGetShouldReturnData() {
        
        let expectedMovie = self.latestMovie()
        
        guard let path = Bundle(for: type(of: self)).url(forResource: "content", withExtension:"json")?.path else {
            fatalError("json file not found")
        }
        let expectedData = try! Data(contentsOf: URL(fileURLWithPath: path))
        session.nextData = expectedData
        
        var actualData: Movies?
        sut.fetchMovies(page: 1) { (response, error) in
            actualData = response
        }
        
        XCTAssertNotNil(actualData)
        
        if let name = actualData?.movies[0].title {
            XCTAssertTrue(name == expectedMovie.title)
        }
    }
    
    func latestMovie() -> Movie {
        
        return Movie(voteCount: 3113, id: 335983, video: false, voteAverage: 6.5, title: "Venom", popularity: 268.175, image_url: "2uNW4WbgBXL25BAbXGLnLqX71Sw.jpg", language: "en", originalTitle: "Venom", genreIds: [878], backdropPath: "VuukZLgaCrho2Ar8Scl9HtV3yD.jpg", adult: false, overview: "Eddie Brock is", releaseDate: "2018-10-03")
    }

}
