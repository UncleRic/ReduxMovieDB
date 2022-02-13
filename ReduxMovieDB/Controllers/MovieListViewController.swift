//
//  MovieListViewController.swift
//  ReduxMovieDB
//
//  Created by Matheus Cardoso on 2/11/18.
//  Copyright © 2018 Matheus Cardoso. All rights reserved.
//

import Combine
import CombineCocoa
import CombineKeyboard
import ReSwift
import UIKit

class MovieListViewController: UIViewController {
    var movies: [Movie] = []

    var cancellables = Cancellables()

    @IBOutlet var moviesTableView: UITableView! {
        didSet {
            moviesTableView.backgroundView = UIView()
            moviesTableView.backgroundView?.backgroundColor = moviesTableView.backgroundColor

            moviesTableView.didSelectRowPublisher //  ...CombineCocoa
                .map { self.movies[$0.row] }
                .map(MainStateAction.showMovieDetail)
                .sink { mainStore.dispatch($0) }
                .store(in: &cancellables)

            moviesTableView.willDisplayCellPublisher //  ...CombineCocoa
                .filter { $1.row == mainStore.state.movies.count - 1 }
                .map { _ in fetchMoviesPage }
                .sink { mainStore.dispatch($0) }
                .store(in: &cancellables)
        }
    }

    @IBOutlet var searchBar: UISearchBar! {
        didSet {
            searchBar.textDidChangePublisher //  ...CombineCocoa
                .filter { !$0.isEmpty && mainStore.state.canDispatchSearchActions }
                .sink {
                    mainStore.dispatch(MainStateAction.search($0))
                    mainStore.dispatch(fetchMoviesPage)
                }
                .store(in: &cancellables)

            searchBar.textDidChangePublisher //  ...CombineCocoa
                .filter { $0.isEmpty && mainStore.state.canDispatchSearchActions }
                .sink { _ in
                    mainStore.dispatch(MainStateAction.readySearch)
                    mainStore.dispatch(fetchMoviesPage)
                }
                .store(in: &cancellables)

            searchBar.cancelButtonClickedPublisher //  ...CombineCocoa
                .sink {
                    mainStore.dispatch(MainStateAction.cancelSearch)
                    mainStore.dispatch(fetchMoviesPage)
                }
                .store(in: &cancellables)
        }
    }

    var isInSplitViewPresentation: Bool {
        !(splitViewController?.isCollapsed ?? true)
    }

    // ----------------------------------------------------------------------------------------------

    // MARK: - UIViewController functions

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        title = "FILMS"

        CombineKeyboard.shared.height
            .sink { height in
                self.additionalSafeAreaInsets.bottom = height
            }
            .store(in: &cancellables)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainStore.subscribe(self, transform: { // ...RxSwift.
            $0.select(MovieListViewState.init)
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainStore.unsubscribe(self) // ...RxSwift
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { _ in
            self.moviesTableView.visibleCells.forEach {
                if let cell = $0 as? MovieListTableViewCell {
                    cell.setDisclosureIndicator(visible: !self.isInSplitViewPresentation)
                }
            }
        }
        super.viewWillTransition(to: size, with: coordinator)
    }
}

// ==============================================================================================

// MARK: -

// MARK: StoreSubscriber

extension MovieListViewController: StoreSubscriber {
    typealias StoreSubscriberStateType = MovieListViewState

    func newState(state: MovieListViewState) {
        moviesTableView.diffUpdate(source: movies, target: state.movies) {
            self.movies = $0
        }

        searchBar.text = state.searchBarText
        searchBar.showsCancelButton = state.searchBarShowsCancel

        switch (searchBar.isFirstResponder, state.searchBarFirstResponder) {
        case (true, false): searchBar.resignFirstResponder()
        case (false, true): searchBar.becomeFirstResponder()
        default: break
        }
    }
}

// ==============================================================================================

// MARK: - UITableViewDataSource

class MovieListTableViewCell: UITableViewCell {
    @IBOutlet var icon: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var subtitle: UILabel!

    var movie: Movie? {
        didSet {
            guard let movie = movie else { return }

            icon.setPosterForMovie(movie)
            title.text = movie.title
            subtitle.text = movie.releaseDate?.description ?? ""
        }
    }
}

// ==============================================================================================

// MARK: -

extension MovieListTableViewCell {
    func setDisclosureIndicator(visible: Bool) {
        accessoryType = visible ? .disclosureIndicator : .none
    }
}

// ==============================================================================================

// MARK: -

extension MovieListViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        movies.count
    }

    // *** CELL FOR ROW ***
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieListTableViewCell") as? MovieListTableViewCell else {
            return UITableViewCell()
        }

        cell.movie = movies[indexPath.row]
        cell.setDisclosureIndicator(visible: !isInSplitViewPresentation)
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        cell.selectionStyle = .none

        return cell
    }
}

extension MovieListViewController: UISearchBarDelegate {}
