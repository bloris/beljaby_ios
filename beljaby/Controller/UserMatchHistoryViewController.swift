//
//  UserMatchHistoryViewController.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/07/19.
//

import UIKit
import Kingfisher

private let reuseIdentifier = "Cell"

class UserMatchHistoryViewController: UICollectionViewController {
    var userMatchDict: [String: Array<(UserMatch,String)>]?
    var MatchDict: [String: Match]?
    var puuid: String?
    var champData: [Int: Champion]?
    var version: String?
    
    var MatchList = [Match]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nibName = UINib(nibName: "UserMatchHistoryCell", bundle: nil)
        self.collectionView.register(nibName, forCellWithReuseIdentifier: "UserMatchHistoryCell")
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        flowLayout.invalidateLayout()
    }
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.userMatchDict?[self.puuid ?? ""]?.count ?? 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserMatchHistoryCell", for: indexPath) as? UserMatchHistoryCell else{
            return UICollectionViewCell()
        }
        
        if let matchTuple = self.userMatchDict?[self.puuid ?? ""]?[indexPath.row], let version = self.version{
            let userMatch = matchTuple.0
            let matchId = matchTuple.1
            let match = self.MatchDict![matchId]!
            let champ = self.champData![userMatch.champ]!
            
            cell.configure(userMatch, match, version, champ)
        }
        
        
        return cell
    }
}

extension UserMatchHistoryViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cnt = self.view.frame.width / 370
        
        return CGSize(width: self.view.frame.width/cnt , height: 190)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let cnt = self.view.frame.width / 370
        let totalCellWidth = cnt.rounded(.down) * (self.view.frame.width/cnt)
        let totalSapcing = (cnt.rounded(.down)-1) * 10
        let inset = self.view.frame.width - (totalSapcing+totalCellWidth)
        
        return UIEdgeInsets(top: 10, left: inset/2, bottom: 10, right: inset/2)
    }
    
}
