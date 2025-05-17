//
//  SudokuGenerator.swift
//  Sudoku
//
//  Created by Jiaxin Shou on 2025/5/14.
//

import Foundation

// TODO: actor
class SudokuGenerator {
    enum Difficulty: CaseIterable {
        case easy

        case medium

        case hard

        case expert

        var numberOfEmptyCells: ClosedRange<Int> {
            switch self {
            case .easy:
                36 ... 40
            case .medium:
                45 ... 50
            case .hard:
                52 ... 56
            case .expert:
                58 ... 62
            }
        }
    }

    private var solution: [[Int]]

    init() {
        solution = Self.generateSolution()
    }

    // MARK: - Public

    func generatePuzzle(at difficulty: Difficulty) -> [[Int?]] {
        var positions: [(Int, Int)] = []
        for row in 0 ..< 9 {
            for column in 0 ..< 9 {
                positions.append((row, column))
            }
        }
        positions.shuffle()

        let numberOfEmptyCells = Int.random(in: difficulty.numberOfEmptyCells)
        var removedCellCount = 0
        var grid: [[Int?]] = solution
        for (row, column) in positions {
            let value = grid[row][column]
            grid[row][column] = nil

            // TODO: unique solution
            if Self.isSolvable(grid: grid) {
                removedCellCount += 1
                if removedCellCount >= numberOfEmptyCells {
                    break
                }
            } else {
                grid[row][column] = value
            }
        }

        return grid
    }

    func validate(value: Int, row: Int, column: Int) -> Bool {
        solution[row][column] == value
    }

    func value(row: Int, column: Int) -> Int {
        solution[row][column]
    }

    func regenerateSolution() {
        solution = Self.generateSolution()
    }

    // MARK: - Private

    private static func generateSolution() -> [[Int]] {
        var grid: [[Int]] = .init(repeating: .init(repeating: 0, count: 9), count: 9)

//        for i in stride(from: 0, to: 9, by: 3) {
//            fillBox(startRow: i, startCol: i)
//        }

        let solved = solveSudoku(&grid)
        assert(solved, "Failed to generate a valid Sudoku solution.")

        return grid
    }

//    private mutating func fillBox(startRow: Int, startCol: Int) {
//        let digits = (1 ... 9).shuffled()
//
//        var index = 0
//        for i in 0 ..< 3 {
//            for j in 0 ..< 3 {
//                solution[startRow + i][startCol + j] = digits[index]
//                index += 1
//            }
//        }
//    }

    private static func isSolvable(grid: [[Int?]]) -> Bool {
        var temp = grid.map { row in row.map { $0 ?? 0 } }
        return Self.solveSudoku(&temp)
    }

    // MARK: - Solver

    private static func solveSudoku(_ grid: inout [[Int]]) -> Bool {
        for row in 0 ..< 9 {
            for column in 0 ..< 9 {
                guard grid[row][column] == 0 else {
                    continue
                }

                for value in (1 ... 9).shuffled() {
                    guard validate(grid: grid, row: row, column: column, value: value) else {
                        continue
                    }

                    grid[row][column] = value

                    if solveSudoku(&grid) {
                        return true
                    }

                    grid[row][column] = 0
                }

                return false
            }
        }

        return true
    }

    private static func validate(grid: [[Int]], row: Int, column: Int, value: Int) -> Bool {
        for i in 0 ..< 9 {
            if grid[row][i] == value || grid[i][column] == value {
                return false
            }
        }

        let startRow = row / 3 * 3
        let startColumn = column / 3 * 3
        for i in 0 ..< 3 {
            for j in 0 ..< 3 {
                if grid[i + startRow][j + startColumn] == value {
                    return false
                }
            }
        }

        return true
    }
}

// Extension to convert Sudoku grid to SudokuCell states
// extension SudokuGenerator {
//    func generateCellStates(difficulty: SudokuDifficulty) -> [SudokuCellFeature.State] {
//        let grid = generatePuzzle(difficulty: difficulty)
//
//        var cells = [SudokuCellFeature.State]()
//
//        for row in 0 ..< 9 {
//            for col in 0 ..< 9 {
//                let content: SudokuCellFeature.State.Content? = if let value = grid[row][col] {
//                    .given(value)
//                } else {
//                    nil
//                }
//
//                cells.append(SudokuCellFeature.State(content: content, row: row, column: col))
//            }
//        }
//
//        return cells
//    }
// }
