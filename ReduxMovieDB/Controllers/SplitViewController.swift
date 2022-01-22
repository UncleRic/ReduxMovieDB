//
//  SplitViewController.swift
//  ReduxMovieDB
//
//  Created by Matheus Cardoso on 2/11/18.
//  Copyright © 2018 Matheus Cardoso. All rights reserved.
//

import UIKit

import ReSwift

class SplitViewController: UISplitViewController {
    var movieListViewController: MovieListViewController? {
        let navigationController = viewControllers.first as? UINavigationController
        return navigationController?.topViewController as? MovieListViewController
    }

    var movieDetailViewController: MovieDetailViewController? {
        let navigationController = viewControllers.last as? UINavigationController
        return navigationController?.topViewController as? MovieDetailViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        preferredDisplayMode = .allVisible
        delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainStore.subscribe(self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainStore.unsubscribe(self)
    }
}

// MARK: StoreSubscriber

extension SplitViewController: StoreSubscriber {
    typealias StoreSubscriberStateType = MainState

    func newState(state: MainState) {
        if case .show = state.movieDetail, movieDetailViewController == nil {
            movieListViewController?.performSegue(withIdentifier: "showDetail", sender: self)
        }
    }
}

// MARK: UISplitViewControllerDelegate

extension SplitViewController: UISplitViewControllerDelegate {
    func splitViewController(_: UISplitViewController, collapseSecondary _: UIViewController, onto _: UIViewController) -> Bool {
        mainStore.dispatch(MainStateAction.collapseSplitDetail)
        return true
    }

    func splitViewController(_: UISplitViewController, separateSecondaryFrom _: UIViewController) -> UIViewController? {
        mainStore.dispatch(MainStateAction.separateSplitDetail)
        return nil
    }
}
