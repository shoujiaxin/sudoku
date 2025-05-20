//
//  SudokuView.swift
//  Sudoku
//
//  Created by Jiaxin Shou on 2025/5/15.
//

import ComposableArchitecture
import SwiftUI

struct SudokuView: View {
    @Bindable
    private var store: StoreOf<SudokuFeature>

    init(difficulty: SudokuGenerator.Difficulty) {
        let reducer = SudokuFeature()

        store = .init(initialState: reducer.initialState(difficulty: difficulty)) {
            reducer
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                SudokuStatsView(store: store.scope(
                    state: \.stats,
                    action: \.stats
                ))

                SudokuGrid(store: store.scope(
                    state: \.grid,
                    action: \.grid
                ))

                SudokuInputView(store: store.scope(
                    state: \.input,
                    action: \.input
                ))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()

            if let menuStore = $store.scope(state: \.menu, action: \.menu).wrappedValue {
                ZStack {
                    Rectangle()
                        .fill(.ultraThinMaterial)

                    SudokuMenu(store: menuStore)
                }
                .transition(.scale(scale: 1.2).combined(with: .opacity))
                .zIndex(1)
            }
        }
        .ignoresSafeArea()
    }
}

#if DEBUG

#Preview {
    SudokuView(difficulty: .easy)
}

#endif
