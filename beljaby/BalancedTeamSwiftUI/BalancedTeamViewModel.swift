//
//  BalancedTeamViewModel.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/08/14.
//

import Foundation

final class BalancedTeamViewModel: ObservableObject {
    @Published var team1: [User]
    @Published var team2: [User]
    
    init(team1: [User], team2: [User]) {
        self.team1 = team1
        self.team2 = team2
    }
}
