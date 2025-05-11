//
//  Level.swift
//  Sudoku
//
//  Created by Jiaxin Shou on 2023/12/29.
//

import Foundation

enum Level: String, CaseIterable, Identifiable {
    case easy = "简单"

    case medium = "中等"

    case hard = "困难"

    var id: Self { self }

    var emptyCellsCount: Int {
        switch self {
        case .easy:
            30 // 简单级别保留约51个数字
        case .medium:
            40 // 中等级别保留约41个数字
        case .hard:
            50 // 困难级别保留约31个数字
        }
    }
}
