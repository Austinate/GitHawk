//
//  ProjectListViewController.swift
//  Freetime
//
//  Created by Sherlock, James on 18/09/2017.
//  Copyright © 2017 Ryan Nystrom. All rights reserved.
//

import UIKit
import IGListKit

final class ProjectListViewController: UIViewController, FeedDelegate, ListAdapterDataSource {

    private let client: GithubClient
    private let repository: RepositoryDetails
    
    private lazy var feed: Feed = { Feed(viewController: self, delegate: self) }()
    private var projects: [Project]?
    private var nextPageToken: String?
    
    // MARK: - Initialiser
    
    init(client: GithubClient, repository: RepositoryDetails) {
        self.client = client
        self.repository = repository
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        feed.viewDidLoad()
        feed.adapter.dataSource = self
        title = NSLocalizedString("Projects", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rz_smoothlyDeselectRows(collectionView: feed.collectionView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        feed.viewWillLayoutSubviews(view: view)
    }
    
    // MARK: - Loading
    
    private func update() {
        feed.finishLoading(dismissRefresh: true, animated: true, completion: nil)
    }
    
    private func reload(loadNext: Bool = false) {
        let nextPage = loadNext ? nextPageToken : nil
        client.loadProjects(for: repository, containerWidth: view.bounds.width, nextPage: nextPage) { [weak self] result in
            switch result {
            case .error(let error):
                print(error?.localizedDescription ?? "No Error")
            case .success(let payload):
                self?.nextPageToken = payload.nextPage
                self?.projects = payload.projects
                self?.update()
            }
        }
    }
    
    // MARK: - FeedDelegate
    
    func loadFromNetwork(feed: Feed) {
        reload()
    }
    
    func loadNextPage(feed: Feed) -> Bool {
        return nextPageToken != nil
    }

    // MARK: - ListAdapterDataSource
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return projects ?? []
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return ProjectSummarySectionController(client: client, repo: repository)
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}
