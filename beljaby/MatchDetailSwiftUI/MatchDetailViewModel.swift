//
//  MatchDetailViewModel.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/08/10.
//

import Foundation
import Combine

final class MatchDetailViewModel: ObservableObject {
    
    @Published var matchDetails: [MatchDetail]
    
    let champData = LolRealmManager.shared.champData
    
    // Range(0..<len/2) -> My Team soreted before
    var myTeam: [MatchDetail] {
        let len = matchDetails.count
        let team = matchDetails[0..<len/2]
        return Array(team)
    }
    
    // Range(len/2..<len) -> Enemy Team sorted before
    var enemyTeam: [MatchDetail] {
        let len = matchDetails.count
        let team = matchDetails[len/2..<len]
        return Array(team)
    }
    
    // Main user's champion splash image URL
    var champImgURl: URL? {
        guard let champ = champData[matchDetails.first?.userMatch.champ ?? 0] else { return nil }
        return URL(string: "https://ddragon.leagueoflegends.com/cdn/img/champion/splash/\(champ.id)_0.jpg")
    }
    
    // Main user's win state
    var win: Bool {
        guard let userMatch = matchDetails.first?.userMatch else { return true }
        return userMatch.win
    }
    
    // Win Label text with win state
    var winLabel: String {
        guard let win = matchDetails.first?.userMatch.win else { return "승리" }
        return win ? "승리" : "패배"
    }
    
    // Match date and game duration info
    var dateLabel: String {
        let firebaseManager = FirebaseManager.shared
        guard let userMatch = matchDetails.first?.userMatch, let match = firebaseManager.MatchDict[userMatch.matchId] else {
            return "0000/00/00 00:00"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        let gameDuration = match.gameDuration
        
        let matchDate = dateFormatter.string(from: userMatch.matchDate)
        let duration = String(format: "  %02d:%02d분", gameDuration/60,gameDuration%60)
        
        return matchDate + duration
    }
    
    init(matchDetails: [MatchDetail]) {
        self.matchDetails = matchDetails
    }
}
