//
//  SudokuCellFeature.swift
//  Sudoku
//
//  Created by Jiaxin Shou on 2025/5/16.
//

import ComposableArchitecture

@Reducer
struct SudokuCellFeature {
    @ObservableState
    struct State {
        enum Content {
            case candidates(_ values: Set<Int>)

            case clue(_ value: Int)

            case mistake(_ value: Int)

            case solution(_ value: Int)

            var value: Int? {
                switch self {
                case .candidates:
                    nil

                case let .clue(value),
                     let .mistake(value),
                     let .solution(value):
                    value
                }
            }
        }

        var content: Content?

        var row: Int

        var column: Int

        func isPeer(with other: Self) -> Bool {
            if row == other.row, column == other.column {
                false
            } else {
                row == other.row || column == other.column || (row / 3 == other.row / 3 && column / 3 == other.column / 3)
            }
        }
    }

    enum Action {
        enum Delegate {
            case onCorrectFill(_ value: Int)

            case onIncorrectFill(_ value: Int)
        }

        case clear

        case delegate(Delegate)

        case fill(_ newValue: Int)

        case note(_ newValue: Int)

        case removeNote(_ value: Int)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .clear:
                handleClear(state: &state)

            case .delegate:
                .none

            case let .fill(newValue):
                handleFill(newValue, state: &state)

            case let .note(newValue):
                handleNote(newValue, state: &state)

            case let .removeNote(value):
                handleRemoveNote(value, state: &state)
            }
        }
    }

    @Dependency(\.sudokuGenerator)
    private var sudokuGenerator

    private func handleClear(state: inout State) -> Effect<Action> {
        switch state.content {
        case .candidates,
             .mistake:
            state.content = nil

        default:
            break
        }

        return .none
    }

    private func handleFill(_ newValue: Int, state: inout State) -> Effect<Action> {
        switch state.content {
        case .none,
             .candidates:
            validateAndFill(with: newValue, state: &state)

        case let .mistake(value):
            value == newValue ? .none : validateAndFill(with: newValue, state: &state)

        case .clue,
             .solution:
            .none
        }
    }

    private func handleNote(_ newValue: Int, state: inout State) -> Effect<Action> {
        switch state.content {
        case .none:
            state.content = .candidates([newValue])

        case var .candidates(values):
            if values.contains(newValue) {
                values.remove(newValue)
                state.content = values.isEmpty ? nil : .candidates(values)
            } else {
                values.insert(newValue)
                state.content = .candidates(values)
            }

        case .mistake:
            state.content = .candidates([newValue])

        case .clue,
             .solution:
            break
        }

        return .none
    }

    private func handleRemoveNote(_ value: Int, state: inout State) -> Effect<Action> {
        if case var .candidates(values) = state.content, values.contains(value) {
            values.remove(value)
            state.content = values.isEmpty ? nil : .candidates(values)
        }

        return .none
    }

    private func validateAndFill(with newValue: Int, state: inout State) -> Effect<Action> {
        if sudokuGenerator.validate(value: newValue, row: state.row, column: state.column) {
            state.content = .solution(newValue)
            return .send(.delegate(.onCorrectFill(newValue)))
        } else {
            state.content = .mistake(newValue)
            return .send(.delegate(.onIncorrectFill(newValue)))
        }
    }
}

extension SudokuCellFeature.State: Identifiable {
    var id: Int {
        (row << 8) | column
    }
}
