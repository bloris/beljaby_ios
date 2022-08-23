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
    
    var my: Bool {
        return matchDetail?.my ?? false
    }
    
    var name: String {
        return matchDetail?.name ?? ""
    }
    
    var champLevel: String {
        guard let level = matchDetail?.userMatch.champLevel else { return "0" }
        return "\(level)"
    }
    
    var champImgURl: URL? {
        guard let champ = champData[matchDetail?.userMatch.champ ?? 0] else { return nil }
        return URL(string: "https://ddragon.leagueoflegends.com/cdn/\(version)/img/champion/\(champ.id).png")
    }
    
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
    
    var kill: String {
        guard let kill = matchDetail?.userMatch.kill else { return "0" }
        return "\(kill)"
    }
    
    var death: String {
        guard let death = matchDetail?.userMatch.death else { return "0" }
        return "\(death)"
    }
    
    var assist: String {
        guard let assist = matchDetail?.userMatch.assist else { return "0" }
        return "\(assist)"
    }
    
    var cs: String {
        guard let cs = matchDetail?.userMatch.cs else { return "0" }
        return "\(cs)"
    }
    
    var goldEarned: String {
        guard let gold = matchDetail?.userMatch.goldEarned else { return "0 천" }
        return String(format: "%.1f천", Double(gold+50)/1000.0)
    }
    
    var mainPerk: String {
        guard let mainPerk = matchDetail?.userMatch.mainPerk else { return "" }
        return "\(mainPerk)"
    }
    
    var subPerk: String {
        guard let subPerk = matchDetail?.userMatch.subPerk else { return "" }
        return "\(subPerk)"
    }
    
    init(matchDetail: MatchDetail) {
        self.matchDetail = matchDetail
    }
}
