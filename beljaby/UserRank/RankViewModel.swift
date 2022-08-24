//
//  RankViewModel.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/08/08.
//

import Foundation
import Combine

final class RankViewModel {
    private let firebaseManager = FirebaseManager.shared //Get Firebase Singleton Object
    private let realmManger = LolRealmManager.shared //Get Realm Singleton Object
    
    private var subscriptions = Set<AnyCancellable>()
    let userList = CurrentValueSubject<[User], Never>([User]())
    let selectedUser: CurrentValueSubject<User?, Never>
    let delegateReceive = PassthroughSubject<([User],[User]), Never>()
    let dataLoadFinish = PassthroughSubject<Void, Never>()
    let makeButton = PassthroughSubject<Void, Never>()
    
    var historyViewTitle: String {
        guard let name = self.selectedUser.value?.name else {return ""}
        return "\(name) 대전 기록"
    }
    
    var puuid: String {
        return self.selectedUser.value?.puuid ?? ""
    }
    
    init(selectedUser: User? = nil) {
        self.selectedUser = CurrentValueSubject(selectedUser)
        bind()
    }
    
    func didSelect(at indexPath: IndexPath) {
        let user = firebaseManager.userList.value[indexPath.item]
        selectedUser.send(user)
    }
    
    func makeButtonTapped() {
        makeButton.send()
    }
    
    private func bind() {
        // Bind User Info List from Firebase -> Apply Section Item to Diffable Datasource
        firebaseManager.userList
            .receive(on: RunLoop.main)
            .sink { [unowned self] users in
                userList.send(users)
            }.store(in: &subscriptions)
        
        // Bind User Match History Fetching Finish -> Get each user most champion data
        // Send View need to reload with correct champion most info
        firebaseManager.mostChampionLoad
            .receive(on: RunLoop.main)
            .sink { [unowned self] in
                dataLoadFinish.send()
            }.store(in: &subscriptions)
        
        realmManger.championDataLoad
            .receive(on: RunLoop.main)
            .sink { [unowned self] in
                dataLoadFinish.send()
            }.store(in: &subscriptions)
    }
}

extension RankViewModel: MatchMakingDelegate {
    func DelegateFunc(team1: [User], team2: [User]) {
        delegateReceive.send((team1,team2))
    }
}
