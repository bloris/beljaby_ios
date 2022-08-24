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

/// Realm Data 사용을 위한 Class
/// - shared: Realm Data를 사용하기 위한 싱글톤 인스턴스
final class LolRealmManager {
    static let shared = LolRealmManager()
    
    var realmData: Results<LolDataCache>
    var champData = [Int: Champion]()
    var ver = ""
    
    private let realm = try! Realm()
    
    private var subscriptions = Set<AnyCancellable>()
    let gameDataLoad = PassthroughSubject<Void, Never>() // Fetching any data finish -> Request UI reload
    private let version = PassthroughSubject<Version,Never>() // Fetching version finish -> Request champion info
    private let championList = PassthroughSubject<LolDataCache,Never>() // Fetching champion finish -> Preprocessing data
    
    private init() {
        self.realmData = realm.objects(LolDataCache.self)
        self.bind()
        self.initData()
    }
    
    func initData() {
        self.getVersion()
    }
    
    private func bind() {
        // Champion List 정보를 받으면 [key: Int, champion: Champion] 형태로 가공하여 저장
        self.championList
            .receive(on: RunLoop.main)
            .sink { [unowned self] data in
                data.champions.forEach {
                    self.champData[Int($0.key) ?? 0] = Champion(id: $0.id, key: $0.key, name: $0.name)
                    self.gameDataLoad.send()
                }
            }.store(in: &subscriptions)
        
        // Version 정보를 받으면 String 타입으로 저장
        self.version
            .receive(on: RunLoop.main)
            .filter { !$0.v.isEmpty } // filtering fetch fail
            .sink { [unowned self] version in
                self.ver = version.v
                self.getChamption(version)
                self.gameDataLoad.send()
            }.store(in: &subscriptions)
    }
    
    /// Riot으로 부터 현재 게임 Version 정보 fetch
    private func getVersion() {
        let url = "https://ddragon.leagueoflegends.com/realms/kr.json"
        AF.request(url)
            .publishDecodable(type: Version.self)
            .value()
            .eraseToAnyPublisher()
            .receive(on: RunLoop.main)
            .sink { [unowned self] completion in
                switch completion {
                case .failure(let error):
                    self.version.send(Version(v: ""))
                    print("error: \(error)")
                case .finished: break
                }
            } receiveValue: { version in
                self.version.send(version)
            }.store(in: &subscriptions)
    }
    
    /// Riot으로 부터 현재 Version 정보에 맞는 Champion List fetch
    private func getChamption(_ version: Version) {
        // 앱을 처음 실행하여 Local 정보가 없거나 Local Data Version과 최신 Version이 다른 경우 fetch
        if realmData.count == 0 || realmData[0].version != version.v {
            let url = "https://ddragon.leagueoflegends.com/cdn/\(version.v)/data/ko_KR/champion.json"
            
            AF.request(url)
                .publishDecodable(type: ChampionList.self)
                .value()
                .replaceError(with: ChampionList(data: [:]))
                .receive(on: RunLoop.main)
                .sink(receiveValue: { [unowned self] result in
                    let newData = LolDataCache(version: version.v)
                    result.data.forEach { (_, champion: Champion) in // Append Champion Data to realm instance
                        newData.champions.append(ChampionCache(champ: champion))
                    }
                    self.save(newData: newData)
                })
                .store(in: &subscriptions)
            
        } else { // Version 업데이트가 없는 경우 Local Data 활용
            self.championList.send(self.realmData[0])
        }
    }
    
    /// 새로운 Data를 fetch한 경우 (첫 실행, Version Update) Local에 저장
    private func save(newData: LolDataCache) {
        do {
            try realm.write( { [unowned self] in
                realm.deleteAll() // 기존 Data delete
                realm.add(newData) // New Data add
                self.championList.send(newData) // Send Data
            })
        } catch {
            print("Error saving cache, \(error)")
        }
    }
}
