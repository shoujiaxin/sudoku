//
//  Level.swift
//  Sudoku
//
//  Created by Jiaxin Shou on 2023/12/29.
//

import Foundation

enum Level: String, CaseIterable, Identifiable {
    case easy
    case medium
    case hard
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .easy:
            return "简单"
        case .medium:
            return "中等"
        case .hard:
            return "困难"
        }
    }
    
    var cellsToRemove: Int {
        switch self {
        case .easy:
            return 30  // 留下51个格子
        case .medium:
            return 45  // 留下36个格子
        case .hard:
            return 55  // 留下26个格子
        }
    }
}
