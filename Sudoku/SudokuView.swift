//
//  SudokuView.swift
//  Sudoku
//
//  Created by Jiaxin Shou on 2025/5/15.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct SudokuFeature {
    struct State {
        var grid: SudokuGridFeature.State

        var input: SudokuInputFeature.State

        var stats: SudokuStatsFeature.State
    }

    enum Action {
        case grid(SudokuGridFeature.Action)

        case input(SudokuInputFeature.Action)

        case stats(SudokuStatsFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.grid, action: \.grid) {
            SudokuGridFeature()
        }

        Scope(state: \.input, action: \.input) {
            SudokuInputFeature()
        }

        Scope(state: \.stats, action: \.stats) {
            SudokuStatsFeature()
        }

        Reduce { _, action in
            switch action {
            case .input(.delegate(.onErase)):
                .send(.grid(.eraseSelection))

            case let .input(.delegate(.onFill(newValue))):
                .send(.grid(.fillSelection(newValue)))

            case .input(.delegate(.onHint)):
                .send(.grid(.hintSelection))

            case let .input(.delegate(.onNote(newValue))):
                .send(.grid(.noteSelection(newValue)))

            case let .grid(.delegate(.onComplete(value))):
                .send(.input(.hide(value)))

            case .grid(.cells(.element(id: _, action: .delegate(.onIncorrectFill)))):
                .send(.stats(.increaseMistakeCount))

            default:
                .none
            }
        }
    }
}

struct SudokuView: View {
    private let store: StoreOf<SudokuFeature>

    init(difficulty: SudokuGenerator.Difficulty) {
        let generator = SudokuGenerator()
        let puzzle = generator.generatePuzzle(at: difficulty)
        let cells: [SudokuCellFeature.State] = puzzle.lazy
            .flatMap(\.self)
            .enumerated()
            .map { index, value in
                .init(content: value.map { .clue($0) }, row: index / 9, column: index % 9)
            }

        store = .init(
            initialState: SudokuFeature.State(
                grid: .init(cells: .init(uniqueElements: cells)),
                input: .init(),
                stats: .init(difficulty: difficulty)
            ),
            reducer: {
                SudokuFeature()
            },
            withDependencies: {
                $0.sudokuGenerator = generator
            }
        )
    }

    var body: some View {
        VStack {
            SudokuStatsView(store: store.scope(
                state: \.stats,
                action: \.stats
            ))
            .padding()

            SudokuGrid(store: store.scope(
                state: \.grid,
                action: \.grid
            ))
            .padding()

            SudokuInput(store: store.scope(
                state: \.input,
                action: \.input
            ))
            .padding()
        }
    }
}

#if DEBUG

#Preview {
    SudokuView(difficulty: .easy)
}

#endif
