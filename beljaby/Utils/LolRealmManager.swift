//
//  Utils.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/08/01.
//

import Foundation
import RealmSwift
import Alamofire
import Combine

final class LolRealmManager{
    static let shared = LolRealmManager()
    
    var realmData: Results<LolDataCache>
    var champData = [Int: Champion]()
    var ver = ""
    
    private let realm = try! Realm()
    
    private var subscriptions = Set<AnyCancellable>()
    private let version = CurrentValueSubject<Version,Never>(Version(v: ""))
    private let championList = PassthroughSubject<LolDataCache,Never>()
    
    private init(){
        self.realmData = realm.objects(LolDataCache.self)
        self.bind()
        self.initData()
    }
    
    func initData(){
        self.getVersion()
    }
    
    private func bind(){
        self.championList
            .receive(on: RunLoop.main)
            .sink {[unowned self] data in
                data.champions.forEach {
                    self.champData[Int($0.key) ?? 0] = Champion(id: $0.id, key: $0.key, name: $0.name)
                }
            }.store(in: &subscriptions)
        
        self.version
            .receive(on: RunLoop.main)
            .sink {[unowned self] version in
                if !version.v.isEmpty{
                    self.getChamption(version)
                    self.ver = version.v
                }
            }.store(in: &subscriptions)
    }
    
    private func getVersion(){
        let url = "https://ddragon.leagueoflegends.com/realms/kr.json"
        AF.request(url)
            .publishDecodable(type: Version.self)
            .value()
            .eraseToAnyPublisher()
            .receive(on: RunLoop.main)
            .sink {[unowned self] completion in
                switch completion{
                case .failure(let error):
                    self.version.send(Version(v: ""))
                    print("error: \(error)")
                case .finished: break
                }
            } receiveValue: { version in
                self.version.send(version)
            }.store(in: &subscriptions)
    }
    
    private func getChamption(_ version: Version){
        if realmData.count == 0 || realmData[0].version != version.v{
            let url = "https://ddragon.leagueoflegends.com/cdn/\(version.v)/data/ko_KR/champion.json"
            
            AF.request(url)
                .publishDecodable(type: ChampionList.self)
                .value()
                .replaceError(with: ChampionList(data: [:]))
                .receive(on: RunLoop.main)
                .sink(receiveValue: {[unowned self] result in
                    let newData = LolDataCache(version: version.v)
                    result
                        .data
                        .forEach { (_, champion: Champion) in
                            newData.champions.append(ChampionCache(champ: champion))
                        }
                    self.save(newData: newData)
                })
                .store(in: &subscriptions)
            
        }else{
            self.championList.send(self.realmData[0])
        }
    }
    
    private func save(newData: LolDataCache){
        do{
            try realm.write({[unowned self] in
                realm.deleteAll()
                realm.add(newData)
                self.championList.send(newData)
            })
        }catch{
            print("Error saving cache, \(error)")
        }
    }
}
