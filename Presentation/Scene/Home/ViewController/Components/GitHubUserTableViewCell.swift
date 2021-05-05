//
//  GitHubUserTableViewCell.swift
//  Presentation
//
//  Created by okudera on 2021/05/03.
//

import Common
import Domain
import Nuke
import UIKit

final class GitHubUserTableViewCell: UITableViewCell {

    @IBOutlet weak private var thumbnailImageView: CircleImageView!
    @IBOutlet weak private var nameLabel: UILabel!

    var userPageButtonHandler: ((String?) -> Void)?
    var repositoriesPageButtonHandler: ((String?) -> Void)?

    private var data: GitHubUser?

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
    }

    func configure(data: GitHubUser) {
        self.data = data
        thumbnailImageView.loadImage(with: data.thumbnailUrl)
        nameLabel.text = data.name
    }

    @IBAction private func tappedUserPageButton(_ sender: UIButton) {
        Logger.debug("Tapped UserPage Button")
        userPageButtonHandler?(data?.htmlUrl)
    }

    @IBAction private func tappedRepositoriesPageButton(_ sender: UIButton) {
        Logger.debug("Tapped RepositoriesPage Button")
        repositoriesPageButtonHandler?(data?.reposUrl)
    }
}
