//
//  SudokuView.swift
//  Sudoku
//
//  Created by Jiaxin Shou on 2025/5/12.
//

import SwiftUI

struct SudokuView: View {
    @StateObject var viewModel: SudokuModel
    @Environment(\.dismiss) private var dismiss

    init(level: Level) {
        let model = SudokuModel()
        model.resetGame(level: level)
        _viewModel = StateObject(wrappedValue: model)
    }

    var body: some View {
        VStack(spacing: 20) {
            // 顶部信息栏
            HStack {
                VStack(alignment: .leading) {
                    Text("难度: \(viewModel.level.rawValue)")
                        .font(.headline)
                    Text("错误: \(viewModel.mistakes)")
                        .foregroundColor(.red)
                }

                Spacer()

                Text(viewModel.formattedTime)
                    .font(.title2)
                    .monospacedDigit()
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray6))
                    )
            }
            .padding()

            // 数独网格
            SudokuGridView(viewModel: viewModel)
                .aspectRatio(1, contentMode: .fit)
                .padding()

            // 数字输入键盘
            NumberPadView(viewModel: viewModel)
                .padding()

            // 按钮区域
            HStack {
                Button("返回") {
                    dismiss()
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("清除") {
                    viewModel.clearCell()
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("重新开始") {
                    viewModel.resetGame(level: viewModel.level)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("数独游戏")
        .navigationBarTitleDisplayMode(.inline)
        .alert("恭喜!", isPresented: Binding<Bool>(
            get: { viewModel.isComplete },
            set: { _ in }
        )) {
            Button("返回主页") {
                dismiss()
            }
            Button("再玩一次") {
                viewModel.resetGame(level: viewModel.level)
            }
        } message: {
            Text("你已经成功完成了这个数独游戏!\n时间: \(viewModel.formattedTime)\n错误数: \(viewModel.mistakes)")
        }
    }
}

struct SudokuGridView: View {
    @ObservedObject var viewModel: SudokuModel

    var body: some View {
        VStack(spacing: 1) {
            ForEach(0 ..< 9) { row in
                HStack(spacing: 1) {
                    ForEach(0 ..< 9) { col in
                        CellView(
                            cell: viewModel.grid[row][col],
                            isSelected: viewModel.selectedCell?.row == row && viewModel.selectedCell?.col == col,
                            onTap: {
                                viewModel.select(row: row, col: col)
                            }
                        )
                    }
                }
            }
        }
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            GeometryReader { geometry in
                // 显示3x3的粗边框
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height

                    // 横线
                    for i in 1 ... 2 {
                        let y = height / 3 * CGFloat(i)
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: width, y: y))
                    }

                    // 竖线
                    for i in 1 ... 2 {
                        let x = width / 3 * CGFloat(i)
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: height))
                    }
                }
                .stroke(Color.black, lineWidth: 3)
            }
        )
    }
}

struct CellView: View {
    let cell: Cell
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Text(cell.value > 0 ? "\(cell.value)" : "")
            .font(.system(size: 20, weight: cell.isGiven ? .bold : .regular))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .foregroundColor(cellTextColor)
            .background(cellBackgroundColor)
            .contentShape(Rectangle())
            .onTapGesture(perform: onTap)
    }

    private var cellBackgroundColor: Color {
        if isSelected {
            Color.blue.opacity(0.3)
        } else if cell.hasError {
            Color.red.opacity(0.2)
        } else if cell.isGiven {
            Color(.systemBackground)
        } else if cell.value > 0 {
            Color(.systemGray6)
        } else {
            Color(.systemBackground)
        }
    }

    private var cellTextColor: Color {
        if cell.hasError {
            .red
        } else if cell.isGiven {
            .primary
        } else {
            .blue
        }
    }
}

struct NumberPadView: View {
    @ObservedObject var viewModel: SudokuModel

    var body: some View {
        VStack {
            HStack {
                ForEach(1 ... 5, id: \.self) { number in
                    numberButton(number)
                }
            }

            HStack {
                ForEach(6 ... 9, id: \.self) { number in
                    numberButton(number)
                }

                Button(action: {
                    viewModel.clearCell()
                }) {
                    Image(systemName: "delete.left")
                        .font(.title)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
            }
        }
    }

    private func numberButton(_ number: Int) -> some View {
        Button(action: {
            viewModel.enter(number: number)
        }) {
            Text("\(number)")
                .font(.title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
        }
    }
}

#Preview {
    NavigationStack {
        SudokuView(level: .easy)
    }
}
