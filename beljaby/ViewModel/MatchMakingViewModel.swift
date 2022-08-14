//
//  MatchMakingViewModel.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/08/12.
//

import Foundation

struct UserSelect: Hashable{
    let name: String
    let elo: Int
    let puuid: String
    let user: User
    var isSelected: Bool = false
}

protocol MatchMakingDelegate {
    func DelegateFunc(team1: [User], team2: [User])
}

final class MatchMakingViewModel: ObservableObject{
    @Published var userDict: [String: UserSelect] = [:]
    var delegate: MatchMakingDelegate
    
    var gridValue: [UserSelect]{
        userDict.values.sorted{$0.name < $1.name}
    }
    
    var makeButtonDisable: Bool{
        self.userDict.values.filter({$0.isSelected}).count != 10
    }
    
    var buttonLabel: String{
        let remain: Int = 10 - self.userDict.values.filter({$0.isSelected}).count
        if remain < 0{
            return "Select too many"
        }
        return makeButtonDisable ? "Select \(remain) users" : "Match Making"
    }
    
    init(deligate: MatchMakingDelegate){
        self.delegate = deligate
        FirebaseManager.shared.userList.value.forEach { user in
            self.userDict[user.name] = UserSelect(name: user.name, elo: user.elo, puuid: user.puuid, user: user)
        }
    }
    
    func Select(name: String){
        self.userDict[name]?.isSelected.toggle()
    }
    
    func Balance(){
        let selected = self.userDict.values.filter{$0.isSelected}
        let sumTotal = selected.reduce(0) { $0 + $1.elo }
        var minDiff = sumTotal
        var team1 = [UserSelect]()
        
        func combination(_ idx: Int, _ now: [UserSelect]){
            if now.count == 5{
                let team1Sum = now.reduce(0) { $0 + $1.elo }
                let diff = abs( 2 * team1Sum - sumTotal )
                if diff < minDiff{
                    minDiff = diff
                    team1 = now
                }
                return
            }
            
            for i in idx..<selected.count{
                combination(i + 1, now + [selected[i]] )
            }
        }
        
        combination(0, [])
        
        let team2 = selected.filter{!team1.contains($0)}
        
        self.delegate.DelegateFunc(team1: team1.map{$0.user}, team2: team2.map{$0.user})
    }
}
