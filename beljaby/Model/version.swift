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

