//
//  UIImageView+.swift
//  Presentation
//
//  Created by okudera on 2021/05/03.
//

import Nuke
import UIKit

extension UIImageView {

    typealias Completion = (Result<UIImage, Error>) -> Void
    func loadImage(with url: URL?, placeholder: UIImage? = nil, completion: Completion? = nil) {
        guard let url = url else {
            return
        }
        Nuke.loadImage(with: url, options: .init(placeholder: placeholder, transition: .fadeIn(duration: 0.2)), into: self, completion: {
            switch $0 {
            case .success(let response):
                completion?(.success(response.image))
            case .failure(let error):
                completion?(.failure(error))
            }
        })
    }
}
