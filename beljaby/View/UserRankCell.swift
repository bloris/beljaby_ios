//
//  UserRankCell.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/07/05.
//

import UIKit
import Kingfisher

class UserRankCell: UICollectionViewCell {

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
    
    func configure(_ user: User, _ champMost: [String], _ version: String){
        let champImageList = [self.mostOneImage, self.mostSecondImage, self.mostThirdImage]
        
        let profileImageURL = URL(string: "https://ddragon.leagueoflegends.com/cdn/\(version)/img/profileicon/\(user.profileIconId).png")
        
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
            }
        }
        
        tierImage.image = UIImage(named: "Emblem_\(user.tier)")
        name.text = user.name
        elo.text = "\(user.elo)LP"
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

extension NSLayoutConstraint {
    /**
     Change multiplier constraint

     - parameter multiplier: CGFloat
     - returns: NSLayoutConstraint
    */
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {

        NSLayoutConstraint.deactivate([self])

        let newConstraint = NSLayoutConstraint(
            item: firstItem!,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)

        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier

        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}
