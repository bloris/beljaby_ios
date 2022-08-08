//
//  UserMatchHistoryViewController.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/07/19.
//

import UIKit
import Kingfisher
import Combine

private let reuseIdentifier = "Cell"

class UserMatchHistoryViewController: UIViewController {
    private let realmManager = LolRealmManager.shared
    private let firebaseManager = FirebaseManager.shared
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var puuid = CurrentValueSubject<String,Never>("")
    
    var subscriptions = Set<AnyCancellable>()
    
    enum Section{
        case main
    }
    
    var datasource: UICollectionViewDiffableDataSource<Section, UserMatch>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.configureCollectionView()
        
        self.bind()
    }
    
    private func bind(){
        puuid
            .receive(on: RunLoop.main)
            .sink { puuid in
                self.applySectionItems(self.firebaseManager.userMatchDict[puuid] ?? [])
            }.store(in: &subscriptions)
    }
    
    private func configureCollectionView(){
        let nibName = UINib(nibName: "UserMatchHistoryCell", bundle: nil)
        self.collectionView.register(nibName, forCellWithReuseIdentifier: "UserMatchHistoryCell")
        
        self.collectionView.delegate = self
        
        datasource = UICollectionViewDiffableDataSource<Section, UserMatch>(collectionView: self.collectionView, cellProvider: {collectionView, indexPath, userMatch in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserMatchHistoryCell", for: indexPath) as? UserMatchHistoryCell else{
                return nil
            }
            
            cell.configure(userMatch)
            
            return cell
        })
        
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
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(190))
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.collectionView.collectionViewLayout = layout()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
}

extension UserMatchHistoryViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected!")
    }
}
