//
//  FirebaseManager.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/08/08.
//

import Foundation
import FirebaseDatabase
import FirebaseFirestore
import Combine

/// Firebase Firestore Database 사용을 위한 Class
/// - shared: Firestore Data를 사용하기 위한 싱글톤 인스턴스
final class FirebaseManager {
    static let shared = FirebaseManager()
    
    let userList = CurrentValueSubject<[User], Never>([User]()) // Send User Array to Rank View
    let userMatchLoad = PassthroughSubject<Void, Never>() // Send fetch finish info to UserMatchHistory View
    let mostChampionLoad = PassthroughSubject<Void, Never>() // Send most champion counting finish info to Rank View
    
    var userDict = [String:User]() // 해당 user의 puuid를 key로 하는 User 정보 Dictionary
    var userMatchDict = [String: [String: UserMatch]]() // 해당 user의 puuid를 key로 하는 User Match 정보 Dictionary
    var MatchDict = [String: Match]() // MatchID를 key로 하는 Match 정보 Dictionary
    var userChampCnt = [String: [Int]]() // 해당 User의 puuid를 key로 하는 User Champion 플레이 횟수로 정렬된 ChampionID 정보 Dictionary
    
    private var db = Firestore.firestore()
    
    private init() {
        self.getAllUser()
        self.getAllMatch()
    }
    
    /// 첫 실행시 전체 User 정보에 대한 Snapshot Listner 연결
    /// - 전체 User 정보 획득
    /// - User 정보에 대한 실시간 업데이트 수신 대기 (새로운 Match 결과 추가에 따른 변화)
    private func getAllUser() {
        self.db.collection("users").addSnapshotListener { [unowned self] snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error Firestore fetching document \(String(describing: error))")
                return
            }
            
            documents.forEach { doc in
                do {
                    let user = try doc.data(as: User.self)
                    self.getAllUserMatch(puuid: doc.documentID) // 해당 User의 User Match 정보 fetch
                    
                    self.userDict[doc.documentID] = user // Store User in UserDict with puuid as key
                } catch let error {
                    print("Error Json parsing \(doc.documentID) \(error.localizedDescription)")
                }
            }
            
            // Elo를 기반으로 User를 내림차순으로 졍렬하여 Subject(Publisher)에 주입
            self.userList.send(Array(self.userDict.values).sorted {
                $0.elo > $1.elo
            })
        }
    }
    
    /// 첫 실행시 전체 Match 정보에 대한 Snapshot Listner 연결
    /// - Match 정보에 대한 실시간 업데이트 수신 대기 (새로운 Match 결과 추가에 따른 변화)
    private func getAllMatch() {
        self.db.collection("matches").addSnapshotListener { [unowned self] snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error Firestore fetching document \(String(describing: error))")
                return
            }
            
            documents.forEach { doc in
                do {
                    let match = try doc.data(as: Match.self)
                    self.MatchDict[doc.documentID] = match // Store match in MatchDict with MacthID as key
                } catch let error {
                    print("Error Json parsing \(doc.documentID) \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// puuid에 해당하는 User Match 정보 Fetch
    /// - 해당 User의 각 Champion 플레이 횟수 Count (Champion Most 정보 제공)
    private func getAllUserMatch(puuid: String) {
        self.db.collection("users").document(puuid).collection("userMatch").getDocuments {[unowned self] (snapshot, error) in
            guard let documents = snapshot?.documents else {
                print("Error Firestore fetching document \(String(describing: error))")
                return
            }
            var champCnt = [Int: Int]()
            
            self.userMatchDict[puuid] = [String: UserMatch]() // Create Eampty Dict with puuid, Save userMatch Info in inside dict
            
            documents.forEach( { doc in
                do {
                    let userMatch = try doc.data(as: UserMatch.self)
                    champCnt[userMatch.champ, default: 0] += 1 // Champion 플레이 횟수 Count
                    self.userMatchDict[puuid]![doc.documentID] = userMatch // Store match in userMatchDict with puuid, matchID as key
                } catch let error {
                    print("Error Json Parsing \(doc.documentID) \(error.localizedDescription)")
                    return
                }
            })
            
            // 해당 User의 각 Champion 플레이 횟수를 내림차순으로 정렬한 Champion name Array 생성
            self.userChampCnt[puuid] = champCnt.sorted(by: {
                if $0.value == $1.value {
                    return $0.key < $1.key
                }
                return $0.value > $1.value
            }).map {
                $0.key
            }
            
            while self.userChampCnt[puuid]!.count < 3 {
                self.userChampCnt[puuid]!.append(-1) // Match 정보가 부족한 경우 크기 맞추기
            }
            
            if self.userMatchDict.count == self.userList.value.count {
                print("!!!!")
                self.userMatchLoad.send() // 모든 User Match를 Fetch 했다고 전달
                self.mostChampionLoad.send() // 모든 User의 most champion counting이 끝났다고 전달
            }
        }
    }
}
