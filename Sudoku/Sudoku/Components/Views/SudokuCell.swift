//
//  SudokuCell.swift
//  Sudoku
//
//  Created by Jiaxin Shou on 2025/5/13.
//

import ComposableArchitecture
import SwiftUI

struct SudokuCell: View {
    let store: StoreOf<SudokuCellFeature>

    var selection: StoreOf<SudokuCellFeature>? = nil

    var body: some View {
        content
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .font(.system(size: 40))
            .minimumScaleFactor(0.01)
            .contentShape(.rect)
            .background {
                if let selection = selection?.state {
                    background(selection: selection)
                }
            }
    }

    // MARK: - Contents

    @ViewBuilder
    private var content: some View {
        switch store.content {
        case .none:
            Color.clear

        case let .candidates(values):
            candidatesContent(Array(values).sorted())

        case let .clue(value):
            clueContent(value)

        case let .mistake(value):
            mistakeContent(value)

        case let .solution(value):
            solutionContent(value)
        }
    }

    private func candidatesContent(_ values: some RandomAccessCollection<Int>) -> some View {
        GeometryReader { geometry in
            let size = geometry.size
            let itemSize = min(size.width, size.height) / 3

            LazyVGrid(
                columns: .init(repeating: .init(.fixed(itemSize), spacing: 0), count: 3),
                spacing: 0
            ) {
                ForEach(1 ... 9, id: \.self) { value in
                    if values.contains(value) {
                        Text(value, format: .number)
                            .font(.system(
                                size: 12,
                                weight: selection?.content?.value == value ? .bold : .regular
                            ))
                            .foregroundStyle(selection?.content?.value == value ? Color.accentColor : .secondary)
                    } else {
                        Color.clear
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding(by: 0.025)
    }

    private func clueContent(_ value: Int) -> some View {
        Text(value, format: .number)
            .padding(by: 0.1)
    }

    private func mistakeContent(_ value: Int) -> some View {
        Text(value, format: .number)
            .fontWeight(.semibold)
            .foregroundStyle(.red)
            .padding(by: 0.1)
    }

    private func solutionContent(_ value: Int) -> some View {
        Text(value, format: .number)
            .fontWeight(.semibold)
            .foregroundStyle(.tint)
            .padding(by: 0.1)
    }

    // MARK: - Backgrounds

    @ViewBuilder
    private func background(selection: SudokuCellFeature.State) -> some View {
        if selection.id == store.id {
            selectionBackground
        } else if selection.isPeer(with: store.state) {
            peerBackground(with: selection)
        } else {
            groupBackground(with: selection)
        }
    }

    /// Background for the selected cell.
    private var selectionBackground: some View {
        Color.accentColor
            .opacity(0.3)
    }

    /// Background for cells in the same row, column, and box as the selected cell.
    @ViewBuilder
    private func peerBackground(with selection: SudokuCellFeature.State) -> some View {
        switch (selection.content, store.content) {
        case let (.solution(v1), .mistake(v2)),
             let (.mistake(v1), .solution(v2)),
             let (.mistake(v1), .mistake(v2)),
             let (.mistake(v1), .clue(v2)),
             let (.clue(v1), .mistake(v2)):
            if v1 == v2 {
                Color.red
                    .opacity(0.1)
            } else {
                Color.accentColor
                    .opacity(0.1)
            }

        default:
            Color.accentColor
                .opacity(0.1)
        }
    }

    /// Background for cells have the same value as the selected cell, but are not in the same row, column, or box.
    @ViewBuilder
    private func groupBackground(with selection: SudokuCellFeature.State) -> some View {
        switch (selection.content, store.content) {
        case let (.solution(v1), .solution(v2)),
             let (.solution(v1), .clue(v2)),
             let (.mistake(v1), .solution(v2)),
             let (.mistake(v1), .clue(v2)),
             let (.clue(v1), .solution(v2)),
             let (.clue(v1), .clue(v2)):
            if v1 == v2 {
                Color.accentColor
                    .opacity(0.2)
            }

        default:
            EmptyView()
        }
    }
}

private struct RelativePadding: ViewModifier {
    let ratio: CGFloat

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            let size = geometry.size
            let padding = max(size.width, size.height) * ratio

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(padding)
        }
    }
}

private extension View {
    func padding(by ratio: CGFloat) -> some View {
        modifier(RelativePadding(ratio: ratio))
    }
}
