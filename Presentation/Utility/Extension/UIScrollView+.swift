//
//  UIScrollView+.swift
//  Presentation
//
//  Created by okudera on 2021/05/04.
//

import UIKit

extension UIScrollView {
    func isNearBottomEdge(edgeOffset: CGFloat = 20.0) -> Bool {
        return contentOffset.y + frame.size.height + edgeOffset > contentSize.height
    }
}
