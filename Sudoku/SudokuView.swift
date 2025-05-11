//
//  SudokuView.swift
//  Sudoku
//
//  Created by GitHub Copilot on 2025/05/12.
//

import SwiftUI

struct SudokuView: View {
    @ObservedObject var viewModel: SudokuModel
    @State private var showingCompletionAlert = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // 根据屏幕尺寸计算单元格大小
    private var cellSize: CGFloat {
        horizontalSizeClass == .compact ? 35 : 45
    }

    var body: some View {
        VStack(spacing: 10) {
            // 游戏信息区域
            HStack {
                VStack(alignment: .leading) {
                    Text("难度：\(viewModel.level.displayName)")
                        .font(.headline)

                    Text("时间：\(viewModel.formattedTime)")
                        .font(.subheadline)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("错误：\(viewModel.mistakes)")
                        .font(.subheadline)
                        .foregroundColor(viewModel.mistakes > 0 ? .red : .primary)

                    Text("提示：\(viewModel.hints)次")
                        .font(.subheadline)
                }
            }
            .padding(.horizontal)

            // 数独棋盘
            VStack(spacing: 1) {
                ForEach(0..<3, id: \.self) { boxRow in
                    HStack(spacing: 1) {
                        ForEach(0..<3, id: \.self) { boxCol in
                            SudokuBoxView(
                                viewModel: viewModel,
                                boxRow: boxRow,
                                boxCol: boxCol,
                                cellSize: cellSize
                            )
                        }
                    }
                }
            }
            .background(Color.black)
            .padding()

            // 数字键盘
            NumberPadView(viewModel: viewModel)

            // 操作按钮
            HStack(spacing: 20) {
                Button(action: {
                    viewModel.useHint()
                }) {
                    VStack {
                        Image(systemName: "lightbulb.fill")
                            .font(.title2)
                        Text("提示")
                            .font(.caption)
                    }
                }
                .disabled(viewModel.hints <= 0)

                Button(action: {
                    viewModel.resetPuzzle()
                }) {
                    VStack {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title2)
                        Text("重置")
                            .font(.caption)
                    }
                }

                Button(action: {
                    viewModel.generateNewPuzzle()
                }) {
                    VStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.title2)
                        Text("新游戏")
                            .font(.caption)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("数独")
        .alert("恭喜！", isPresented: $showingCompletionAlert) {
            Button("新游戏") {
                viewModel.generateNewPuzzle()
            }
            Button("返回主页", role: .cancel) {}
        } message: {
            Text(
                "你成功完成了\(viewModel.level.displayName)难度的数独！\n用时：\(viewModel.formattedTime)\n错误：\(viewModel.mistakes)次"
            )
        }
        .onChange(of: viewModel.isCompleted) { _, completed in
            if completed {
                showingCompletionAlert = true
            }
        }
    }
}

struct SudokuBoxView: View {
    @ObservedObject var viewModel: SudokuModel
    let boxRow: Int
    let boxCol: Int
    let cellSize: CGFloat

    var body: some View {
        VStack(spacing: 1) {
            ForEach(0..<3, id: \.self) { i in
                HStack(spacing: 1) {
                    ForEach(0..<3, id: \.self) { j in
                        let row = boxRow * 3 + i
                        let col = boxCol * 3 + j
                        SudokuCellView(
                            cell: viewModel.board[row][col],
                            isSelected: viewModel.selectedCell?.row == row
                                && viewModel.selectedCell?.col == col,
                            cellSize: cellSize
                        )
                        .onTapGesture {
                            viewModel.selectCell(row: row, col: col)
                        }
                    }
                }
            }
        }
        .background(Color(uiColor: .systemGray6))
    }
}

struct SudokuCellView: View {
    let cell: Cell
    let isSelected: Bool
    let cellSize: CGFloat

    var body: some View {
        ZStack {
            Rectangle()
                .fill(backgroundColor)
                .frame(width: cellSize, height: cellSize)

            if cell.value != 0 {
                Text("\(cell.value)")
                    .font(.system(size: cellSize * 0.6, weight: cell.isInitial ? .bold : .regular))
                    .foregroundColor(textColor)
            }
        }
    }

    private var backgroundColor: Color {
        if isSelected {
            return Color.blue.opacity(0.3)
        } else if !cell.isCorrect {
            return Color.red.opacity(0.2)
        } else {
            return Color.white
        }
    }

    private var textColor: Color {
        if !cell.isCorrect {
            return .red
        } else if cell.isInitial {
            return .black
        } else {
            return .blue
        }
    }
}

struct NumberPadView: View {
    @ObservedObject var viewModel: SudokuModel

    var body: some View {
        VStack {
            HStack {
                ForEach(1...5, id: \.self) { number in
                    NumberButton(number: number) {
                        viewModel.setValueForSelectedCell(number)
                    }
                }
            }

            HStack {
                ForEach(6...9, id: \.self) { number in
                    NumberButton(number: number) {
                        viewModel.setValueForSelectedCell(number)
                    }
                }

                // 擦除按钮
                NumberButton(symbol: "xmark") {
                    viewModel.setValueForSelectedCell(0)
                }
            }
        }
    }
}

struct NumberButton: View {
    var number: Int?
    var symbol: String?
    let action: () -> Void

    init(number: Int, action: @escaping () -> Void) {
        self.number = number
        self.action = action
    }

    init(symbol: String, action: @escaping () -> Void) {
        self.symbol = symbol
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 44, height: 44)

                if let number = number {
                    Text("\(number)")
                        .font(.title2)
                } else if let symbol = symbol {
                    Image(systemName: symbol)
                        .font(.title2)
                }
            }
        }
        .padding(5)
    }
}
