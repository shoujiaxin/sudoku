//
//  HomeView.swift
//  Sudoku
//
//  Created by Jiaxin Shou on 2025/5/12.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    init() {
        let largeTitleFont: UIFont = {
            let font = UIFont.preferredFont(forTextStyle: .largeTitle)
            let fontDescriptor = font.fontDescriptor
                .withDesign(.rounded)?
                .withSymbolicTraits(.traitBold)
            return .init(
                descriptor: fontDescriptor ?? font.fontDescriptor,
                size: font.pointSize
            )
        }()

        let titleFont: UIFont = {
            let font = UIFont.preferredFont(forTextStyle: .body)
            let fontDescriptor = font.fontDescriptor
                .withDesign(.rounded)?
                .withSymbolicTraits(.traitBold)
            return .init(
                descriptor: fontDescriptor ?? font.fontDescriptor,
                size: font.pointSize
            )
        }()

        UINavigationBar.appearance().largeTitleTextAttributes = [
            .font: largeTitleFont,
        ]
        UINavigationBar.appearance().titleTextAttributes = [
            .font: titleFont,
        ]
    }

    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "square.grid.3x3.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .frame(maxHeight: .infinity)
                    .foregroundStyle(.tint)

                Button {} label: {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                        .padding(8)
                }
                .buttonStyle(.bordered)
                .tint(.accentColor)
                .padding()

                Button {} label: {
                    Text("New Game")
                        .frame(maxWidth: .infinity)
                        .padding(8)
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .padding()
            .navigationTitle("Sudoku")
        }
    }
}

#if DEBUG

#Preview {
    HomeView()
}

#endif
