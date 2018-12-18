//
//  MovieDetailViewController.swift
//  MovieApp
//
//  Created by Nano Suarez on 16/12/2018.
//  Copyright © 2018 nano. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieDetailImageView: UIImageView!
    @IBOutlet weak var moviePopularityLabel: UILabel!
    
    @IBOutlet weak var movieReleaseDate: UILabel!
    var movie: MovieCellViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let baseUrl = "https://image.tmdb.org/t/p/w300/"
        let posterPath = movie?.image_url
        let imageUrlString = baseUrl + posterPath!
        
        if !posterPath!.isEmpty {
            ImageLoader.image(for: imageUrlString) { image in
                if let image = image  {
                    self.movieDetailImageView.image = image
                }
            }
        }
        
        self.movieTitleLabel.text = movie?.name
        self.moviePopularityLabel.text = "Popularity: " + (movie?.popularity.description ?? "0")
        self.movieReleaseDate.text = "Release date: " + (movie?.releaseDate ?? "")
    }
}
