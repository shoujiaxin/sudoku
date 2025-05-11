//
//  SudokuModel.swift
//  Sudoku
//
//  Created by GitHub Copilot on 2025/05/12.
//

import Foundation

class SudokuModel: ObservableObject {
    // 数独棋盘大小
    static let size = 9
    static let boxSize = 3

    // 棋盘状态
    @Published var board: [[Cell]]
    @Published var selectedCell: (row: Int, col: Int)?
    @Published var isCompleted: Bool = false
    @Published var level: Level
    @Published var elapsedTime: Int = 0
    @Published var mistakes: Int = 0
    @Published var hints: Int = 3

    // 计时器
    private var timer: Timer?

    init(level: Level = .easy) {
        self.level = level
        self.board = Array(
            repeating: Array(repeating: Cell(), count: SudokuModel.size), count: SudokuModel.size)
        generateNewPuzzle()
    }

    func generateNewPuzzle() {
        // 重置状态
        stopTimer()
        elapsedTime = 0
        mistakes = 0
        hints = 3
        isCompleted = false
        selectedCell = nil

        // 生成完整的数独解
        generateSolution()

        // 根据难度级别移除部分数字
        removeCells(count: level.cellsToRemove)

        // 启动计时器
        startTimer()
    }

    // 生成完整的数独解答
    private func generateSolution() {
        // 创建一个空数独板
        board = Array(
            repeating: Array(repeating: Cell(), count: SudokuModel.size), count: SudokuModel.size)

        // 使用回溯法填充数独解
        _ = solveSudoku(board: &board, createMode: true)

        // 标记所有单元格为初始值
        for row in 0..<SudokuModel.size {
            for col in 0..<SudokuModel.size {
                board[row][col].isInitial = true
                board[row][col].isCorrect = true
            }
        }
    }

    // 随机移除单元格的值
    private func removeCells(count: Int) {
        var positions = [(Int, Int)]()

        // 创建所有格子的位置
        for row in 0..<SudokuModel.size {
            for col in 0..<SudokuModel.size {
                positions.append((row, col))
            }
        }

        // 随机打乱位置
        positions.shuffle()

        // 移除指定数量的单元格值
        for i in 0..<count {
            if i < positions.count {
                let (row, col) = positions[i]
                let correctValue = board[row][col].value
                board[row][col].value = 0
                board[row][col].isInitial = false
                // 储存正确答案用于校验
                board[row][col].correctValue = correctValue
            }
        }
    }

    // 玩家填入数字
    func setValueForSelectedCell(_ value: Int) {
        guard let selectedCell = selectedCell else { return }
        let row = selectedCell.row
        let col = selectedCell.col

        // 如果是初始单元格，不允许修改
        if board[row][col].isInitial {
            return
        }

        board[row][col].value = value

        // 检查填入的值是否正确
        let isCorrect = board[row][col].correctValue == value
        board[row][col].isCorrect = isCorrect

        if !isCorrect {
            mistakes += 1
        }

        // 检查游戏是否已完成
        checkCompletion()
    }

    // 使用提示功能
    func useHint() {
        guard let selectedCell = selectedCell, hints > 0 else { return }
        let row = selectedCell.row
        let col = selectedCell.col

        // 如果是初始单元格或已经填入正确的值，不使用提示
        if board[row][col].isInitial || board[row][col].value == board[row][col].correctValue {
            return
        }

        // 减少提示次数并填入正确的值
        hints -= 1
        board[row][col].value = board[row][col].correctValue
        board[row][col].isCorrect = true

        // 检查游戏是否已完成
        checkCompletion()
    }

    // 检查游戏是否完成
    private func checkCompletion() {
        for row in 0..<SudokuModel.size {
            for col in 0..<SudokuModel.size {
                if board[row][col].value != board[row][col].correctValue {
                    isCompleted = false
                    return
                }
            }
        }
        isCompleted = true
        stopTimer()
    }

    // 回溯法解数独
    private func solveSudoku(board: inout [[Cell]], createMode: Bool = false) -> Bool {
        for row in 0..<SudokuModel.size {
            for col in 0..<SudokuModel.size {
                if board[row][col].value == 0 {
                    // 创建一个随机的数字尝试顺序（仅在创建新谜题时使用随机顺序）
                    var numbers = Array(1...SudokuModel.size)
                    if createMode {
                        numbers.shuffle()
                    }

                    for num in numbers {
                        if isValidPlacement(board: board, row: row, col: col, num: num) {
                            board[row][col].value = num

                            if solveSudoku(board: &board, createMode: createMode) {
                                return true
                            }

                            board[row][col].value = 0
                        }
                    }
                    return false
                }
            }
        }
        return true
    }

    // 检查在特定位置放置数字是否有效
    private func isValidPlacement(board: [[Cell]], row: Int, col: Int, num: Int) -> Bool {
        // 检查行
        for i in 0..<SudokuModel.size {
            if board[row][i].value == num {
                return false
            }
        }

        // 检查列
        for i in 0..<SudokuModel.size {
            if board[i][col].value == num {
                return false
            }
        }

        // 检查3x3子格
        let startRow = (row / SudokuModel.boxSize) * SudokuModel.boxSize
        let startCol = (col / SudokuModel.boxSize) * SudokuModel.boxSize

        for i in 0..<SudokuModel.boxSize {
            for j in 0..<SudokuModel.boxSize {
                if board[startRow + i][startCol + j].value == num {
                    return false
                }
            }
        }

        return true
    }

    // 启动计时器
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedTime += 1
        }
    }

    // 停止计时器
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // 格式化时间显示
    var formattedTime: String {
        let minutes = elapsedTime / 60
        let seconds = elapsedTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // 选择单元格
    func selectCell(row: Int, col: Int) {
        selectedCell = (row, col)
    }

    // 重置游戏
    func resetPuzzle() {
        for row in 0..<SudokuModel.size {
            for col in 0..<SudokuModel.size {
                if !board[row][col].isInitial {
                    board[row][col].value = 0
                    board[row][col].isCorrect = true
                }
            }
        }
        mistakes = 0
        isCompleted = false
    }

    // 设置难度并生成新谜题
    func setLevel(_ newLevel: Level) {
        level = newLevel
        generateNewPuzzle()
    }
}

// 代表数独中的一个单元格
struct Cell: Identifiable {
    var id = UUID()
    var value: Int = 0
    var correctValue: Int = 0  // 正确答案
    var isInitial: Bool = false  // 是否是初始值
    var isCorrect: Bool = true  // 玩家填入的值是否正确
    var notes: Set<Int> = []  // 标记可能的值
}
