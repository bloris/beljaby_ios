//
//  Users.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/07/05.
//

import Foundation

struct userData{
    let user: User
    let matchs: [UserMatch]
}

struct User: Codable, Hashable{
    let puuid: String
    let name: String
    let profileIconId: Int
    let elo: Int
    let tier: String
    let win: Int
    let lose: Int
    
}

struct Match: Codable{
    let gameDuration: Int
    let matchDate: Date
    let users: [String]
    let win: Bool
}

struct UserMatch: Codable{
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
