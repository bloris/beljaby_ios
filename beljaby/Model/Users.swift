//
//  Users.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/07/05.
//

import Foundation

struct Users: Codable{
    let puuid: String
    let profileIconId: Int
    let elo: Int
    let tier: String
    let win: Int
    let lose: Int
    let matches: [userMatch]
}

struct userMatch: Codable{
    let champ: String
    let eloChange: Int
    let mainPerk: String
    let subPerk: String
    let kill: Int
    let death: Int
    let assist: Int
    let cs: Int
    let killP : Int
    let item: [Int]
    let ward: Int
}
