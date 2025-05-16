//
//  SudokuInputFeature.swift
//  Sudoku
//
//  Created by Jiaxin Shou on 2025/5/16.
//

import ComposableArchitecture

@Reducer
struct SudokuInputFeature {
    @ObservableState
    struct State {
        enum Mode {
            case fill

            case note
        }

        var hiddenValues: Set<Int> = []

        var mode: Mode = .fill
    }

    enum Action {
        enum Delegate {
            case onErase

            case onFill(_ newValue: Int)

            case onHint

            case onNote(_ newValue: Int)

            case onRedo

            case onUndo
        }

        case delegate(Delegate)

        case hide(_ value: Int)

        case input(_ newValue: Int)

        case toggleMode
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .delegate:
                .none

            case let .hide(value):
                handleHide(value, state: &state)

            case let .input(newValue):
                handleInput(newValue, state: &state)

            case .toggleMode:
                handleToggleMode(state: &state)
            }
        }
    }

    private func handleHide(_ value: Int, state: inout State) -> Effect<Action> {
        state.hiddenValues.insert(value)

        return .none
    }

    private func handleToggleMode(state: inout State) -> Effect<Action> {
        state.mode = switch state.mode {
        case .fill:
            .note

        case .note:
            .fill
        }

        return .none
    }

    private func handleInput(_ newValue: Int, state: inout State) -> Effect<Action> {
        switch state.mode {
        case .fill:
            .send(.delegate(.onFill(newValue)))

        case .note:
            .send(.delegate(.onNote(newValue)))
        }
    }
}
