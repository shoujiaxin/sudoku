//
//  SudokuModel.swift
//  Sudoku
//
//  Created by Jiaxin Shou on 2025/5/12.
//

import Foundation
import SwiftUI

class SudokuModel: ObservableObject {
    // 9x9数独棋盘
    @Published
    var grid: [[Cell]] = []

    @Published
    var selectedCell: (row: Int, col: Int)? = nil

    @Published
    var isComplete: Bool = false

    @Published
    var level: Level = .easy

    @Published
    var timerCount: Int = 0

    @Published
    var mistakes: Int = 0

    @Published
    var isGameActive: Bool = false

    private var timer: Timer?
    private var solution: [[Int]] = []

    init() {
        resetGame(level: .easy)
    }

    deinit {
        stopTimer()
    }

    func resetGame(level: Level) {
        self.level = level
        selectedCell = nil
        isComplete = false
        timerCount = 0
        mistakes = 0

        stopTimer()
        generateNewPuzzle(level: level)
        isGameActive = true
        startTimer()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            timerCount += 1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func select(row: Int, col: Int) {
        if grid[row][col].isGiven {
            return // 不允许选择初始给定的单元格
        }
        selectedCell = (row, col)
    }

    func enter(number: Int) {
        guard let (row, col) = selectedCell, !grid[row][col].isGiven else {
            return
        }

        if solution[row][col] == number {
            grid[row][col].value = number
            grid[row][col].isCorrect = true
            grid[row][col].hasError = false
            checkCompletion()
        } else {
            grid[row][col].value = number
            grid[row][col].hasError = true
            grid[row][col].isCorrect = false
            mistakes += 1
        }
    }

    func clearCell() {
        guard let (row, col) = selectedCell, !grid[row][col].isGiven else {
            return
        }

        grid[row][col].value = 0
        grid[row][col].hasError = false
    }

    private func checkCompletion() {
        // 检查所有单元格是否填满且正确
        let complete = grid.allSatisfy { row in
            row.allSatisfy { cell in
                cell.value != 0 && !cell.hasError
            }
        }

        if complete {
            isComplete = true
            stopTimer()
        }
    }

    private func generateNewPuzzle(level: Level) {
        // 生成完整的数独解决方案
        generateSolution()

        // 复制解决方案以创建初始网格
        grid = Array(repeating: Array(repeating: Cell(value: 0), count: 9), count: 9)

        for row in 0 ..< 9 {
            for col in 0 ..< 9 {
                grid[row][col].value = solution[row][col]
                grid[row][col].isGiven = true
                grid[row][col].isCorrect = true
            }
        }

        // 根据难度级别移除一定数量的单元格
        removeNumbers(count: level.emptyCellsCount)
    }

    private func generateSolution() {
        solution = Array(repeating: Array(repeating: 0, count: 9), count: 9)

        // 先填入一些随机数字
        fillDiagonalBoxes()

        // 解决其余部分
        solveSudoku()
    }

    private func fillDiagonalBoxes() {
        // 填充对角线上的3个3x3的方块
        for i in stride(from: 0, to: 9, by: 3) {
            fillBox(row: i, col: i)
        }
    }

    private func fillBox(row: Int, col: Int) {
        var nums = Array(1 ... 9)
        nums.shuffle()

        var index = 0
        for i in 0 ..< 3 {
            for j in 0 ..< 3 {
                solution[row + i][col + j] = nums[index]
                index += 1
            }
        }
    }

    private func solveSudoku() -> Bool {
        for row in 0 ..< 9 {
            for col in 0 ..< 9 {
                if solution[row][col] == 0 {
                    for num in 1 ... 9 {
                        if isSafe(row: row, col: col, num: num) {
                            solution[row][col] = num

                            if solveSudoku() {
                                return true
                            }

                            solution[row][col] = 0 // 回溯
                        }
                    }
                    return false
                }
            }
        }
        return true
    }

    private func isSafe(row: Int, col: Int, num: Int) -> Bool {
        // 检查行
        for i in 0 ..< 9 {
            if solution[row][i] == num {
                return false
            }
        }

        // 检查列
        for i in 0 ..< 9 {
            if solution[i][col] == num {
                return false
            }
        }

        // 检查3x3方块
        let boxRow = row - row % 3
        let boxCol = col - col % 3

        for i in 0 ..< 3 {
            for j in 0 ..< 3 {
                if solution[boxRow + i][boxCol + j] == num {
                    return false
                }
            }
        }

        return true
    }

    private func removeNumbers(count: Int) {
        var emptyCells = count

        while emptyCells > 0 {
            let row = Int.random(in: 0 ..< 9)
            let col = Int.random(in: 0 ..< 9)

            if grid[row][col].value != 0 {
                grid[row][col].value = 0
                grid[row][col].isGiven = false
                emptyCells -= 1
            }
        }
    }

    // 格式化计时器显示
    var formattedTime: String {
        let minutes = timerCount / 60
        let seconds = timerCount % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct Cell {
    var value: Int = 0
    var isGiven: Bool = false
    var isCorrect: Bool = false
    var hasError: Bool = false
}
