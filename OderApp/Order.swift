//
//  Order.swift
//  OderApp
//
//  Created by Esperanza on 2022-01-31.
//

import Foundation

struct Order: Codable {
    var menuItems: [MenuItem]
    
    init(menuItems: [MenuItem] = []) {
        self.menuItems = menuItems
    }
}
