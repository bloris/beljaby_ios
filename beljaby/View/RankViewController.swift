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
    
    private let firebaseManager = FirebaseManager.shared
    
    var subscriptions = Set<AnyCancellable>()
    
    enum Section{
        case main
    }
    
    var datasource: UICollectionViewDiffableDataSource<Section, User>!
    var viewModel: RankViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel = RankViewModel()
        
        self.configureCollectionView()
        
        self.bind()
    }
    
    @IBAction func makeMatchTapped(_ sender: UIButton) {
        /*
         present select view with simple view(ex: only name and elo?)
         balancing button in below
         if tap button -> make balanced team
         */
        /*
         change bar button to done button
         mupltiple selct mode active
         select 10 user -> tap done button
         present or push balanced team member view
         */
        print("123")
    }
    
    private func bind(){
        self.viewModel.selectedUser
            .receive(on: RunLoop.main)
            .compactMap({$0})
            .sink { [unowned self] user in
                let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "UserMatchHistoryViewController") as! UserMatchHistoryViewController
                
                destinationVC.viewModel = UserMatchHistoryViewModel(puuid: self.viewModel.puuid)
                destinationVC.title = self.viewModel.historyViewTitle
                
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }.store(in: &subscriptions)
        
        self.firebaseManager.userList
            .receive(on: RunLoop.main)
            .sink { [unowned self] users in
                self.applySectionItems(users)
            }.store(in: &subscriptions)
        
        self.firebaseManager.userMatchLoad
            .receive(on: RunLoop.main)
            .sink { [unowned self] complete in
                if complete{
                    self.collectionView.reloadData()
                    self.collectionView.allowsSelection = true
                }
            }.store(in: &subscriptions)
    }
}

//MARK: - Configure CollectionView
extension RankViewController{
    private func configureCollectionView(){
        let nibName = UINib(nibName: "UserRankCell", bundle: nil)
        self.collectionView.register(nibName, forCellWithReuseIdentifier: "UserRankCell")
        
        self.collectionView.delegate = self
        self.collectionView.allowsSelection = false //Disable selection before load user match history data
        
        datasource = UICollectionViewDiffableDataSource<Section, User>(collectionView: self.collectionView, cellProvider: { collectionView, indexPath, user in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserRankCell", for: indexPath) as? UserRankCell else{
                return nil
            }
            
            cell.configure(user)
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

//MARK: - Collection View Delegate
extension RankViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel.didSelect(at: indexPath)
    }
}
