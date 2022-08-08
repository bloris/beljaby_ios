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
import Combine

class RankViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var userList = CurrentValueSubject<[User], Never>([User]())
    var userChampCnt = [String: [Int]]()
    
    var userDict = [String:User]()
    var userMatchDict = [String: Array<UserMatch>]()
    var MatchDict = [String: Match]()
    
    var subscriptions = Set<AnyCancellable>()
    
    var db = Firestore.firestore()
    var makeMode = false
    
    enum Section{
        case main
    }
    
    var datasource: UICollectionViewDiffableDataSource<Section, User>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureCollectionView()
        
        self.configureData()
        
        self.bind()
    }
    
    @IBAction func makeMatchTapped(_ sender: UIBarButtonItem) {
        //makeMode.toggle()
        /*
         change bar button to done button
         mupltiple selct mode active
         select 10 user -> tap done button
         present or push balanced team member view
         */
    }
    
    private func configureData(){
        self.getAllUser()
        self.getAllMatch()
    }
    
    private func bind(){
        self.userList
            .receive(on: RunLoop.main)
            .sink {[unowned self] users in
                self.applySectionItems(users)
            }.store(in: &subscriptions)
    }
}

//MARK: - Configure CollectionView
extension RankViewController{
    private func configureCollectionView(){
        //link cell to collectionView
        let nibName = UINib(nibName: "UserRankCell", bundle: nil)
        self.collectionView.register(nibName, forCellWithReuseIdentifier: "UserRankCell")
        
        self.collectionView.delegate = self
        self.collectionView.allowsSelection = false //Disable selection before load user match history data
        
        datasource = UICollectionViewDiffableDataSource<Section, User>(collectionView: self.collectionView, cellProvider: { collectionView, indexPath, user in
            guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "UserRankCell", for: indexPath) as? UserRankCell else{
                return nil
            }
            
            cell.configure(user, self.userChampCnt)
            return cell
        })
        
        self.collectionView.collectionViewLayout = layout()
    }
    
    private func layout() -> UICollectionViewCompositionalLayout{
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(60))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0)
        section.interGroupSpacing = 5
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    private func applySectionItems(_ items: [User], to section: Section = .main){
        var snapshot = NSDiffableDataSourceSnapshot<Section, User>()
        snapshot.appendSections([section])
        snapshot.appendItems(items, toSection: section)
        datasource.apply(snapshot)
    }
}

//MARK: - Table View Datasource
extension RankViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = self.userList.value[indexPath.item]
        print(user.name)
        let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "UserMatchHistoryViewController") as! UserMatchHistoryViewController
        
        destinationVC.userMatchList.send(self.userMatchDict[user.puuid] ?? [])
        destinationVC.puuid = user.puuid
        destinationVC.MatchDict = self.MatchDict
        destinationVC.userList = self.userList.value
        destinationVC.userDict = self.userDict
        
        destinationVC.title = "\(user.name) 대전 기록"
        
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
}

//MARK: - Cloud Firestore Database Read
extension RankViewController{
    func getAllUserMatch(puuid: String){
        self.db.collection("users").document(puuid).collection("userMatch").getDocuments { (snapshot, error) in
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
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                if self.userMatchDict.count == self.userList.value.count{
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
