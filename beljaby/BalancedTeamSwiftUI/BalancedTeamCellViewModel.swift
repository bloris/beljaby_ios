//
//  BalancedTeamCellViewModel.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/08/23.
//

import Foundation

final class BalancedTeamCellViewModel: ObservableObject {
    @Published var user: User?
    
    let version = LolRealmManager.shared.ver
    
    var profileIconURL: URL? {
        guard let profileIconId = user?.profileIconId else { return nil }
        return URL(string: "https://ddragon.leagueoflegends.com/cdn/\(version)/img/profileicon/\(profileIconId).png")
    }
    
    var name: String {
        return user?.name ?? ""
    }
    
    var elo: String {
        guard let elo = user?.elo else { return "1300" }
        return "\(elo)"
    }
    
    var tier: String {
        guard let tier = user?.tier else { return "Emblem_Gold" }
        return "Emblem_\(tier)"
    }
    
    init(user: User) {
        self.user = user
    }
}
