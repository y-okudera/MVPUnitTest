//
//  UITableView+.swift
//  Presentation
//
//  Created by okudera on 2021/05/03.
//

import UIKit

extension UITableView {

    func register(cellTypes: [UITableViewCell.Type], bundle: Bundle? = .current) {
        cellTypes.forEach { register(cellType: $0, bundle: bundle) }
    }

    func register(cellType: UITableViewCell.Type, bundle: Bundle? = .current) {
        let className = cellType.className
        let nib = UINib(nibName: className, bundle: bundle)
        register(nib, forCellReuseIdentifier: className)
    }

    func dequeueReusableCell<T: UITableViewCell>(with type: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: type.className, for: indexPath) as! T
    }
}
