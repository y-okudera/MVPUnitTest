//
//  TransitToExternalBrowserWireframe.swift
//  Presentation
//
//  Created by okudera on 2021/05/03.
//

import Common
import UIKit

protocol TransitToExternalBrowserWireframe: AnyObject {
    func openExternalBrowser(by urlString: String)
}

extension TransitToExternalBrowserWireframe {
    func openExternalBrowser(by urlString: String) {
        guard let url = URL(string: urlString) else {
            Logger.error("URL is nil.")
            return
        }
        guard UIApplication.shared.canOpenURL(url) else {
            Logger.error("UIApplication.shared.canOpenURL is false. url: \(url)")
            return
        }
        UIApplication.shared.open(url, options: [:])
    }
}
