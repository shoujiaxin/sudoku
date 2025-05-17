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
        static let iconSize: CGFloat = 28

        static let titleIconSpacing: CGFloat = 8
    }

    var body: some View {
        VStack {
            HStack(spacing: 0) {
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
                            .resizable()
                            .frame(width: Constants.iconSize, height: Constants.iconSize)

                        Text("Erase")
                    }
                }

                Button {
                    store.send(.toggleMode)
                } label: {
                    VStack(spacing: Constants.titleIconSpacing) {
                        Image(store.mode == .fill ? .pencilLine : .pencilLineFill)
                            .resizable()
                            .frame(width: Constants.iconSize, height: Constants.iconSize)
                            .foregroundStyle(store.mode == .fill ? .secondary : Color.accentColor)

                        Text("Note")
                    }
                }

                // TODO: hint count
                Button {
                    store.send(.delegate(.onHint))
                } label: {
                    VStack(spacing: Constants.titleIconSpacing) {
                        Image(.lightbulb)
                            .resizable()
                            .frame(width: Constants.iconSize, height: Constants.iconSize)

                        Text("Hint")
                    }
                }
            }
            .buttonStyle(SudokuInputButtonStyle())
            .font(.caption2)

            HStack(spacing: 0) {
                ForEach(1 ... 9, id: \.self) { digit in
                    if store.hiddenValues.contains(digit) {
                        Color.clear
                    } else {
                        Button {
                            store.send(.input(digit))
                        } label: {
                            Text(digit, format: .number)
                                .font(store.mode == .fill ? .system(size: 40).monospaced() : .custom("Bradley Hand", size: 40))
                                .minimumScaleFactor(0.01)
                                .foregroundStyle(store.mode == .fill ? Color.accentColor : .secondary)
                        }
                    }
                }
            }
            .buttonStyle(SudokuInputButtonStyle(padding: 0))
            .frame(maxHeight: 60)
        }
    }
}

private struct SudokuInputButtonStyle: ButtonStyle {
    var padding: CGFloat? = nil

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.all, padding)
            .background(
                .quaternary.opacity(configuration.isPressed ? 1 : 0),
                in: .rect(cornerRadius: 8)
            )
            .opacity(configuration.isPressed ? 0.5 : 1)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .foregroundStyle(.tint)
    }
}
