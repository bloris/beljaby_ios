//
//  User.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/08/08.
//

import Foundation

/// MatchMakingView에서 Select 여부를 지원하기 위한 Struct
struct UserSelect: Hashable {
    let name: String
    let elo: Int
    let puuid: String
    let user: User
    var isSelected: Bool = false
}

/// User 정보를 가져오기 위한 Struct
struct User: Codable, Hashable {
    let puuid: String
    let name: String
    let profileIconId: Int
    let elo: Int
    let tier: String
    let win: Int
    let lose: Int
}
