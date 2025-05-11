//
//  HomeView.swift
//  Sudoku
//
//  Created by Jiaxin Shou on 2023/12/28.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var sudokuModel = SudokuModel()
    @State private var selectedLevel: Level = .medium
    @State private var isGameStarted = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // 标题
                Text("数独游戏")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // 游戏图标
                Image(systemName: "square.grid.3x3.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.blue)

                // 难度选择
                VStack(alignment: .leading, spacing: 10) {
                    Text("选择难度：")
                        .font(.headline)

                    ForEach(Level.allCases) { level in
                        Button(action: {
                            selectedLevel = level
                            sudokuModel.setLevel(level)
                        }) {
                            HStack {
                                Text(level.displayName)
                                    .font(.title3)

                                Spacer()

                                if selectedLevel == level {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(
                                        selectedLevel == level
                                            ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)

                // 开始游戏按钮
                NavigationLink(destination: SudokuView(viewModel: sudokuModel)) {
                    Text("开始游戏")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                // 游戏说明
                VStack(alignment: .leading, spacing: 5) {
                    Text("游戏规则：")
                        .font(.headline)

                    Text("在每个9x9的格子中，填入1到9的数字，使得每一行、每一列和每个3x3的子方格中，1-9的数字均恰好出现一次。")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.1))
                )
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    HomeView()
}
