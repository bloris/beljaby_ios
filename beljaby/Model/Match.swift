//
//  Users.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/07/05.
//

import Foundation

/// Match Detail View를 위한 User name, UserMatch, 기준이 되는 User인지 확인하는 변수 my를 합친 Struct
struct MatchDetail: Identifiable, Equatable {
    var id: String {
        return name
    }
    
    let name: String
    let userMatch: UserMatch
    let my: Bool
}

/// Match의 기본적인 정보 및 Match 참여 User puuid List를 가져오기 위한 Struct
struct Match: Codable {
    let matchId: String
    let gameDuration: Int
    let matchDate: Date
    let users: [String]
    let win: Bool
}

/// User 각각의 Match Detail을 가져오기 위한 Struct
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
