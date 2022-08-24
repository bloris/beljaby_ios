//
//  BalancedTeamCellViewModel.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/08/23.
//

import Foundation

final class BalancedTeamCellViewModel: ObservableObject {
    @Published var user: User?
    
    let version = LolRealmManager.shared.ver // Version info to construct profileIconURL
    
    // User Profile Icon URL
    var profileIconURL: URL? {
        guard let profileIconId = user?.profileIconId else { return nil }
        return URL(string: "https://ddragon.leagueoflegends.com/cdn/\(version)/img/profileicon/\(profileIconId).png")
    }
    
    // User name
    var name: String {
        return user?.name ?? ""
    }
    
    // User elo
    var elo: String {
        guard let elo = user?.elo else { return "1300" }
        return "\(elo)"
    }
    
    // User tier
    var tier: String {
        guard let tier = user?.tier else { return "Emblem_Gold" }
        return "Emblem_\(tier)"
    }
    
    init(user: User) {
        self.user = user
    }
}
