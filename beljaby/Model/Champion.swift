//
//  champion.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/07/20.
//

import Foundation
import RealmSwift

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

struct ChampionList:Codable {
    let data: [String: Champion]
}

struct Champion: Codable {
    let id: String
    let key: String
    let name: String
}
