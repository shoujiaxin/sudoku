//
//  SudokuMenuFeature.swift
//  Sudoku
//
//  Created by Jiaxin Shou on 2025/5/17.
//

import ComposableArchitecture

@Reducer
struct SudokuMenuFeature {
    @ObservableState
    struct State {
        let stats: SudokuStatsFeature.State
    }

    enum Action {
        enum Delegate {
            case onNewGame

            case onRestart

            case onResume
        }

        case delegate(Delegate)

        case newGame

        case restart

        case resume
    }

    @Dependency(\.dismiss)
    private var dismiss

    var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .delegate:
                .none

            case .newGame:
                // TODO: double confirmation
                .run { send in
                    await send(.delegate(.onNewGame))
                    await dismiss(animation: .smooth(duration: 0.25))
                }

            case .restart:
                // TODO: double confirmation
                .run { send in
                    await send(.delegate(.onRestart))
                    await dismiss(animation: .smooth(duration: 0.25))
                }

            case .resume:
                .run { send in
                    await send(.delegate(.onResume))
                    await dismiss(animation: .smooth(duration: 0.25))
                }
            }
        }
    }
}
