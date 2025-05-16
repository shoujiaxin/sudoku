//
//  SudokuGrid.swift
//  Sudoku
//
//  Created by Jiaxin Shou on 2025/5/14.
//

import ComposableArchitecture
import SwiftUI

struct SudokuGrid: View {
    let store: StoreOf<SudokuGridFeature>

    var body: some View {
        // TODO: drag gesture
        GeometryReader { geometry in
            let size = geometry.size
            let cellSize = min(size.width, size.height) / 9

            LazyVGrid(
                columns: .init(repeating: .init(.fixed(cellSize), spacing: 0), count: 9),
                spacing: 0
            ) {
                let selectionScope: StoreOf<SudokuCellFeature>? = store.scope(
                    state: \.cells[id: store.selection],
                    action: \.cells[id: store.selection]
                )

                ForEach(store.scope(state: \.cells, action: \.cells)) { cell in
                    SudokuCell(store: cell, selection: selectionScope)
                        .onTapGesture {
                            store.send(.select(cell.id))
                        }
                }
            }
            .monospaced()
        }
        .aspectRatio(1, contentMode: .fit)
        .background {
            gridLines
        }
    }

    private var gridLines: some View {
        GeometryReader { geometry in
            let size = geometry.size

            ZStack {
                secondaryGridLines(size: size)

                primaryGridLines(size: size)
            }
        }
    }

    @ViewBuilder
    private func primaryGridLines(size: CGSize) -> some View {
        let lineWidth: CGFloat = 2
        let inset = lineWidth / 2

        Path { path in
            let cellWidth = size.width / 9
            let cellHeight = size.height / 9

            for i in stride(from: 0, through: 9, by: 3) {
                let x = cellWidth * CGFloat(i)
                path.move(to: .init(x: x, y: -inset))
                path.addLine(to: .init(x: x, y: size.height + inset))

                let y = cellHeight * CGFloat(i)
                path.move(to: .init(x: -inset, y: y))
                path.addLine(to: .init(x: size.width + inset, y: y))
            }
        }
        .stroke(.primary, lineWidth: lineWidth)
    }

    private func secondaryGridLines(size: CGSize) -> some View {
        Path { path in
            let cellWidth = size.width / 9
            let cellHeight = size.height / 9

            for i in 0 ... 9 {
                if i % 3 == 0 {
                    continue
                }
                let x = cellWidth * CGFloat(i)
                path.move(to: .init(x: x, y: 0))
                path.addLine(to: .init(x: x, y: size.height))

                let y = cellHeight * CGFloat(i)
                path.move(to: .init(x: 0, y: y))
                path.addLine(to: .init(x: size.width, y: y))
            }
        }
        .stroke(.secondary, lineWidth: 0.5)
    }
}
