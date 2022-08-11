//
//  MatchDetailViewModel.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/08/10.
//

import Foundation
import Combine

final class MatchDetailViewModel: ObservableObject{
    
    @Published var matchDetails: [MatchDetail]
    
    let champData = LolRealmManager.shared.champData
    
    var myTeam: [MatchDetail]{
        let len = self.matchDetails.count
        let team = self.matchDetails[0..<len/2]
        return Array(team)
    }
    
    var enemyTeam: [MatchDetail]{
        let len = self.matchDetails.count
        let team = self.matchDetails[len/2..<len]
        return Array(team)
    }
    
    var champImgURl: URL?{
        guard let champ = champData[self.matchDetails.first?.userMatch.champ ?? 0] else {return nil}
        return URL(string: "https://ddragon.leagueoflegends.com/cdn/img/champion/splash/\(champ.id)_0.jpg")
    }
    
    var win: Bool{
        guard let userMatch = self.matchDetails.first?.userMatch else {return true}
        return userMatch.win
    }
    
    var winLabel: String{
        guard let win = self.matchDetails.first?.userMatch.win else {return "승리"}
        return win ? "승리" : "패배"
    }
    
    var dateLabel: String{
        let firebaseManager = FirebaseManager.shared
        guard let userMatch = self.matchDetails.first?.userMatch,
              let match = firebaseManager.MatchDict[userMatch.matchId] else {return "0000/00/00 00:00"}
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        let gameDuration = match.gameDuration
        
        let matchDate = dateFormatter.string(from: userMatch.matchDate)
        let duration = String(format: "  %02d:%02d분", gameDuration/60,gameDuration%60)
        
        return matchDate + duration
    }
    
    init(matchDetails: [MatchDetail]){
        self.matchDetails = matchDetails
    }
}
