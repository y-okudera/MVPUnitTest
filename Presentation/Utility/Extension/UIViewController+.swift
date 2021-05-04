//
//  UIViewController+.swift
//  Presentation
//
//  Created by okudera on 2021/04/30.
//

import NVActivityIndicatorView
import UIKit

extension UIViewController {

    /// Make the ViewController's instance.
    /// - Parameters:
    ///   - storyboardName:
    ///   - storyboardID:
    /// - Returns: ViewController's instance.
    static func instantiate(storyboardName: String, storyboardID: String) -> Self {
        let storyboard = UIStoryboard(name: storyboardName, bundle: .current)
        return storyboard.instantiateViewController(identifier: storyboardID)
    }

    /// Make the ViewController's instance.
    ///
    /// - Precondition: The `storyboardName` and the `storyboardID` properties must same as ViewController class name.
    /// - Returns: ViewController's instance.
    static func instantiate() -> Self {
        return instantiate(storyboardName: className, storyboardID: className)
    }
}

extension UIViewController {

    private var activityIndicatorView: NVActivityIndicatorView? {
        return view.findViews(subclassOf: NVActivityIndicatorView.self).first
    }

    func addActivityIndicatorView() {
        let activityIndicatorView = NVActivityIndicatorView.make()
        view.addSubview(activityIndicatorView)
        activityIndicatorView.center = view.center
    }

    func startAnimating() {
        activityIndicatorView?.startAnimating()
    }

    func stopAnimating() {
        activityIndicatorView?.stopAnimating()
    }
}
