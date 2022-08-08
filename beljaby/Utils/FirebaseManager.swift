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

final class FirebaseManager{
    static let shared = FirebaseManager()
    
    var userList = CurrentValueSubject<[User], Never>([User]())
    var userMatchLoad = PassthroughSubject<Bool, Never>()
    
    var userDict = [String:User]()
    var userMatchDict = [String: Array<UserMatch>]()
    var MatchDict = [String: Match]()
    var userChampCnt = [String: [Int]]()
    
    private var db = Firestore.firestore()
    
    private init(){
        self.getAllUser()
        self.getAllMatch()
    }
    
    private func getAllUserMatch(puuid: String){
        self.db.collection("users").document(puuid).collection("userMatch").getDocuments {[unowned self] (snapshot, error) in
            guard let documents = snapshot?.documents else{
                print("Error Firestore fetching document \(String(describing: error))")
                return
            }
            var champCnt = [Int: Int]()
            
            self.userMatchDict[puuid] = documents.compactMap({ doc -> UserMatch?  in
                do{
                    let userMatch = try doc.data(as: UserMatch.self)
                    champCnt[userMatch.champ, default: 0] += 1
                    return userMatch
                }catch let error{
                    print("Error Json Parsing \(doc.documentID) \(error.localizedDescription)")
                    return nil
                }
            }).sorted(by: {
                $0.matchDate > $1.matchDate
            })
            
            self.userChampCnt[puuid] = champCnt.sorted(by: {
                if $0.value == $1.value{
                    return $0.key < $1.key
                }
                return $0.value > $1.value
            }).map{
                $0.key
            }
            
            while self.userChampCnt[puuid]!.count < 3{
                self.userChampCnt[puuid]!.append(-1)
            }
            
            if self.userMatchDict.count == self.userList.value.count{
                self.userMatchLoad.send(true)
            }
        }
    }
    
    private func getAllMatch(){
        self.db.collection("matches").addSnapshotListener {[unowned self] snapshot, error in
            guard let documents = snapshot?.documents else{
                print("Error Firestore fetching document \(String(describing: error))")
                return
            }
            
            documents.forEach { doc in
                do{
                    let match = try doc.data(as: Match.self)
                    self.MatchDict[doc.documentID] = match
                }catch let error{
                    print("Error Json parsing \(doc.documentID) \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func getAllUser(){
        self.db.collection("users").addSnapshotListener {[unowned self] snapshot, error in
            guard let documents = snapshot?.documents else{
                print("Error Firestore fetching document \(String(describing: error))")
                return
            }
            
            documents.forEach { doc in
                do{
                    let user = try doc.data(as: User.self)
                    self.getAllUserMatch(puuid: doc.documentID)
                    
                    self.userDict[doc.documentID] = user
                } catch let error{
                    print("Error Json parsing \(doc.documentID) \(error.localizedDescription)")
                }
            }
            self.userList.send(Array(self.userDict.values).sorted{
                $0.elo > $1.elo
            })
        }
    }
}
