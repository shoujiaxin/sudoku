//
//  SudokuStatsFeature.swift
//  Sudoku
//
//  Created by Jiaxin Shou on 2025/5/17.
//

import ComposableArchitecture
import Foundation

@Reducer
struct SudokuStatsFeature {
    @ObservableState
    struct State {
        var difficulty: SudokuGenerator.Difficulty

        var elapsedTime: TimeInterval = .zero

        var mistakeCount: Int = 0
    }

    enum Action {
        case increaseMistakeCount
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .increaseMistakeCount:
                state.mistakeCount += 1
                return .none
            }
        }
    }
}
