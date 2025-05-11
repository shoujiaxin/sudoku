//
//  HomeView.swift
//  Sudoku
//
//  Created by Jiaxin Shou on 2023/12/28.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // 标题
                VStack(spacing: 10) {
                    Text("数独")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.primary)

                    Text("选择难度开始游戏")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 60)

                Spacer()

                // 难度选择
                VStack(spacing: 20) {
                    ForEach(Level.allCases) { level in
                        NavigationLink(destination: SudokuView(level: level)) {
                            LevelButtonView(level: level)
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                // 底部信息
                VStack {
                    Text("© 2025 Jiaxin Shou")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 20)
            }
            .background(
                Image(systemName: "number.square")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(0.05)
                    .rotationEffect(.degrees(30))
                    .offset(y: -50)
            )
        }
    }
}

struct LevelButtonView: View {
    let level: Level

    var body: some View {
        HStack {
            Text(level.rawValue)
                .font(.title)
                .bold()

            Spacer()

            Image(systemName: difficultyIcon)
                .font(.title2)
        }
        .foregroundColor(.white)
        .padding()
        .frame(maxWidth: .infinity)
        .background(difficultyColor)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(radius: 5)
    }

    private var difficultyColor: Color {
        switch level {
        case .easy:
            .green
        case .medium:
            .orange
        case .hard:
            .red
        }
    }

    private var difficultyIcon: String {
        switch level {
        case .easy:
            "1.circle"
        case .medium:
            "2.circle"
        case .hard:
            "3.circle"
        }
    }
}

#Preview {
    HomeView()
}
