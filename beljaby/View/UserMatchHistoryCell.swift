//
//  UserMatchHistoryCell.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/07/18.
//

import UIKit

class UserMatchHistoryCell: UICollectionViewCell {
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureView()
        // Initialization code
    }
    func setCornerRadius<V:UIView>(_ view: V,_ radius: CGFloat){
        view.clipsToBounds = true
        view.layer.cornerRadius = radius
        
    }
    func configureView(){
        [item0,item1,item2,item3,item4,item5,item6].forEach{
            setCornerRadius($0, 5)
        }
        
        setCornerRadius(champLevelView, champLevelView.frame.height/2)
        setCornerRadius(winView, winView.frame.height/2)
        
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
        
        
    }
    
    
}
