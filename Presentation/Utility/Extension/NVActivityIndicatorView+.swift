//
//  NVActivityIndicatorView+.swift
//  Presentation
//
//  Created by okudera on 2021/05/04.
//

import NVActivityIndicatorView

extension NVActivityIndicatorView {
    public class func setDefaultValues() {
        NVActivityIndicatorView.DEFAULT_TYPE = .ballRotateChase
        NVActivityIndicatorView.DEFAULT_COLOR = .purple
        NVActivityIndicatorView.DEFAULT_BLOCKER_MINIMUM_DISPLAY_TIME = 200
    }

    class func make() -> NVActivityIndicatorView {
        let activityIndicatorView = NVActivityIndicatorView(frame: .init(origin: .zero, size: NVActivityIndicatorView.DEFAULT_BLOCKER_SIZE))
        return activityIndicatorView
    }
}
