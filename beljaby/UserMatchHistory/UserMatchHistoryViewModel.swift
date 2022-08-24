//
//  UserMatchHistoryViewModel.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/08/10.
//

import Foundation
import Combine

final class UserMatchHistoryViewModel {
    
    private var puuid: String // 현재 확인중인 User의 puuid
    
    private var subscriptions = Set<AnyCancellable>()
    let selectedMatchDetail: CurrentValueSubject<[MatchDetail]?, Never> // MatchDetail View를 위해 재가공된 데이터 전달
    let userMatchList: CurrentValueSubject<[UserMatch], Never> // Firebase로부터 UserMatch Data를 view에 전달
    
    private let firebaseManager = FirebaseManager.shared //Get Firebase Singleton Object
    
    init(puuid: String, selectedMatch: [MatchDetail]? = nil) {
        self.puuid = puuid
        selectedMatchDetail = CurrentValueSubject(selectedMatch)
        // Data를 획득하기 전에 접근했다면 Empty Array -> Bind를 통해 Update
        userMatchList = CurrentValueSubject(
            firebaseManager
                .userMatchDict[puuid]?
                .values
                .sorted(by: {
                    $0.matchDate > $1.matchDate
                }) ?? []
        )
        bind()
    }
    
    private func bind() {
        // Receive Firebase User Match Data Fetching Finish info
        // Bind UserMatch Info List from Firebase -> Apply Section Item to Diffable Datasource
        firebaseManager.userMatchLoad
            .receive(on: RunLoop.main)
            .sink { [unowned self] in
                userMatchList.send(
                    firebaseManager
                        .userMatchDict[puuid]?
                        .values
                        .sorted(by: {
                            $0.matchDate > $1.matchDate
                        }) ?? []
                )
            }.store(in: &subscriptions)
    }
    
    // Preprocess UserMatch Data to MatchDetail View
    func didSelect(at indexPath: IndexPath) {
        let firebaseManager = FirebaseManager.shared
        
        let userMatch = userMatchList.value[indexPath.item] // Get Selected UserMatch
        let match = FirebaseManager.shared.MatchDict[userMatch.matchId]! // Get Match data with MatchID
        let users = match.users // Get User list in Match
        let team: [String] // Reconstructed users
        let userMatches: [UserMatch] // Get UserMatch Data with User puuid and MatchID
        let matchDetails: [MatchDetail] // Reconstruct Data to MatchDetail View
        
        // 현재 유저가 속한 팀을 상단으로, 현재 유저를 0번째 열로
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
        
        // 재구성한 User Puuid List를 바탕으로 UserMatch Data 획득
        userMatches = team.map( { puuid in
            firebaseManager.userMatchDict[puuid]![userMatch.matchId]!
        })
        
        // MatchDetail View에서 사용하기 편한 형태로 Data 가공
        matchDetails = zip(team, userMatches).map { MatchDetail(name: firebaseManager.userDict[$0]!.name, userMatch: $1, my: $0 == team[0]) }
        
        // 가공된 Data 전달
        selectedMatchDetail.send(matchDetails)
    }
}
