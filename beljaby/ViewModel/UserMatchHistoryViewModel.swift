//
//  UserMatchHistoryViewModel.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/08/10.
//

import Foundation
import Combine

final class UserMatchHistoryViewModel {
    
    var puuid: String
    
//    typealias MatchDetail = (String,UserMatch)
    
    let selectedMatchDetail: CurrentValueSubject<[MatchDetail]?, Never>
    
    let userMatchList: CurrentValueSubject<[UserMatch], Never>
    
    init(puuid: String, selectedMatch: [MatchDetail]? = nil) {
        let firebaseManager = FirebaseManager.shared
        
        self.puuid = puuid
        
        self.userMatchList = CurrentValueSubject(
            firebaseManager
                .userMatchDict[puuid]?
                .values
                .sorted(by: {
                    $0.matchDate > $1.matchDate
                }) ?? []
        )
        
        self.selectedMatchDetail = CurrentValueSubject(selectedMatch)
    }
    
    func didSelect(at indexPath: IndexPath) {
        let firebaseManager = FirebaseManager.shared
        
        let userMatch = self.userMatchList.value[indexPath.item]
        let match = FirebaseManager.shared.MatchDict[userMatch.matchId]!
        let users = match.users
        let team: [String]
        let userMatches: [UserMatch]
        let matchDetails: [MatchDetail]
        
        //현재 유저가 속한 팀을 상단으로, 현재 유저를 0번째 열로
        if users[0..<5].contains(self.puuid) {
            team = Array(users[0..<5]).sorted(by: {
                if $0 == self.puuid { return true }
                else if $1 == self.puuid { return false }
                return true
            }) + Array(users[5..<10])
        }else {
            team = Array(users[5..<10]).sorted(by: {
                if $0 == self.puuid { return true }
                else if $1 == self.puuid { return false }
                return true
            }) + Array(users[0..<5])
        }
        
        userMatches = team.map( { puuid in
            firebaseManager.userMatchDict[puuid]![userMatch.matchId]!
        })
        
        matchDetails = zip(team, userMatches).map { MatchDetail(name: firebaseManager.userDict[$0]!.name, userMatch: $1, my: $0 == team[0]) }
        
        self.selectedMatchDetail.send(matchDetails)
    }
}
