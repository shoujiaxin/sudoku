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
        let difficulty: SudokuGenerator.Difficulty

        var elapsedTime: TimeInterval = .zero

        var mistakeCount: Int = 0
    }

    enum Action {
        enum Delegate {
            case onPause
        }

        case delegate(Delegate)

        case increaseMistakeCount

        case pause

        case resume

        case timerTick
    }

    private enum TaskID {
        case timer
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .delegate:
                .none

            case .increaseMistakeCount:
                handleSncreaseMistakeCount(state: &state)

            case .pause:
                .merge(
                    .cancel(id: TaskID.timer),
                    .send(.delegate(.onPause))
                )

            case .resume:
                .run { send in
                    for await _ in clock.timer(interval: .seconds(1)) {
                        await send(.timerTick)
                    }
                }
                .cancellable(id: TaskID.timer, cancelInFlight: true)

            case .timerTick:
                handleTimerTick(state: &state)
            }
        }
    }

    @Dependency(\.continuousClock)
    private var clock

    private func handleSncreaseMistakeCount(state: inout State) -> Effect<Action> {
        state.mistakeCount += 1

        return .none
    }

    private func handleTimerTick(state: inout State) -> Effect<Action> {
        state.elapsedTime += 1

        return .none
    }
}
