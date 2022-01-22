//
//  MainState.swift
//  ReduxMovieDB
//
//  Created by Matheus Cardoso on 2/11/18.
//  Copyright © 2018 Matheus Cardoso. All rights reserved.
//

import ReSwift
import ReSwiftThunk

enum SearchState: Equatable {
    case canceled
    case ready
    case searching(String)
}

enum MovieDetailState: Equatable {
    case willHide(Movie)
    case hide
    case show(Movie)

    var movie: Movie? {
        switch self {
        case let .willHide(movie):
            return movie
        case .hide:
            return nil
        case let .show(movie):
            return movie
        }
    }
}

enum SplitDetailState: Equatable {
    case collapsed
    case separated
}

struct MainState: StateType, Equatable {
    var genres: [Genre] = []
    var moviePages: Pages<Movie> = .init()

    var movieDetail: MovieDetailState = .hide
    var splitDetail: SplitDetailState = .separated

    var search: SearchState = .canceled

    var movies: [Movie] {
        moviePages.values
    }

    var canDispatchSearchActions: Bool {
        switch (splitDetail, movieDetail) {
        case (.separated, _),
             (.collapsed, .hide):
            return true
        default:
            return false
        }
    }
}

func mainReducer(action: Action, state: MainState?) -> MainState {
    var state = state ?? MainState()

    guard let action = action as? MainStateAction else {
        return state
    }

    switch action {
    case let .addGenres(genres):
        state.genres.append(contentsOf: genres)

    case let .fetchNextMoviesPage(totalPages, movies):
        // TMDB API is returning duplicates...
        let values = movies.filter { movie in !state.movies.contains(where: { $0.id == movie.id }) }
        state.moviePages.addPage(totalPages: totalPages, values: values)

    case let .willHideMovieDetail(movie):
        state.movieDetail = .willHide(movie)
    case .hideMovieDetail:
        state.movieDetail = .hide
    case let .showMovieDetail(movie):
        state.movieDetail = .show(movie)

    case .cancelSearch:
        state.moviePages = Pages<Movie>()
        state.search = .canceled
    case .readySearch:
        state.moviePages = Pages<Movie>()
        state.search = .ready
    case let .search(query):
        state.moviePages = Pages<Movie>()
        state.search = .searching(query)
    case .collapseSplitDetail:
        state.splitDetail = .collapsed
    case .separateSplitDetail:
        state.splitDetail = .separated
    }

    return state
}

let thunksMiddleware: Middleware<MainState> = createThunkMiddleware()

let mainStore = Store(
    reducer: mainReducer,
    state: MainState(),
    middleware: [thunksMiddleware]
)
