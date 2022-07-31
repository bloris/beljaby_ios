//
//  UserMatchHistoryViewController.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/07/19.
//

import UIKit
import Kingfisher

private let reuseIdentifier = "Cell"

class UserMatchHistoryViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var userMatchDict: [String: Array<UserMatch>]?
    var MatchDict: [String: Match]?
    var puuid: String?
    var version: String?
    
    var MatchList = [Match]()
    
    enum Section{
        case main
    }
    
    var datasource: UICollectionViewDiffableDataSource<Section, UserMatch>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.configureCollectionView()
    }
    
    private func configureCollectionView(){
        let nibName = UINib(nibName: "UserMatchHistoryCell", bundle: nil)
        self.collectionView.register(nibName, forCellWithReuseIdentifier: "UserMatchHistoryCell")
        
        self.collectionView.delegate = self
        
        datasource = UICollectionViewDiffableDataSource<Section, UserMatch>(collectionView: self.collectionView, cellProvider: { collectionView, indexPath, userMatch in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserMatchHistoryCell", for: indexPath) as? UserMatchHistoryCell, let version = self.version else{
                return nil
            }
            let match = self.MatchDict![userMatch.matchId]!
            let champ = Champion.champData[userMatch.champ]!
            
            cell.configure(userMatch, match, version, champ)
            
            return cell
        })
        
        self.applySectionItems(self.userMatchDict![self.puuid!]!)
        
        self.collectionView.collectionViewLayout = layout()
    }
    
    private func applySectionItems(_ items: [UserMatch], to section: Section = .main){
        var snapshot = NSDiffableDataSourceSnapshot<Section, UserMatch>()
        snapshot.appendSections([section])
        snapshot.appendItems(items, toSection: section)
        self.datasource.apply(snapshot)
    }
    
    private func layout() -> UICollectionViewCompositionalLayout{
        let cnt = self.view.bounds.width / 370
        let interItemSpacing: CGFloat = 10
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/cnt), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(190))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: Int(cnt))
        group.interItemSpacing = .fixed(interItemSpacing)
        
        let section = NSCollectionLayoutSection(group: group)
        
        let totalCellWidth = cnt.rounded(.down) * (self.view.bounds.width/cnt)
        let totalSapcing = (cnt.rounded(.down)-1) * interItemSpacing
        let inset = self.view.bounds.width - (totalSapcing+totalCellWidth)
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: inset/2, bottom: 10, trailing: inset/2)
        section.interGroupSpacing = 10
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.collectionView.collectionViewLayout = layout()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
}

extension UserMatchHistoryViewController: UICollectionViewDelegate{
    
}
