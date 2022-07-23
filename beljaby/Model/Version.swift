//
//  version.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/07/11.
//

import Foundation
import Alamofire
import RealmSwift

struct Version:Codable{
    let v: String
}

class DataCache: Object{
    @objc dynamic var version: String = ""
    let champions = List<ChampionCache>()
}


