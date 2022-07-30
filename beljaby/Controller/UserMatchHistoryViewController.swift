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
    
    var userMatchDict: [String: Array<(UserMatch,String)>]?
    var MatchDict: [String: Match]?
    var puuid: String?
    var version: String?
    
    var MatchList = [Match]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        let nibName = UINib(nibName: "UserMatchHistoryCell", bundle: nil)
        self.collectionView.register(nibName, forCellWithReuseIdentifier: "UserMatchHistoryCell")
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        if let flowlayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout{
            flowlayout.estimatedItemSize = .zero
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        flowLayout.invalidateLayout()
    }
}

extension UserMatchHistoryViewController: UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.userMatchDict?[self.puuid ?? ""]?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserMatchHistoryCell", for: indexPath) as? UserMatchHistoryCell else{
            return UICollectionViewCell()
        }
        
        if let matchTuple = self.userMatchDict?[self.puuid ?? ""]?[indexPath.row], let version = self.version{
            let userMatch = matchTuple.0
            let matchId = matchTuple.1
            let match = self.MatchDict![matchId]!
            let champ = Champion.champData[userMatch.champ]!
            
            cell.configure(userMatch, match, version, champ)
        }
        
        return cell
    }
}

extension UserMatchHistoryViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cnt = self.collectionView.bounds.width / 370
        return CGSize(width: self.collectionView.bounds.width/cnt , height: 190)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let cnt = self.collectionView.bounds.width / 370
        let totalCellWidth = cnt.rounded(.down) * (self.collectionView.bounds.width/cnt)
        let totalSapcing = (cnt.rounded(.down)-1) * 10
        let inset = self.collectionView.bounds.width - (totalSapcing+totalCellWidth)
        
        return UIEdgeInsets(top: 10, left: inset/2, bottom: 10, right: inset/2)
    }
    
}
