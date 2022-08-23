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
import SwiftUI

class RankViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let firebaseManager = FirebaseManager.shared //Get Firebase Singleton Object -> Move to ViewModel
    
    var subscriptions = Set<AnyCancellable>() //Store subscriptions
    
    enum Section {
        case main
    }
    
    var datasource: UICollectionViewDiffableDataSource<Section, User>!
    var viewModel: RankViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = RankViewModel() //Load ViewModel
        
        configureCollectionView() //Configure CollectionView
        
        bind() //Bind with ViewModel Publihser
    }
    
    @IBAction func makeMatchTapped(_ sender: UIButton) {
        viewModel.makeButtonTapped() //Send Tapped Action
    }
    
    private func bind() {
        //Bind Input User Rank Cell Tapped -> Push UserMatchHistory View
        viewModel.selectedUser
            .receive(on: RunLoop.main)
            .compactMap( { $0 } )
            .sink { [unowned self] user in
                let sb = UIStoryboard(name: "UserMatchHistory", bundle: nil)
                let destinationVC = sb.instantiateViewController(withIdentifier: "UserMatchHistoryViewController") as! UserMatchHistoryViewController
                
                destinationVC.viewModel = UserMatchHistoryViewModel(puuid: self.viewModel.puuid)
                destinationVC.title = self.viewModel.historyViewTitle
                
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }.store(in: &subscriptions)
        
        //Bind Input Make Match Button Tap -> Push Matchmaking View
        viewModel.makeButton
            .receive(on: RunLoop.main)
            .sink { [unowned self] in
                let matchMakingViewModel = MatchMakingViewModel(deligate: self.viewModel)
                let matchMakingView = MatchMakingView(viewModel: matchMakingViewModel)
                let vc = UIHostingController(rootView: matchMakingView)
                
                self.present(vc, animated: true)
            }.store(in: &subscriptions)
        
        //Bind Delegate Input from Matchmaking View -> Push Balanced Team View
        viewModel.delegateReceive
            .receive(on: RunLoop.main)
            .sink { [unowned self] (team1, team2) in
                let balancedTeamViewModel = BalancedTeamViewModel(team1: team1, team2: team2)
                let balancedTeamView = BalancedTeamView(viewModel: balancedTeamViewModel)
                let vc = UIHostingController(rootView: balancedTeamView)
                vc.navigationItem.largeTitleDisplayMode = .never
                
                self.navigationController?.pushViewController(vc, animated: true)
            }.store(in: &subscriptions)
        
        //Bind User Info List from Firebase -> Apply Section Item to Diffable Datasource
        firebaseManager.userList
            .receive(on: RunLoop.main)
            .sink { [unowned self] users in
                self.applySectionItems(users)
            }.store(in: &subscriptions)
        
        //Bind User Match Info List from Firebase -> Allow Selection
        //Need to Refactoring
        firebaseManager.userMatchLoad
            .receive(on: RunLoop.main)
            .sink { [unowned self] in
                self.collectionView.reloadData()
                self.collectionView.allowsSelection = true
            }.store(in: &subscriptions)
    }
}

//MARK: - Configure CollectionView
extension RankViewController {
    private func configureCollectionView() {
        //Register xib CollectionView Cell
        let nibName = UINib(nibName: "UserRankCell", bundle: nil)
        collectionView.register(nibName, forCellWithReuseIdentifier: "UserRankCell")
        
        collectionView.delegate = self //CollectionView Delegate for didSelectItem
        collectionView.allowsSelection = false //Disable selection before load user match history data
        
        datasource = UICollectionViewDiffableDataSource<Section, User>(collectionView: self.collectionView, cellProvider: { collectionView, indexPath, user in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserRankCell", for: indexPath) as? UserRankCell else {
                return nil
            }
            
            cell.configure(user)
            return cell
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, User>()
        snapshot.appendSections([.main])
        snapshot.appendItems([], toSection: .main)
        datasource.apply(snapshot)
        
        collectionView.collectionViewLayout = layout()
    }
    
    private func layout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(60))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(60))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0)
        section.interGroupSpacing = 5
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    private func applySectionItems(_ items: [User], to section: Section = .main) {
        var snapshot = datasource.snapshot()
        snapshot.appendItems(items, toSection: section)
        datasource.apply(snapshot)
    }
}

//MARK: - Collection View Delegate
extension RankViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelect(at: indexPath)
    }
}
