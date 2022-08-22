//
//  User.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/08/08.
//

import Foundation

struct User: Codable, Hashable {
    let puuid: String
    let name: String
    let profileIconId: Int
    let elo: Int
    let tier: String
    let win: Int
    let lose: Int
    
}
