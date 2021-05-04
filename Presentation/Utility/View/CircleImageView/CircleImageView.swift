//
//  CircleImageView.swift
//  Presentation
//
//  Created by okudera on 2021/05/03.
//

import UIKit

final class CircleImageView: UIImageView {
    override func awakeFromNib() {
        super.awakeFromNib()
        swapImage()
    }

    private func swapImage() {
        let image = self.image
        self.image = image
    }

    override var image: UIImage? {
        get { super.image }
        set {
            contentMode = .scaleAspectFit
            super.image = newValue?.roundImage()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2.0
    }
}
