//
//  SudokuStatsView.swift
//  Sudoku
//
//  Created by Jiaxin Shou on 2025/5/17.
//

import ComposableArchitecture
import SwiftUI

struct SudokuStatsView: View {
    let store: StoreOf<SudokuStatsFeature>

    private enum Constants {
        static let verticalSpacing: CGFloat = 8
    }

    @Environment(\.scenePhase)
    private var scenePhase

    var body: some View {
        VStack {
            Button {
                store.send(.pause, animation: .smooth(duration: 0.25))
            } label: {
                HStack {
                    Text(
                        Duration.seconds(store.elapsedTime),
                        format: .time(pattern: .minuteSecond)
                    )

                    Image(systemName: "pause.fill")
                }
                .foregroundStyle(.tint)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.tertiary, lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
        }
        .monospacedDigit()

        Button {
            store.send(.pause, animation: .smooth(duration: 0.25))
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: Constants.verticalSpacing) {
                    Text("Mistakes")
                        .font(.callout)

                    Text(store.mistakeCount, format: .number)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: Constants.verticalSpacing) {
                    Text("Level")
                        .font(.callout)

                    Text(store.difficulty.title)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                VStack(alignment: .trailing, spacing: Constants.verticalSpacing) {
                    Text("Time")
                        .font(.callout)

                    Text(
                        Duration.seconds(store.elapsedTime),
                        format: .time(pattern: .minuteSecond)
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(8)
        }
        .buttonStyle(.bordered)
        .foregroundStyle(.primary)
        .monospacedDigit()
        .onChange(of: scenePhase, initial: true) { oldValue, newValue in
            switch (oldValue, newValue) {
            case (.active, _):
                store.send(.pause, animation: .smooth(duration: 0.25))

            case (_, .active):
                store.send(.resume)

            default:
                break
            }
        }
    }
}

extension SudokuGenerator.Difficulty {
    var title: LocalizedStringKey {
        switch self {
        case .easy:
            "Easy"

        case .medium:
            "Medium"

        case .hard:
            "Hard"

        case .expert:
            "Expert"
        }
    }
}
