//
//  UserMatchHistoryViewController.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/07/19.
//

import UIKit
import Kingfisher
import Combine
import SwiftUI

class UserMatchHistoryViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var subscriptions = Set<AnyCancellable>()
    
    enum Section {
        case main
    }
    
    var datasource: UICollectionViewDiffableDataSource<Section, UserMatch>!
    var viewModel: UserMatchHistoryViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        configureCollectionView()
        bind()
    }
    
    private func bind() {
        // Bind Input UserMatchHistory Cell Tapped -> Push MatchDetail View
        viewModel.selectedMatchDetail
            .receive(on: RunLoop.main)
            .compactMap( { $0 } )
            .sink { [unowned self] matchDetail in
                let detailViewModel = MatchDetailViewModel(matchDetails: matchDetail)
                let detailView = MatchDetailView(viewModel: detailViewModel)
                let vc = UIHostingController(rootView: detailView) // Integrate SwiftUI View to UIKit
                
                self.navigationController?.pushViewController(vc, animated: true)
            }.store(in: &subscriptions)
        
        // Bind UserMatch List from Firebase -> Apply Section Item to Diffable Datasource
        viewModel.userMatchList
            .receive(on: RunLoop.main)
            .sink { [unowned self] userMatches in
                self.applySectionItems(userMatches, to: .main)
            }.store(in: &subscriptions)
    }
    
    private func configureCollectionView() {
        // Register xib CollectionView Cell
        let nibName = UINib(nibName: "UserMatchHistoryCell", bundle: nil)
        collectionView.register(nibName, forCellWithReuseIdentifier: "UserMatchHistoryCell")
        
        collectionView.delegate = self
        
        datasource = UICollectionViewDiffableDataSource<Section, UserMatch>(collectionView: self.collectionView, cellProvider: { collectionView, indexPath, userMatch in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserMatchHistoryCell", for: indexPath) as? UserMatchHistoryCell else {
                return nil
            }
            
            cell.configure(userMatch)
            
            return cell
        })
        
        applySectionItems([], to: .main) // Initialize Section Item with Empty Array
        
        collectionView.collectionViewLayout = layout()
    }
    
    /// Apply Section Items to Diffable datasource
    private func applySectionItems(_ items: [UserMatch], to section: Section) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, UserMatch>()
        snapshot.appendSections([section])
        snapshot.appendItems(items, toSection: section)
        datasource.apply(snapshot)
    }
    
    private func layout() -> UICollectionViewCompositionalLayout {
        let cnt = max(1.0, self.view.bounds.width / 370) // Calc maximum item for row with minimum width
        let interItemSpacing: CGFloat = 10
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/cnt), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(190))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: Int(cnt))
        group.interItemSpacing = .fixed(interItemSpacing)
        
        let section = NSCollectionLayoutSection(group: group)
        
        let totalCellWidth = cnt.rounded(.down) * (self.view.bounds.width/cnt)
        let totalSapcing = (cnt.rounded(.down)-1) * interItemSpacing
        let inset = self.view.bounds.width - (totalSapcing+totalCellWidth) // Calc remain width to align center
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: inset/2, bottom: 10, trailing: inset/2) // Use ramin width with inset
        section.interGroupSpacing = 10
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    // Rotate iphone -> update layout
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout = layout()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
}

extension UserMatchHistoryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelect(at: indexPath) // Send selected indexPath to viewModel
    }
}
