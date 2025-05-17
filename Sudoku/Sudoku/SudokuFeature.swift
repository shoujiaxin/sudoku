//
//  SudokuFeature.swift
//  Sudoku
//
//  Created by Jiaxin Shou on 2025/5/17.
//

import ComposableArchitecture

@Reducer
struct SudokuFeature {
    @ObservableState
    struct State {
        let difficulty: SudokuGenerator.Difficulty

        let puzzle: [[Int?]]

        var digitsCount: [Int: Int] = [:]

        var grid: SudokuGridFeature.State

        var input: SudokuInputFeature.State

        var stats: SudokuStatsFeature.State

        @Presents
        var menu: SudokuMenuFeature.State? = nil
    }

    enum Action {
        case grid(SudokuGridFeature.Action)

        case input(SudokuInputFeature.Action)

        case stats(SudokuStatsFeature.Action)

        case menu(PresentationAction<SudokuMenuFeature.Action>)
    }

    private let generator = SudokuGenerator()

    var body: some ReducerOf<Self> {
        Scope(state: \.grid, action: \.grid) {
            SudokuGridFeature()
                .dependency(\.sudokuGenerator, generator)
        }

        Scope(state: \.input, action: \.input) {
            SudokuInputFeature()
        }

        Scope(state: \.stats, action: \.stats) {
            SudokuStatsFeature()
        }

        Reduce { state, action in
            switch action {
            case .input(.delegate(.onErase)):
                .send(.grid(.eraseSelection))

            case let .input(.delegate(.onFill(newValue))):
                .send(.grid(.fillSelection(newValue)))

            case .input(.delegate(.onHint)):
                .send(.grid(.hintSelection))

            case let .input(.delegate(.onNote(newValue))):
                .send(.grid(.noteSelection(newValue)))

            case .grid(.cells(.element(id: _, action: .delegate(.onIncorrectFill)))):
                .send(.stats(.increaseMistakeCount))

            case .grid(.cells(.element(id: _, action: .delegate(.onCorrectFill(let value))))):
                handleCorrectFill(value, state: &state)

            case .stats(.delegate(.onPause)):
                handlePause(state: &state)

            case .menu(.presented(.delegate(.onNewGame))):
                handleNewGame(state: &state)

            case .menu(.presented(.delegate(.onRestart))):
                handleRestart(state: &state)

            case .menu(.presented(.delegate(.onResume))):
                .send(.stats(.resume))

            default:
                .none
            }
        }
        .ifLet(\.$menu, action: \.menu) {
            SudokuMenuFeature()
        }
    }

    private func handleCorrectFill(_ value: Int, state: inout State) -> Effect<Action> {
        state.digitsCount[value, default: 0] += 1

        return state.digitsCount[value] == 9 ? .send(.input(.hide(value))) : .none
    }

    private func handlePause(state: inout State) -> Effect<Action> {
        state.menu = .init(stats: state.stats)

        return .none
    }

    private func handleNewGame(state: inout State) -> Effect<Action> {
        generator.regenerateSolution()
        var newState = initialState(difficulty: state.difficulty)
        // Keep the menu state to finish the dismiss animation.
        newState.menu = state.menu

        state = newState

        return .send(.stats(.resume))
    }

    private func handleRestart(state: inout State) -> Effect<Action> {
        let (cells, digitsCount) = createCellsAndCountDigits(from: state.puzzle)
        state.digitsCount = digitsCount
        state.grid = .init(cells: .init(uniqueElements: cells))
        state.input = .init(hiddenValues: .init(digitsCount.filter { $0.value == 9 }.keys))
        state.stats = .init(difficulty: state.difficulty)

        return .send(.stats(.resume))
    }

    private func createCellsAndCountDigits(
        from puzzle: [[Int?]]
    ) -> (
        [SudokuCellFeature.State],
        [Int: Int]
    ) {
        var digitsCount: [Int: Int] = [:]
        let cells: [SudokuCellFeature.State] = puzzle.lazy
            .flatMap(\.self)
            .enumerated()
            .map { index, value in
                let row = index / 9
                let column = index % 9

                if let value {
                    digitsCount[value] = digitsCount[value, default: 0] + 1
                    return .init(content: .clue(value), row: row, column: column)
                } else {
                    return .init(content: nil, row: row, column: column)
                }
            }

        return (cells, digitsCount)
    }
}

extension SudokuFeature {
    func initialState(difficulty: SudokuGenerator.Difficulty) -> State {
        let puzzle = generator.generatePuzzle(at: difficulty)
        let (cells, digitsCount) = createCellsAndCountDigits(from: puzzle)

        return .init(
            difficulty: difficulty,
            puzzle: puzzle,
            digitsCount: digitsCount,
            grid: .init(cells: .init(uniqueElements: cells)),
            input: .init(hiddenValues: .init(digitsCount.filter { $0.value == 9 }.keys)),
            stats: .init(difficulty: difficulty)
        )
    }
}
