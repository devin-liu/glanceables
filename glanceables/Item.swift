//
//  Item.swift
//  glanceables
//
//  Created by Devin Liu on 5/30/24.
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
