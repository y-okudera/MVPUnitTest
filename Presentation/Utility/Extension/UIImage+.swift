//
//  UIImage+.swift
//  Presentation
//
//  Created by okudera on 2021/05/03.
//

import UIKit

extension UIImage {
    func roundImage() -> UIImage {
        let minLength: CGFloat = min(size.width, size.height)
        let rectangleSize = CGSize(width: minLength, height: minLength)
        UIGraphicsBeginImageContextWithOptions(rectangleSize, false, 0.0)

        UIBezierPath(roundedRect: CGRect(origin: .zero, size: rectangleSize), cornerRadius: minLength).addClip()
        draw(in: CGRect(origin: CGPoint(x: (minLength - size.width) / 2, y: (minLength - size.height) / 2), size: size))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}
