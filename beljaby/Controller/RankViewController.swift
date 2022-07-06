//
//  RankViewController.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/07/05.
//

import UIKit

class RankViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nibName = UINib(nibName: "UserRankCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "UserRankCell")
    }

}
//MARK: - Table View Datasource
extension RankViewController{
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserRankCell", for: indexPath) as? UserRankCell else{
            return UITableViewCell()
        }
        
        let profileImageURL = URL(string: "https://ddragon.leagueoflegends.com/cdn/12.12.1/img/profileicon/4902.png")
        let tierImageURL = URL(string: "https://opgg-static.akamaized.net/images/medals_new/gold.png?image=q_auto,f_webp,w_144&v=1657013167257")
        let m1 = URL(string: "https://ddragon.leagueoflegends.com/cdn/12.12.1/img/champion/Qiyana.png")
        
        cell.profileImage.kf.setImage(with: profileImageURL)
        cell.tierImage.kf.setImage(with: tierImageURL)
        cell.name.text = "Bloris"
        cell.elo.text = "\(1480)LP"
        
        cell.mostOneImage.kf.setImage(with: m1)
        cell.mostSecondImage.kf.setImage(with: m1)
        cell.mostThirdImage.kf.setImage(with: m1)
        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
