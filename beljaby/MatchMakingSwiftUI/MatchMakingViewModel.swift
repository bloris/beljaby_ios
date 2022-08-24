//
//  MatchMakingViewModel.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/08/12.
//

import Foundation

/// Protocol to Dismiss Matchmaking View and push Balanced Team view
protocol MatchMakingDelegate {
    func DelegateFunc(team1: [User], team2: [User]) // Get Balanced Team info as parameter
}

final class MatchMakingViewModel: ObservableObject {
    @Published var userDict: [String: UserSelect] = [:]
    
    var delegate: MatchMakingDelegate
    var buttonTapped = false // Check View dismiss with button
    
    // Show User name with sorted as alphabetical order
    var gridValue: [UserSelect] {
        userDict.values.sorted{$0.name < $1.name}
    }
    
    // Before select 10 user disable button
    var makeButtonDisable: Bool {
        userDict.values.filter( { $0.isSelected } ).count != 10
    }
    
    // Count selected user and change label text of button
    var buttonLabel: String {
        let remain: Int = 10 - userDict.values.filter( { $0.isSelected } ).count
        if remain < 0 {
            return "Select too many"
        }
        return makeButtonDisable ? "Select \(remain) users" : "Match Making"
    }
    
    init(deligate: MatchMakingDelegate) {
        self.delegate = deligate
        FirebaseManager.shared.userList.value.forEach { user in
            self.userDict[user.name] = UserSelect(name: user.name, elo: user.elo, puuid: user.puuid, user: user)
        }
    }
    
    // Selected user select value toggle
    func Select(name: String) {
        userDict[name]?.isSelected.toggle()
    }
    
    // Balancing Team with selected user
    func Balance() {
        let selected = userDict.values.filter { $0.isSelected }
        let sumTotal = selected.reduce(0) { $0 + $1.elo }
        var minDiff = sumTotal
        var team1 = [UserSelect]()
        
        // Make 10C5 Combination and find minimum sum diff case
        func combination(_ idx: Int, _ now: [UserSelect]) {
            if now.count == 5{
                let team1Sum = now.reduce(0) { $0 + $1.elo }
                let diff = abs( 2 * team1Sum - sumTotal ) // team1Sum - team2Sum = team1Sum - (sumTotal - team1Sum)
                if diff < minDiff {
                    minDiff = diff
                    team1 = now
                }
                return
            }
            
            for i in idx..<selected.count {
                combination(i + 1, now + [selected[i]] )
            }
        }
        
        combination(0, [])
        
        let team2 = selected.filter { !team1.contains($0) } // Get team2 with filtering team1
        
        delegate.DelegateFunc(team1: team1.map { $0.user }, team2: team2.map { $0.user } ) // Call Delegate function at RankViewModel
    }
}
