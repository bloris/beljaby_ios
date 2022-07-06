//
//  UserRankCell.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/07/05.
//

import UIKit
import Kingfisher

class UserRankCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var tierImage: UIImageView!
    @IBOutlet weak var mostOneImage: UIImageView!
    @IBOutlet weak var mostSecondImage: UIImageView!
    @IBOutlet weak var mostThirdImage: UIImageView!
    
    
    @IBOutlet weak var winView: UIView!
    @IBOutlet weak var loseView: UIView!
    
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var elo: UILabel!
    @IBOutlet weak var ratioLabel: UILabel!
    @IBOutlet weak var winLabel: UILabel!
    @IBOutlet weak var loseLabel: UILabel!
    
    
    @IBOutlet weak var ratioConstraint: NSLayoutConstraint!
    
    let win = 70
    let lose = 50
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureView()
    }
    
    func configureView(){
        winView.clipsToBounds = true
        winView.layer.cornerRadius = 5
        winView.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMaxYCorner, .layerMinXMinYCorner)
        
        loseView.clipsToBounds = true
        loseView.layer.cornerRadius = 5
        loseView.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMaxXMaxYCorner, .layerMaxXMinYCorner)
        
        profileImage.layer.cornerRadius = 5
        profileImage.layer.borderWidth = 1
        profileImage.clipsToBounds = true
        
        let ratio = 100*Double(win)/Double(win+lose)
        ratioConstraint = ratioConstraint.setMultiplier(multiplier: ratio/50)
        
        winLabel.text = "\(win)W"
        loseLabel.text = "\(lose)L"
        ratioLabel.text = "\(Int(ratio))%"
        
        mostOneImage.clipsToBounds = true
        mostOneImage.layer.cornerRadius = mostOneImage.frame.height/2
        
        mostSecondImage.clipsToBounds = true
        mostSecondImage.layer.cornerRadius = mostSecondImage.frame.height/2
        
        mostThirdImage.clipsToBounds = true
        mostThirdImage.layer.cornerRadius = mostThirdImage.frame.height/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
            item: firstItem,
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
