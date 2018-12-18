//
//  APIService.swift
//  MovieApp
//
//  Created by Nano Suarez on 14/12/2018.
//  Copyright © 2018 nano. All rights reserved.
//

import Foundation

enum Result<Value> {
    case success(Value)
    case failure(Error)
}

protocol URLSessionProtocol {
    typealias DataTaskResult = (Data?, URLResponse?, Error?) -> ()
    
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol
}

protocol URLSessionDataTaskProtocol {
    func resume()
}

protocol APIServiceProtocol {
    func fetchMovies(page: Int, complete: @escaping (( _ data: Movies?, _ error: Error?)->()))
}

final class APIService: APIServiceProtocol {
    let apiKey = "Get an api key from the web"
    typealias completeClosure = ( _ data: Movies?, _ error: Error?)-> ()
    private let session: URLSessionProtocol
    
    init() {
        self.session = URLSession.shared
    }
    
    //I use this init for unit testing, dependency injection of session
    init(session: URLSessionProtocol) {
        self.session = session
    }
    
    func fetchMovies(page: Int, complete: @escaping completeClosure){
        
        let urlString = self.urlString()
        let apiString = "&api_key=\(apiKey)"
        let pageParameter = "&page=\(page)"
        let searchString = "&primary_release_date.gte=2018-09-15&primary_release_date.lte=2018-10-22"
        
        guard let url = URL(string: urlString + apiString + pageParameter + searchString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
                if let Responserror = error {
                    complete(nil, Responserror)
                }
            }
            
            guard let responseData = data else { return }
            
            do {
                //Decode retrived data with JSONDecoder and assing type of Country object
                let moviesData = try JSONDecoder().decode(Movies.self, from: responseData)
                complete(moviesData, nil)
                
            } catch let jsonError {
                print(jsonError)
                complete(nil, jsonError)
            }
        }
        task.resume()
    }
    
    func urlString() -> String{
        let endpoints = Endpoints()
        return endpoints.latestsMoviesEndpoint
    }
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}

//MARK: Conform the protocol
extension URLSession: URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        return (dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask) as URLSessionDataTaskProtocol
    }
}

