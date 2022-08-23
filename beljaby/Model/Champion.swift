//
//  champion.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/07/20.
//

import Foundation
import RealmSwift

/// Riot Champion Data를 Local에 저장하기 위한 Realm Class
/// - Champion Type Data를 받아 초기화
class ChampionCache: Object {
    @Persisted var id: String = ""
    @Persisted var key: String = ""
    @Persisted var name: String = ""
    
    var parentCategory = LinkingObjects(fromType: LolDataCache.self, property: "champions")
    
    convenience init(champ: Champion) {
        self.init()
        self.id = champ.id
        self.key = champ.key
        self.name = champ.name
    }
}

/// Riot Champion List Data Parsing을 위한 Struct
struct ChampionList:Codable {
    let data: [String: Champion]
}

/// Riot Champion List Item Parsing을 위한 Struct
struct Champion: Codable {
    let id: String
    let key: String
    let name: String
}
