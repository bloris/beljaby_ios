//
//  UserRankCell.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/07/05.
//

import UIKit

class UserRankCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var tierImage: UIImageView!
    @IBOutlet weak var mostOneImage: UIImageView!
    @IBOutlet weak var mostSecondImage: UIImageView!
    @IBOutlet weak var mostThirdImage: UIImageView!
    
    
    @IBOutlet weak var winView: UIView!
    @IBOutlet weak var loseView: UIView!
    @IBOutlet weak var ratioLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        winView.clipsToBounds = true
        winView.layer.cornerRadius = 10
        winView.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMaxYCorner, .layerMinXMinYCorner)
        
        loseView.clipsToBounds = true
        loseView.layer.cornerRadius = 10
        loseView.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMaxXMaxYCorner, .layerMaxXMinYCorner)
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
