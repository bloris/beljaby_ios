//
//  MatchDetailCellViewModel.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/08/10.
//

import Foundation

final class MatchDetailCellViewModel: ObservableObject {
    
    @Published var matchDetail: MatchDetail?
    
    let version = LolRealmManager.shared.ver
    let champData = LolRealmManager.shared.champData
    
    // Check current cell is main user
    var my: Bool {
        return matchDetail?.my ?? false
    }
    
    // User name
    var name: String {
        return matchDetail?.name ?? ""
    }
    
    // User level
    var champLevel: String {
        guard let level = matchDetail?.userMatch.champLevel else { return "0" }
        return "\(level)"
    }
    
    // User Champion image URL
    var champImgURl: URL? {
        guard let champ = champData[matchDetail?.userMatch.champ ?? 0] else { return nil }
        return URL(string: "https://ddragon.leagueoflegends.com/cdn/\(version)/img/champion/\(champ.id).png")
    }
    
    // User boughted item image URL
    var itemImgURL: [URL?] {
        var itemList = matchDetail?.userMatch.item.filter { $0 != 0 } ?? []
        while itemList.count < 7 {
            itemList.insert(0, at: itemList.count - 1)
        }
        
        return itemList.map( { item in
            if item == 0 { return nil }
            return URL(string: "https://ddragon.leagueoflegends.com/cdn/\(version)/img/item/\(item).png")
        })
    }
    
    // User kill count
    var kill: String {
        guard let kill = matchDetail?.userMatch.kill else { return "0" }
        return "\(kill)"
    }
    
    // User death count
    var death: String {
        guard let death = matchDetail?.userMatch.death else { return "0" }
        return "\(death)"
    }
    
    // User assist count
    var assist: String {
        guard let assist = matchDetail?.userMatch.assist else { return "0" }
        return "\(assist)"
    }
    
    // User minions kill count
    var cs: String {
        guard let cs = matchDetail?.userMatch.cs else { return "0" }
        return "\(cs)"
    }
    
    // User gold earned total
    var goldEarned: String {
        guard let gold = matchDetail?.userMatch.goldEarned else { return "0 천" }
        return String(format: "%.1f천", Double(gold+50)/1000.0)
    }
    
    // User selected main perk image name
    var mainPerk: String {
        guard let mainPerk = matchDetail?.userMatch.mainPerk else { return "" }
        return "\(mainPerk)"
    }
    
    // User selected sub perk image name
    var subPerk: String {
        guard let subPerk = matchDetail?.userMatch.subPerk else { return "" }
        return "\(subPerk)"
    }
    
    init(matchDetail: MatchDetail) {
        self.matchDetail = matchDetail
    }
}
