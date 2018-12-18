//
//  MovieCollectionViewCell.swift
//  MovieApp
//
//  Created by Nano Suarez on 14/12/2018.
//  Copyright © 2018 nano. All rights reserved.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet var indicatorView: UIActivityIndicatorView!

    
    override func prepareForReuse() {
        
        movieImageView.image = nil
        
        super.prepareForReuse()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        indicatorView?.color = .black
    }
    
}

