//
//  UserRankCell.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/07/05.
//

import UIKit
import Kingfisher

class UserRankCell: UICollectionViewCell {
    private let realmManager = LolRealmManager.shared
    private let firebaseManager = FirebaseManager.shared

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var tierImage: UIImageView!
    @IBOutlet weak var mostOneImage: UIImageView!
    @IBOutlet weak var mostSecondImage: UIImageView!
    @IBOutlet weak var mostThirdImage: UIImageView!
    
    @IBOutlet weak var winView: UIView!
    @IBOutlet weak var loseView: UIView!
    @IBOutlet weak var entireView: UIStackView!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var elo: UILabel!
    @IBOutlet weak var ratioLabel: UILabel!
    @IBOutlet weak var winLabel: UILabel!
    @IBOutlet weak var loseLabel: UILabel!
    @IBOutlet weak var tierLabel: UILabel!
    
    @IBOutlet weak var ratioConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initView()
    }
    
    func configure(_ user: User){
        let champImageList = [self.mostOneImage, self.mostSecondImage, self.mostThirdImage]
        let version = realmManager.ver
        
        let profileImageURL = URL(string: "https://ddragon.leagueoflegends.com/cdn/\(version)/img/profileicon/\(user.profileIconId).png")
        
        let champMost: [String] = (0...2).map{
            guard let champCnt = self.firebaseManager.userChampCnt[user.puuid] else{
                return "blank"
            }
            return realmManager.champData[champCnt[$0]]?.id ?? "blank"
        }
        
        let champURL: [URL?] = champMost.map{
            URL(string: "https://ddragon.leagueoflegends.com/cdn/\(version)/img/champion/\($0).png")
        }
        
        let win = user.win
        let lose = user.lose
        let ratio = win+lose != 0 ? 100*Double(win)/Double(win+lose) : 0.0
        
        self.profileImage.kf.setImage(with: profileImageURL)
        
        for (idx, url) in champURL.enumerated(){
            if champMost[idx] != "blank"{
                champImageList[idx]?.kf.setImage(with: url)
            }else{
                champImageList[idx]?.image = nil
            }
        }
        
        tierImage.image = UIImage(named: "Emblem_\(user.tier)")
        name.text = user.name
        elo.text = "\(user.elo)LP"
        tierLabel.text = user.tier
        winLabel.text = "\(win)W"
        loseLabel.text = "\(lose)L"
        ratioLabel.text = "\(Int(ratio))%"
        ratioConstraint = ratioConstraint.setMultiplier(multiplier: ratio/50)
    }
    
    func setCornerRadius<V:UIView>(_ view: V,_ radius: CGFloat){
        view.clipsToBounds = true
        view.layer.cornerRadius = radius
        view.layer.borderWidth = 1
    }
    
    func initView(){
        [entireView,profileImage].forEach{
            setCornerRadius($0, 5)
        }
         
        
        [mostOneImage, mostSecondImage, mostThirdImage].forEach {
            setCornerRadius($0, $0.frame.height/2)
        }
        
        entireView.layer.borderWidth = 0
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 5
    }
}
