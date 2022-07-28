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
import RealmSwift

class RankViewController: UITableViewController {
    var userList = [(User,String)]()
    var userChampCnt = [String: [Int]]()
    var userMatchDict = [String: Array<(UserMatch,String)>]()
    var MatchDict = [String: Match]()

    var champData = [Int: Champion]()
    var version = "12.12.1"
    var db = Firestore.firestore()
    var makeMode = false
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nibName = UINib(nibName: "UserRankCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "UserRankCell")
        tableView.allowsSelection = false
        self.initData()
        self.getAllUser()
        self.getAllMatch()
    }
    
    @IBAction func makeMatchTapped(_ sender: UIBarButtonItem) {
        makeMode.toggle()
    }
    
}

//MARK: - Table View Datasource
extension RankViewController{
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.userList[indexPath.row].0
        print(user.name)
        if !self.makeMode{
            performSegue(withIdentifier: "goToUserMatch", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! UserMatchHistoryViewController
        
        if let indexPath = self.tableView.indexPathForSelectedRow{
            destinationVC.userMatchDict = self.userMatchDict
            destinationVC.puuid = self.userList[indexPath.row].1
            destinationVC.champData = self.champData
            destinationVC.version = self.version
            destinationVC.MatchDict = self.MatchDict
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserRankCell", for: indexPath) as? UserRankCell else{
            return UITableViewCell()
        }
        
        let user = self.userList[indexPath.row].0
        let puuid = self.userList[indexPath.row].1
        
        let champMost: [String] = (0...2).map{
            guard let champCnt = userChampCnt[puuid] else{
                return "blank"
            }
            return champData[champCnt[$0]]?.id ?? "blank"
        }
        cell.configure(user, champMost, self.version)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension RankViewController{
    func initData(){
        let data = realm.objects(DataCache.self)
        let semaphore = DispatchSemaphore(value: 0)
        var version = ""
        self.getVersion {result in
            switch result{
            case let .success(result):
                version = result.v
                semaphore.signal()
            case let .failure(error):
                print(error.localizedDescription)
                return
            }
        }
        
        if data.count == 0 || data.first!.version != version{
            DispatchQueue.global().async {
                semaphore.wait()
                let data = DataCache()
                data.version = version
                self.getChampion(version) {[weak self] result in
                    guard let self = self else{
                        return
                    }
                    switch result{
                    case let .success(result):
                        result.data.forEach{
                            let champData = ChampionCache()
                            champData.id = $0.value.id
                            champData.key = $0.value.key
                            champData.name = $0.value.name
                            
                            data.champions.append(champData)
                            self.champData[Int($0.value.key) ?? 0] = $0.value
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        self.save(data: data)
                    case let .failure(error):
                        print(error.localizedDescription)
                        return
                    }
                }
            }
        }else{
            data.first!.champions.forEach {
                self.champData[Int($0.key) ?? 0] = Champion(id: $0.id, key: $0.key, name: $0.name)
            }
            self.tableView.reloadData()
        }
    }
    
    func save(data: DataCache){
        do{
            try realm.write({
                realm.add(data)
            })
        }catch{
            print("Error saving cache, \(error)")
        }
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
                $0.0.matchDate > $1.0.matchDate
            })
            
            self.userChampCnt[puuid] = champCnt.sorted(by: {
                $0.value > $1.value
            }).map{
                $0.key
            }
            
            while self.userChampCnt[puuid]!.count < 3{
                self.userChampCnt[puuid]!.append(-1)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                if self.userMatchDict.count == self.userList.count{
                    self.tableView.allowsSelection = true
                }
            }
        }
    }
    
    func getAllMatch(){
        db.collection("matches").addSnapshotListener { snapshot, error in
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

    func getAllUser(){
        db.collection("users").addSnapshotListener {snapshot, error in
            guard let documents = snapshot?.documents else{
                print("Error Firestore fetching document \(String(describing: error))")
                return
            }
            
            self.userList = documents.compactMap({ doc -> (User,String)? in
                do{
                    let user = try doc.data(as: User.self)
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
