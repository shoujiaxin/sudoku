//
//  SudokuMenu.swift
//  Sudoku
//
//  Created by Jiaxin Shou on 2025/5/17.
//

import ComposableArchitecture
import SwiftUI

struct SudokuMenu: View {
    let store: StoreOf<SudokuMenuFeature>

    private enum Constants {
        static let iconSize: CGFloat = 20
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Paused")
                .font(.title)

            statsView

            Divider()

            VStack(spacing: 16) {
                Button {
                    store.send(.restart)
                } label: {
                    HStack {
                        Text("Restart")
                            .frame(maxWidth: .infinity)

                        Image(.refreshCcw)
                            .resizable()
                            .frame(width: Constants.iconSize, height: Constants.iconSize)
                    }
                }

                Button {
                    store.send(.newGame)
                } label: {
                    HStack {
                        Text("New Game")
                            .frame(maxWidth: .infinity)

                        Image(.plus)
                            .resizable()
                            .frame(width: Constants.iconSize, height: Constants.iconSize)
                    }
                }

                Button {
                    store.send(.resume)
                } label: {
                    HStack {
                        Text("Resume")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)

                        Image(.playFill)
                            .resizable()
                            .frame(width: Constants.iconSize, height: Constants.iconSize)
                    }
                }
                .foregroundStyle(.tint)
            }
            .buttonStyle(SudokuPauseButtonStyle())
        }
        .frame(width: 300)
        .padding(24)
        .background(.background, in: .rect(cornerRadius: 16))
    }

    private var statsView: some View {
        HStack {
            VStack(spacing: 8) {
                Text("Mistakes")
                    .font(.callout)

                Text(store.stats.mistakeCount, format: .number)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: 8) {
                Text("Level")
                    .font(.callout)

                Text(store.stats.difficulty.title)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: 8) {
                Text("Time")
                    .font(.callout)

                Text(
                    Duration.seconds(store.stats.elapsedTime),
                    format: .time(pattern: .minuteSecond)
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

private struct SudokuPauseButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(.quaternary, in: .rect(cornerRadius: 8))
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}

#if DEBUG

#Preview {
    ZStack {
        Color.gray
            .ignoresSafeArea()

        SudokuMenu(
            store: .init(initialState: SudokuMenuFeature.State(stats: .init(
                difficulty: .medium,
                elapsedTime: 100,
                mistakeCount: 2
            ))) {
                SudokuMenuFeature()
            }
        )
    }
}

#endif
