//
//  Item.swift
//  Sudoku
//
//  Created by Jiaxin Shou on 2025/5/12.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date

    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
