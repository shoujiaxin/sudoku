//
//  SudokuInput.swift
//  Sudoku
//
//  Created by Jiaxin Shou on 2025/5/15.
//

import ComposableArchitecture
import SwiftUI

struct SudokuInput: View {
    let store: StoreOf<SudokuInputFeature>

    private enum Constants {
        static let titleIconSpacing: CGFloat = 8
    }

    var body: some View {
        VStack(spacing: 32) {
            HStack {
                // TODO: add undo
//                Button("Undo", systemImage: "arrow.uturn.backward") {
//                    store.send(.delegate(.onUndo))
//                }
//                .frame(maxWidth: .infinity)

                // TODO: add redo
//                Button("Redo", systemImage: "arrow.uturn.forward") {
//                    store.send(.delegate(.onRedo))
//                }
//                .frame(maxWidth: .infinity)

                Button {
                    store.send(.delegate(.onErase))
                } label: {
                    VStack(spacing: Constants.titleIconSpacing) {
                        Image(.eraser)

                        Text("Erase")
                    }
                }
                .frame(maxWidth: .infinity)

                Button {
                    store.send(.toggleMode)
                } label: {
                    VStack(spacing: Constants.titleIconSpacing) {
                        Image(store.mode == .fill ? .pencilLine : .pencilLineFill)
                            .foregroundStyle(store.mode == .fill ? .secondary : Color.accentColor)

                        Text("Note")
                    }
                }
                .frame(maxWidth: .infinity)

                // TODO: hint count
                Button {
                    store.send(.delegate(.onHint))
                } label: {
                    VStack(spacing: Constants.titleIconSpacing) {
                        Image(.lightbulb)

                        Text("Hint")
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .font(.caption2)

            HStack {
                ForEach(1 ... 9, id: \.self) { digit in
                    Button(digit.formatted(.number)) {
                        store.send(.input(digit))
                    }
                    .aspectRatio(0.8, contentMode: .fit)
                    .font(store.mode == .fill ? .system(size: 40).monospaced() : .custom("Bradley Hand", size: 40))
                    .minimumScaleFactor(0.01)
                    .foregroundStyle(store.mode == .fill ? Color.accentColor : .secondary)
                    .frame(maxWidth: .infinity)
                    .opacity(store.hiddenValues.contains(digit) ? 0 : 1)
                }
            }
        }
    }
}
