//
//  RankViewModel.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/08/08.
//

import Foundation
import Combine

final class RankViewModel{
    private let firebaseManager = FirebaseManager.shared
    
    let selectedUser: CurrentValueSubject<User?, Never>
    
    var historyViewTitle: String{
        guard let name = self.selectedUser.value?.name else {return ""}
        return "\(name) 대전 기록"
    }
    
    var puuid: String{
        return self.selectedUser.value?.puuid ?? ""
    }
    
    init(selectedUser: User? = nil){
        self.selectedUser = CurrentValueSubject(selectedUser)
    }
    
    func didSelect(at indexPath: IndexPath){
        let user = self.firebaseManager.userList.value[indexPath.item]
        selectedUser.send(user)
    }
}
