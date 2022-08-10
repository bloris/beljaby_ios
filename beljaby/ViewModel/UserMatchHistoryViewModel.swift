//
//  UserMatchHistoryViewModel.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/08/10.
//

import Foundation
import Combine

final class UserMatchHistoryViewModel{
    
    var puuid: String
    
    let selectedMatch: CurrentValueSubject<UserMatch?, Never>
    
    let userMatchList: CurrentValueSubject<[UserMatch], Never>
    
    init(puuid: String, selectedMatch: UserMatch? = nil){
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
        
        self.selectedMatch = CurrentValueSubject(selectedMatch)
    }
    
    func didSelect(at indexPath: IndexPath){
        let userMatch = self.userMatchList.value[indexPath.item]
        
        self.selectedMatch.send(userMatch)
    }
}
