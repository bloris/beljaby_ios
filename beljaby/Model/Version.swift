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
    @Persisted var version: String = ""
    @Persisted var champions = List<ChampionCache>()
}


