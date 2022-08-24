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
    let userList = CurrentValueSubject<[User], Never>([User]()) // Subscribe User List from Friebase -> Send to View
    let selectedUser: CurrentValueSubject<User?, Never> // Get selected User -> Push UserMatchHistory view
    let delegateReceive = PassthroughSubject<([User],[User]), Never>() // Get balanced team info as delegate func -> Push BalancedTeam View
    let dataLoadFinish = PassthroughSubject<Void, Never>() // Get data load finish notice -> Request reload Data with correct info
    let makeButton = PassthroughSubject<Void, Never>() // Make button tapped -> Push MatchMaking View
    
    var historyViewTitle: String {
        guard let name = self.selectedUser.value?.name else {return ""}
        return "\(name) 대전 기록"
    }
    
    init(selectedUser: User? = nil) {
        self.selectedUser = CurrentValueSubject(selectedUser) // Initialize selected user with nil
        bind()
    }
    
    func didSelect(at indexPath: IndexPath) {
        let user = userList.value[indexPath.item] // Get selected user info
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
        
        // Bind User Most Champion Counting Finish -> Get each user most champion data
        // Send View need to reload with correct champion most info
        firebaseManager.mostChampionLoad
            .receive(on: RunLoop.main)
            .sink { [unowned self] in
                dataLoadFinish.send()
            }.store(in: &subscriptions)
        
        // Bind realmManager get version, champion game data -> Some game imageURL need version info
        // Send View need to reload with correct URL
        realmManger.gameDataLoad
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
