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
    //UserMatchCell
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
    
    /*
     // MARK: - Navigation
     
     */
    
    // MARK: UICollectionViewDataSource
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        flowLayout.invalidateLayout()
    }
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.userMatchDict?[self.puuid ?? ""]?.count ?? 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserMatchHistoryCell", for: indexPath) as? UserMatchHistoryCell else{
            return UICollectionViewCell()
        }
        
        if let matchTuple = self.userMatchDict?[self.puuid ?? ""]?[indexPath.row]{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"
            let match = matchTuple.0
            let gameDuration = self.MatchDict![matchTuple.1]!.gameDuration
            
            let champ = self.champData![match.champ]!
            var itemList = match.item.filter{$0 != 0}
            while itemList.count < 7{
                itemList.insert(0, at: itemList.count - 1)
            }

            let itemImageURL: [URL?] = itemList.map{
                if $0 == 0{
                    return nil
                }
                return URL(string: "https://ddragon.leagueoflegends.com/cdn/\(version!)/img/item/\($0).png")
            }
            let splashURL = URL(string: "https://ddragon.leagueoflegends.com/cdn/img/champion/splash/\(champ.id)_0.jpg")
            
            
            cell.dateLabel.text = dateFormatter.string(from: match.matchDate) + String(format: "  %02d:%02d분", gameDuration/60,gameDuration%60)
            
            if match.win{
                cell.winLabel.text = "승리"
                cell.winLabel.textColor = .black
                cell.winView.backgroundColor = UIColor(red: 0.04, green: 0.77, blue: 0.89, alpha: 1.00)
            }else{
                cell.winLabel.text = "패배"
                cell.winLabel.textColor = .white
                cell.winView.backgroundColor = UIColor(red: 0.82, green: 0.22, blue: 0.22, alpha: 1.00)
            }
            
            cell.eloChange.text = (match.eloChange > 0 ? "+" : "") + "\(match.eloChange)"
            
            cell.champName.text = champ.name
            cell.champLevel.text = "\(match.champLevel)"
            
            cell.killScoreLabel.text = "\(match.kill)/\(match.death)/\(match.assist)"
            cell.csLabel.text = "\(match.cs) "+String(format: "(%.1f)", (Double(match.cs)/(Double(gameDuration)/600.0)+5.0)/10.0)
            cell.goldEarnedLabel.text = String(format: "%.1f천", Double(match.goldEarned+50)/1000.0)
            
            cell.killPLabel.text = "킬관여 \(match.killP)%"
            cell.wardLabel.text = "제어 와드 \(match.ward)"
            
            if let url = itemImageURL[0] {cell.item0.kf.setImage(with: url)}
            if let url = itemImageURL[1] {cell.item1.kf.setImage(with: url)}
            if let url = itemImageURL[2] {cell.item2.kf.setImage(with: url)}
            if let url = itemImageURL[3] {cell.item3.kf.setImage(with: url)}
            if let url = itemImageURL[4] {cell.item4.kf.setImage(with: url)}
            if let url = itemImageURL[5] {cell.item5.kf.setImage(with: url)}
            if let url = itemImageURL[6] {cell.item6.kf.setImage(with: url)}
            
            cell.mainPerkImage.image = UIImage(named: "\(match.mainPerk)")
            cell.subPerkImage.image = UIImage(named: "\(match.subPerk)")
            
            cell.champSplashImage.kf.setImage(with: splashURL)
            
            let gradientMaskLayer = CAGradientLayer()
            gradientMaskLayer.frame = cell.champSplashImage.bounds
            gradientMaskLayer.colors =  [UIColor.white.cgColor, UIColor.clear.cgColor]
            gradientMaskLayer.locations = [0.8, 1]
            
            cell.champSplashImage.layer.mask = gradientMaskLayer
        }
        
        
        return cell
    }

    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
    
}

extension UserMatchHistoryViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cnt = self.view.frame.width / 370
        
        return CGSize(width: self.view.frame.width/cnt , height: 180)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let cnt = self.view.frame.width / 370
        let totalCellWidth = cnt.rounded(.down) * (self.view.frame.width/cnt)
        let totalSapcing = (cnt.rounded(.down)-1) * 10
        let inset = self.view.frame.width - (totalSapcing+totalCellWidth)
        
        return UIEdgeInsets(top: 10, left: inset/2, bottom: 10, right: inset/2)
    }
    
}
