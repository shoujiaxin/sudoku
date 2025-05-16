//
//  SudokuGenerator+Dependency.swift
//  Sudoku
//
//  Created by Jiaxin Shou on 2025/5/15.
//

import ComposableArchitecture

extension DependencyValues {
    var sudokuGenerator: SudokuGenerator {
        get {
            self[SudokuGenerator.self]
        }
        set {
            self[SudokuGenerator.self] = newValue
        }
    }
}

extension SudokuGenerator: DependencyKey {
    static let liveValue: SudokuGenerator = .init()
}
