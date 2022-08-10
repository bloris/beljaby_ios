//
//  MatchDetailViewModel.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/08/10.
//

import Foundation
import Combine

final class MatchDetailViewModel{
    
    let selectedMatchID: CurrentValueSubject<String,Never>
    
    let match: Match
    let users: [User]
    let userMatch: [UserMatch]
    
    init(matchID: String){
        let firebaseManager = FirebaseManager.shared
        self.selectedMatchID = CurrentValueSubject(matchID)
        self.match = firebaseManager.MatchDict[matchID]!
        self.users = self.match.users.map { puuid in
            firebaseManager.userDict[puuid]!
        }
        self.userMatch = []
    }
}
