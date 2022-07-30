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

class RankViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var userList = [(User,String)]()
    var userChampCnt = [String: [Int]]()
    var userMatchDict = [String: Array<(UserMatch,String)>]()
    var MatchDict = [String: Match]()

    var champData = [Int: Champion]()
    var version = "12.12.1"
    var db = Firestore.firestore()
    var makeMode = false
    let realm = try! Realm()
    
    enum Section{
        case main
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nibName = UINib(nibName: "UserRankCell", bundle: nil)
        self.collectionView.register(nibName, forCellWithReuseIdentifier: "UserRankCell")
        self.collectionView.allowsSelection = false
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.initData()
        self.getAllUser()
        self.getAllMatch()
        
        if let flowlayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout{
            flowlayout.estimatedItemSize = .zero
        }
    }
    
    @IBAction func makeMatchTapped(_ sender: UIBarButtonItem) {
        //makeMode.toggle()
    }
    
}

//MARK: - Table View Datasource
extension RankViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = self.userList[indexPath.item].0
        print(user.name)
        if !self.makeMode{
            performSegue(withIdentifier: "goToUserMatch", sender: self)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! UserMatchHistoryViewController
        
        if let indexPath = self.collectionView.indexPathsForSelectedItems?.first{
            destinationVC.userMatchDict = self.userMatchDict
            destinationVC.puuid = self.userList[indexPath.item].1
            destinationVC.champData = self.champData
            destinationVC.version = self.version
            destinationVC.MatchDict = self.MatchDict
        }
    }
    
    func numberOfSections(in tableView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.userList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "UserRankCell", for: indexPath) as? UserRankCell else{
            return UICollectionViewCell()
        }
        
        let user = self.userList[indexPath.item].0
        let puuid = self.userList[indexPath.item].1
        
        let champMost: [String] = (0...2).map{
            guard let champCnt = userChampCnt[puuid] else{
                return "blank"
            }
            return champData[champCnt[$0]]?.id ?? "blank"
        }
        cell.configure(user, champMost, self.version)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.bounds.width , height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
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
                            self.collectionView.reloadData()
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
            self.collectionView.reloadData()
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
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                if self.userMatchDict.count == self.userList.count{
                    self.collectionView.allowsSelection = true
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
                self.collectionView.reloadData()
            }
        }
    }
}
