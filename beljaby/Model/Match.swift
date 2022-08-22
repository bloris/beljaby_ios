//
//  Users.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/07/05.
//

import Foundation

struct MatchDetail: Identifiable, Equatable {
    var id: String {
        return name
    }
    
    let name: String
    let userMatch: UserMatch
    let my: Bool
}

struct Match: Codable {
    let matchId: String
    let gameDuration: Int
    let matchDate: Date
    let users: [String]
    let win: Bool
}

struct UserMatch: Codable, Hashable {
    let matchId: String
    let champ: Int
    let eloChange: Int
    let champLevel: Int
    let goldEarned: Int
    let mainPerk: Int
    let subPerk: Int
    let kill: Int
    let death: Int
    let assist: Int
    let cs: Int
    let killP : Int
    let item: [Int]
    let ward: Int
    let matchDate: Date
    let win: Bool
}
