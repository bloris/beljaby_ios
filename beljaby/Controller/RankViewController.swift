//
//  RankViewController.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/07/05.
//

import UIKit
import Alamofire

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
    
    func getVersion(completionHandler: @escaping (Result<Version, Error>) -> Void){
        let url = "https://ddragon.leagueoflegends.com/realms/kr.json"
        
        AF.request(url, method: .get)
            .responseDecodable(of: Version.self) { response in
                switch response.result {
                case .success(let response):
                    completionHandler(.success(response))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserRankCell", for: indexPath) as? UserRankCell else{
            return UITableViewCell()
        }
        var version = "12.12.1"
        let profileImageId = "4902"
        
        getVersion { [weak self] result in
            guard let self = self else{return}
            switch result{
            case let .success(result):
                version = result.v
            case let .failure(error):
                print(error.localizedDescription)
                return
            }
        }
        
        let profileImageURL = URL(string: "https://ddragon.leagueoflegends.com/cdn/\(version)/img/profileicon/\(profileImageId).png")
        let m1 = URL(string: "https://ddragon.leagueoflegends.com/cdn/\(version)/img/champion/Qiyana.png")
        
        cell.profileImage.kf.setImage(with: profileImageURL)
        cell.mostOneImage.kf.setImage(with: m1)
        cell.mostSecondImage.kf.setImage(with: m1)
        cell.mostThirdImage.kf.setImage(with: m1)
        
        let tier = "Master"
        
        
        
        cell.tierImage.image = UIImage(named: "Emblem_\(tier)")
        cell.name.text = "Bloris"
        cell.elo.text = "\(1480)LP"
        cell.tierLabel.text = tier
        
        
        let win = 500
        let lose = 500
        let ratio = 100*Double(win)/Double(win+lose)
        cell.ratioConstraint = cell.ratioConstraint.setMultiplier(multiplier: ratio/50)
        
        cell.winLabel.text = "\(win)W"
        cell.loseLabel.text = "\(lose)L"
        cell.ratioLabel.text = "\(Int(ratio))%"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
