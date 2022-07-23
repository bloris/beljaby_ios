//
//  champion.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/07/20.
//

import Foundation
import RealmSwift

class ChampionCache: Object{
    @objc dynamic var id: String = ""
    @objc dynamic var key: String = ""
    @objc dynamic var name: String = ""
    
    var parentCategory = LinkingObjects(fromType: DataCache.self, property: "champions")
}

struct ChampionList:Codable{
    let data: [String: Champion]
}

struct Champion: Codable{
    let id: String
    let key: String
    let name: String
}
