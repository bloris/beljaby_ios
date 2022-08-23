//
//  version.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/07/11.
//

import Foundation
import Alamofire
import RealmSwift

/// Riot Verion, Champion Data를 Local에 저장하기 위한 Realm Class
/// - version: 실제 게임의 버전과 기기에 저장된 Local Data의 버전 비교를 위함
/// - champions: Local Version의 Champion Data List
class LolDataCache: Object {
    @Persisted var version: String = ""
    @Persisted var champions = List<ChampionCache>()
    
    convenience init(version: String) {
        self.init()
        self.version = version
    }
}

/// Riot Version Data Parsing을 위한 Struct
struct Version:Codable {
    let v: String
}




