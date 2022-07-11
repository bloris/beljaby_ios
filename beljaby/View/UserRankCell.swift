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
        self.configureView()
    }
    func setCornerRadius<V:UIView>(_ view: V,_ radius: CGFloat){
        view.clipsToBounds = true
        view.layer.cornerRadius = radius
        view.layer.borderWidth = 1
    }
    func configureView(){
        [entireView,profileImage].forEach{
            setCornerRadius($0, 5)
        }
        
        [mostOneImage, mostSecondImage, mostThirdImage].forEach {
            setCornerRadius($0, $0.frame.height/2)
        }
        
        entireView.layer.borderWidth = 0
        
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
