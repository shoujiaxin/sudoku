//
//  SudokuGridFeature.swift
//  Sudoku
//
//  Created by Jiaxin Shou on 2025/5/16.
//

import ComposableArchitecture

@Reducer
struct SudokuGridFeature {
    @ObservableState
    struct State {
        var cells: IdentifiedArrayOf<SudokuCellFeature.State>

        var selection: SudokuCellFeature.State.ID

        var selectedCell: SudokuCellFeature.State {
            guard let cell = cells[id: selection] else {
                fatalError("Selected cell not found.")
            }
            return cell
        }

        init(cells: IdentifiedArrayOf<SudokuCellFeature.State>) {
            assert(cells.count == 81, "Grid must have 81 cells.")

            self.cells = cells
            selection = cells[0].id
        }
    }

    enum Action {
        case cells(IdentifiedActionOf<SudokuCellFeature>)

        case eraseSelection

        case fillSelection(_ newValue: Int)

        case hintSelection

        case noteSelection(_ newValue: Int)

        case select(_ id: SudokuCellFeature.State.ID?)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .eraseSelection:
                .send(.cells(.element(
                    id: state.selection,
                    action: .clear
                )))

            case let .fillSelection(newValue):
                handleFillSelection(newValue, state: state)

            case .hintSelection:
                handleFillSelection(
                    value(for: state.selectedCell),
                    state: state
                )

            case let .noteSelection(newValue):
                .send(.cells(.element(
                    id: state.selection,
                    action: .note(newValue)
                )))

            case let .select(id):
                handleSelect(id, state: &state)

            default:
                .none
            }
        }
        .forEach(\.cells, action: \.cells) {
            SudokuCellFeature()
        }
    }

    @Dependency(\.sudokuGenerator)
    private var sudokuGenerator

    private func handleSelect(_ id: SudokuCellFeature.State.ID?, state: inout State) -> Effect<Action> {
        if let id {
            state.selection = id
        }

        return .none
    }

    private func handleFillSelection(_ newValue: Int, state: State) -> Effect<Action> {
        .concatenate(
            .send(.cells(.element(
                id: state.selection,
                action: .fill(newValue)
            ))),
            removeCandidatesIfNeeded(newValue, state: state)
        )
    }

    private func removeCandidatesIfNeeded(_ value: Int, state: State) -> Effect<Action> {
        .merge(state.cells.lazy
            .filter {
                $0.isPeer(with: state.selectedCell)
            }
            .map {
                .send(.cells(.element(
                    id: $0.id,
                    action: .removeNote(value)
                )))
            }
        )
    }

    private func value(for cell: SudokuCellFeature.State) -> Int {
        sudokuGenerator.value(row: cell.row, column: cell.column)
    }
}
