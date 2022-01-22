//
//  UIImageView+MoviePoster.swift
//  ReduxMovieDB
//
//  Created by Matheus Cardoso on 2/12/18.
//  Copyright © 2018 Matheus Cardoso. All rights reserved.
//

import Foundation
import Nuke
import UIKit

extension UIImageView {
    private var activityIndicator: UIActivityIndicatorView {
        if let activityIndicator = subviews.compactMap({ $0 as? UIActivityIndicatorView }).first {
            return activityIndicator
        }

        let activityIndicator = UIActivityIndicatorView(style: .medium)
        addSubview(activityIndicator)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        addConstraint(
            NSLayoutConstraint(
                item: activityIndicator,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: self,
                attribute: .centerX,
                multiplier: 1.0,
                constant: 0.0
            )
        )

        addConstraint(
            NSLayoutConstraint(
                item: activityIndicator,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: self,
                attribute: .centerY,
                multiplier: 1.0,
                constant: 0.0
            )
        )

        return activityIndicator
    }

    private func startLoading() {
        activityIndicator.startAnimating()
    }

    private func stopLoading() {
        activityIndicator.stopAnimating()
    }

    private var imageBaseUrl: String {
        "https://image.tmdb.org/t/p/w500"
    }

    func setPosterForMovie(_ movie: Movie) {
        let placeholder = UIImage(named: "poster_placeholder")

        guard let posterPath = movie.posterPath,
              let imageURL = URL(string: "\(imageBaseUrl)\(posterPath)")
        else {
            image = placeholder
            return
        }

        startLoading()

        let options = ImageLoadingOptions(
            placeholder: placeholder,
            transition: .fadeIn(duration: 0.33)
        )

        Nuke.loadImage(
            with: imageURL,
            options: options,
            into: self
        ) { [weak self] _, _, _ in
            self?.stopLoading()
        }
    }
}
