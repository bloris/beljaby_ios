//
//  UserMatchHistoryCell.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/07/18.
//

import UIKit
import Kingfisher

class UserMatchHistoryCell: UICollectionViewCell {
    private let realmManager = LolRealmManager.shared
    private let firebaseManager = FirebaseManager.shared
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var winView: UIView!
    @IBOutlet weak var winLabel: UILabel!
    
    @IBOutlet weak var champSplashImage: UIImageView!
    @IBOutlet weak var champLevel: UILabel!
    @IBOutlet weak var champLevelView: UIView!
    @IBOutlet weak var champName: UILabel!
    
    @IBOutlet weak var item0: UIImageView!
    @IBOutlet weak var item1: UIImageView!
    @IBOutlet weak var item2: UIImageView!
    @IBOutlet weak var item3: UIImageView!
    @IBOutlet weak var item4: UIImageView!
    @IBOutlet weak var item5: UIImageView!
    @IBOutlet weak var item6: UIImageView!
    
    @IBOutlet weak var eloChange: UILabel!
    @IBOutlet weak var killScoreLabel: UILabel!
    @IBOutlet weak var csLabel: UILabel!
    @IBOutlet weak var goldEarnedLabel: UILabel!
    
    @IBOutlet weak var blurMaskView: UIView!
    @IBOutlet weak var killPLabel: UILabel!
    @IBOutlet weak var wardLabel: UILabel!
    
    @IBOutlet weak var mainPerkImage: UIImageView!
    @IBOutlet weak var subPerkImage: UIImageView!
    
    let colorList = [UIColor(red: 0.04, green: 0.77, blue: 0.89, alpha: 1.00), UIColor(red: 0.82, green: 0.22, blue: 0.22, alpha: 1.00)]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initView()
    }
    
    func setCornerRadius<V:UIView>(_ view: V,_ radius: CGFloat) {
        view.clipsToBounds = true
        view.layer.cornerRadius = radius
        
    }
    
    func configure(_ userMatch: UserMatch) {
        guard let match = firebaseManager.MatchDict[userMatch.matchId], let champ = realmManager.champData[userMatch.champ] else {
            return
        }
        
        let gameDuration = match.gameDuration
        let dateFormatter = DateFormatter()
        let version = realmManager.ver
        
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        let matchDate = dateFormatter.string(from: match.matchDate)
        let duration = String(format: "  %02d:%02d분", gameDuration/60,gameDuration%60)
        
        let itemImageList: [UIImageView] = [item0, item1, item2, item3, item4, item5, item6]
        var itemList = userMatch.item.filter { $0 != 0 }
        while itemList.count < 7 {
            itemList.insert(0, at: itemList.count - 1)
        }
        
        let itemImageURL: [URL?] = itemList.map {
            if $0 == 0 { return nil }
            return URL(string: "https://ddragon.leagueoflegends.com/cdn/\(version)/img/item/\($0).png")
        }
        
        let splashURL = URL(string: "https://ddragon.leagueoflegends.com/cdn/img/champion/splash/\(champ.id)_0.jpg")
        
        dateLabel.text  = matchDate + duration
        
        winLabel.text = userMatch.win ? "승리" : "패배"
        winLabel.textColor = userMatch.win ? .black : .white
        winView.backgroundColor = userMatch.win ? colorList[0] : colorList[1]
        
        eloChange.text = (userMatch.eloChange > 0 ? "+" : "") + "\(userMatch.eloChange)"
        
        champName.text = champ.name
        champLevel.text = "\(userMatch.champLevel)"
        
        killScoreLabel.text = "\(userMatch.kill)/\(userMatch.death)/\(userMatch.assist)"
        csLabel.text = "\(userMatch.cs) "+String(format: "(%.1f)", (Double(userMatch.cs)/(Double(gameDuration)/600.0)+5.0)/10.0)
        goldEarnedLabel.text = String(format: "%.1f천", Double(userMatch.goldEarned+50)/1000.0)
        
        killPLabel.text = "킬관여 \(userMatch.killP)%"
        wardLabel.text = "제어 와드 \(userMatch.ward)"
        
        mainPerkImage.image = UIImage(named: "\(userMatch.mainPerk)")
        subPerkImage.image = UIImage(named: "\(userMatch.subPerk)")
        
        champSplashImage.kf.setImage(with: splashURL)
        
        let gradientMaskLayer = CAGradientLayer()
        gradientMaskLayer.frame = champSplashImage.bounds
        gradientMaskLayer.colors =  [UIColor.white.cgColor, UIColor.clear.cgColor]
        gradientMaskLayer.locations = [0.8, 1]
        
        champSplashImage.layer.mask = gradientMaskLayer
        
        for (idx, itemURL) in itemImageURL.enumerated() {
            if let url = itemURL {
                itemImageList[idx].kf.setImage(with: url)
            } else {
                itemImageList[idx].image = nil
            }
        }
    }
    
    func initView() {
        [item0,item1,item2,item3,item4,item5,item6].forEach {
            setCornerRadius($0, 5)
        }
        
        [champLevelView,winView,mainPerkImage].forEach {
            setCornerRadius($0, $0.frame.height/2)
        }
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
    }
}
