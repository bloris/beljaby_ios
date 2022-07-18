//
//  RankViewController.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/07/05.
//

import UIKit
import Alamofire
import FirebaseDatabase
import FirebaseFirestore

class RankViewController: UITableViewController {
    var userList = [(Users,String)]()
    var userChampCnt = [String: [Int]]()
    var userMatchDict = [String: Array<(UserMatch,String)>]()
    //var userMatchDict = [Users: Array<userMatch>]()
    var champData = [Int: Champion]()
    var version = "12.12.1"
    var db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nibName = UINib(nibName: "UserRankCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "UserRankCell")
        
        
        self.getAllUser()
        
        self.getVersion {[weak self] result in
            guard let self = self else{
                return
            }
            switch result{
            case let .success(result):
                self.version = result.v
            case let .failure(error):
                print(error.localizedDescription)
                return
            }
        }
        
        self.getChampion(self.version) {[weak self] result in
            guard let self = self else{
                return
            }
            switch result{
            case let .success(result):
                result.data.forEach{
                    self.champData[Int($0.value.key) ?? 0] = $0.value
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case let .failure(error):
                print(error.localizedDescription)
                return
            }
        }
    }
    
    func getAllUserMatch(puuid: String){
        self.db.collection("users").document(puuid).collection("userMatch").getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else{
                print("Error Firestore fetching document \(String(describing: error))")
                return
            }
            var champCnt = [Int: Int]()
            self.userMatchDict[puuid] = documents.compactMap({ doc -> (UserMatch,String)?  in
                do{
                    let userMatch = try doc.data(as: UserMatch.self)
                    champCnt[userMatch.champ, default: 0] += 1
                    return (userMatch,doc.documentID)
                }catch let error{
                    print("Error Json Parsing \(doc.documentID) \(error.localizedDescription)")
                    return nil
                }
            }).sorted(by: {
                $0.0.matchDate < $1.0.matchDate
            })
            
            self.userChampCnt[puuid] = champCnt.sorted(by: {
                $0.value > $1.value
            }).map{
                $0.key
            }
            
            while self.userChampCnt[puuid]!.count < 3{
                self.userChampCnt[puuid]!.append(self.userChampCnt[puuid]!.last!)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    func getAllUser(){
        db.collection("users").addSnapshotListener {snapshot, error in
            guard let documents = snapshot?.documents else{
                print("Error Firestore fetching document \(String(describing: error))")
                return
            }
            
            self.userList = documents.compactMap({ doc -> (Users,String)? in
                do{
                    let user = try doc.data(as: Users.self)
                    self.getAllUserMatch(puuid: doc.documentID)
                    
                    return (user,doc.documentID)
                } catch let error{
                    print("Error Json parsing \(doc.documentID) \(error.localizedDescription)")
                    return nil
                }
            }).sorted(by: {
                $0.0.elo > $1.0.elo
            })
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
    }
}

//MARK: - Table View Datasource
extension RankViewController{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.userList[indexPath.row].0
        print(user.name)
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.userList.count
    }
    
    func getVersion(completionHandler: @escaping (Result<Version, Error>) -> Void){
        let url = "https://ddragon.leagueoflegends.com/realms/kr.json"
        
        AF.request(url, method: .get)
            .responseDecodable(of: Version.self) { response in
                switch response.result {
                case .success(let response):
                    completionHandler(.success(response))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
    }
    
    func getChampion(_ version: String, completionHandler: @escaping (Result<ChampionList, Error>) -> Void){
        let url = "https://ddragon.leagueoflegends.com/cdn/\(version)/data/ko_KR/champion.json"
        AF.request(url, method: .get)
            .responseDecodable(of: ChampionList.self) { response in
                switch response.result {
                case .success(let response):
                    completionHandler(.success(response))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserRankCell", for: indexPath) as? UserRankCell else{
            return UITableViewCell()
        }
        
        let user = self.userList[indexPath.row].0
        let puuid = self.userList[indexPath.row].1
        
        let profileImageURL = URL(string: "https://ddragon.leagueoflegends.com/cdn/\(self.version)/img/profileicon/\(user.profileIconId).png")
        
        let champ: [String] = (0...2).map{
            guard let champCnt = userChampCnt[puuid] else{
                return "Qiyana"
            }
            return champData[champCnt[$0]]?.id ?? "Qiyana"
        }
        
        let m1 = URL(string: "https://ddragon.leagueoflegends.com/cdn/\(self.version)/img/champion/\(champ[0]).png")
        let m2 = URL(string: "https://ddragon.leagueoflegends.com/cdn/\(self.version)/img/champion/\(champ[1]).png")
        let m3 = URL(string: "https://ddragon.leagueoflegends.com/cdn/\(self.version)/img/champion/\(champ[2]).png")

        cell.profileImage.kf.setImage(with: profileImageURL)
        cell.mostOneImage.kf.setImage(with: m1)
        cell.mostSecondImage.kf.setImage(with: m2)
        cell.mostThirdImage.kf.setImage(with: m3)
        
        cell.tierImage.image = UIImage(named: "Emblem_\(user.tier)")
        cell.name.text = user.name
        cell.elo.text = "\(user.elo)LP"
        cell.tierLabel.text = user.tier
        
        let win = user.win
        let lose = user.lose
        let ratio = 100*Double(win)/Double(win+lose)
        cell.ratioConstraint = cell.ratioConstraint.setMultiplier(multiplier: ratio/50)
        
        cell.winLabel.text = "\(win)W"
        cell.loseLabel.text = "\(lose)L"
        cell.ratioLabel.text = "\(Int(ratio))%"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
