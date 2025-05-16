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

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Constants.verticalSpacing) {
                Text("Mistakes")

                Text(store.mistakeCount, format: .number)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: Constants.verticalSpacing) {
                Text("Level")

                Text(store.difficulty.title)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            VStack(alignment: .trailing, spacing: Constants.verticalSpacing) {
                Text("Time")

                Text(
                    Duration.seconds(store.elapsedTime),
                    format: .time(pattern: .minuteSecond)
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

private extension SudokuGenerator.Difficulty {
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
