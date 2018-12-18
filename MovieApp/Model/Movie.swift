//
//  Movie.swift
//  MovieApp
//
//  Created by Nano Suarez on 14/12/2018.
//  Copyright © 2018 nano. All rights reserved.
//

import Foundation

struct Movies: Codable {
    let page: Int?
    let totalResults: Int?
    let totalPages:Int?
    let movies: [Movie]
    
    private enum CodingKeys: String, CodingKey {
        case page
        case totalResults = "total_results"
        case totalPages = "total_pages"
        case movies = "results"
    }
}

struct Movie: Codable {
    let voteCount: Int?
    let id: Int?
    let video: Bool?
    let voteAverage: Double?
    let title: String
    let popularity: Double?
    let image_url: String?
    let language: String?
    let originalTitle: String?
    let genreIds: [Int]?
    let backdropPath: String?
    let adult: Bool?
    let overview: String?
    let releaseDate: String?
    
    private enum CodingKeys: String, CodingKey {
        case voteCount = "vote_count"
        case id
        case video
        case voteAverage = "vote_average"
        case title
        case popularity
        case image_url = "poster_path"
        case language = "original_language"
        case originalTitle = "original_title"
        case genreIds = "genre_ids"
        case backdropPath = "backdrop_path"
        case adult
        case overview
        case releaseDate = "release_date"
    }
}
