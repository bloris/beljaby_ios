//
//  version.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/07/11.
//

import Foundation
import Alamofire
struct Version:Codable{
    let v: String
}

struct ChampionList:Codable{
    let data: [String: Champion]
}

struct Champion: Codable{
    let id: String
    let key: String
    let name: String
}

