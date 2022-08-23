//
//  MatchDetailView.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/08/10.
//

import SwiftUI
import Kingfisher

struct MatchDetailView: View {
    
    @StateObject var viewModel: MatchDetailViewModel
    
    let colorList = [
        UIColor(red: 0.04, green: 0.77, blue: 0.89, alpha: 1.00),
        UIColor(red: 0.82, green: 0.22, blue: 0.22, alpha: 1.00)
    ].map{Color($0)}
    
    let layout: [GridItem] = [
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            VStack {
                ZStack(alignment: .bottom) {
                    
                    KFImage(viewModel.champImgURl)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .overlay {
                            LinearGradient(gradient: Gradient(colors: [.clear,.black]), startPoint: .init(x: 0.5, y: 0.7), endPoint: .bottom)
                        }
                    
                    HStack {
                        Text(viewModel.dateLabel)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.gray)
                            .padding(.leading,20)
                        
                        Spacer()
                        
                        Text(viewModel.winLabel)
                            .foregroundColor(viewModel.win ? .black : .white)
                            .font(.system(size: 13, weight: .regular))
                            .padding(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15))
                            .background(viewModel.win ? colorList[0] : colorList[1])
                            .clipShape(Capsule(style: .circular))
                            .padding(.trailing,20)
                    }
                    .padding(.bottom,10)
                }
                
                LazyVGrid(columns: layout,spacing: 0) {
                    TeamView(team: viewModel.myTeam, text: "아군")
                    TeamView(team: viewModel.enemyTeam, text: "적")
                }
            }
        }
        .background(Color.black.ignoresSafeArea())
    }
}


struct HeaderView: View {
    let text: String
    var body: some View {
        HStack {
            Text(text)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.white)
                .padding(5)
                .padding(.leading,20)
            
            Spacer()
        }
        .frame(maxWidth:.infinity, alignment: .leading)
        .background(Color(UIColor(red: 0.16, green: 0.15, blue: 0.16, alpha: 1.00)))
    }
}

struct TeamView: View {
    let team: [MatchDetail]
    let text: String
    
    var body: some View {
        Section(header: HeaderView(text: text)) {
            ForEach(team) { matchDetail in
                VStack(spacing: 0) {
                    MatchDetailCell(viewModel: MatchDetailCellViewModel(matchDetail: matchDetail))
                    
                    if matchDetail != team.last {
                        RoundedRectangle(cornerRadius: 1)
                            .foregroundColor( Color( UITableView().separatorColor ?? .gray) )
                            .frame(height: 2)
                    }
                }
            }
        }
    }
}

struct MatchDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MatchDetailView(viewModel: MatchDetailViewModel(matchDetails: [
            MatchDetail(name: "Bloris1", userMatch: UserMatch(matchId: "24234", champ: 895, eloChange: -19, champLevel: 13, goldEarned: 10359, mainPerk: 8010, subPerk: 8400, kill: 4, death: 6, assist: 5, cs: 204, killP: 53, item: [1055,6673,3046,3006,3133,1018,3363], ward: 1, matchDate: Date(), win: false),my: true),
            MatchDetail(name: "Bloris2", userMatch: UserMatch(matchId: "24234", champ: 895, eloChange: -19, champLevel: 13, goldEarned: 10359, mainPerk: 8010, subPerk: 8400, kill: 4, death: 6, assist: 5, cs: 204, killP: 53, item: [1055,6673,3046,3006,3133,1018,3363], ward: 1, matchDate: Date(), win: false),my: false),
            MatchDetail(name: "Bloris3", userMatch: UserMatch(matchId: "24234", champ: 895, eloChange: -19, champLevel: 13, goldEarned: 10359, mainPerk: 8010, subPerk: 8400, kill: 4, death: 6, assist: 5, cs: 204, killP: 53, item: [1055,6673,3046,3006,3133,1018,3363], ward: 1, matchDate: Date(), win: false),my: false),
            MatchDetail(name: "Bloris4", userMatch: UserMatch(matchId: "24234", champ: 895, eloChange: -19, champLevel: 13, goldEarned: 10359, mainPerk: 8010, subPerk: 8400, kill: 4, death: 6, assist: 5, cs: 204, killP: 53, item: [1055,6673,3046,3006,3133,1018,3363], ward: 1, matchDate: Date(), win: false),my: false),
            MatchDetail(name: "Bloris5", userMatch: UserMatch(matchId: "24234", champ: 895, eloChange: -19, champLevel: 13, goldEarned: 10359, mainPerk: 8010, subPerk: 8400, kill: 4, death: 6, assist: 5, cs: 204, killP: 53, item: [1055,6673,3046,3006,3133,1018,3363], ward: 1, matchDate: Date(), win: false),my: false),
            MatchDetail(name: "Bloris6", userMatch: UserMatch(matchId: "24234", champ: 895, eloChange: -19, champLevel: 13, goldEarned: 10359, mainPerk: 8010, subPerk: 8400, kill: 4, death: 6, assist: 5, cs: 204, killP: 53, item: [1055,6673,3046,3006,3133,1018,3363], ward: 1, matchDate: Date(), win: false),my: false),
            MatchDetail(name: "Bloris7", userMatch: UserMatch(matchId: "24234", champ: 895, eloChange: -19, champLevel: 13, goldEarned: 10359, mainPerk: 8010, subPerk: 8400, kill: 4, death: 6, assist: 5, cs: 204, killP: 53, item: [1055,6673,3046,3006,3133,1018,3363], ward: 1, matchDate: Date(), win: false),my: false),
            MatchDetail(name: "Bloris8", userMatch: UserMatch(matchId: "24234", champ: 895, eloChange: -19, champLevel: 13, goldEarned: 10359, mainPerk: 8010, subPerk: 8400, kill: 4, death: 6, assist: 5, cs: 204, killP: 53, item: [1055,6673,3046,3006,3133,1018,3363], ward: 1, matchDate: Date(), win: false),my: false),
            MatchDetail(name: "Bloris9", userMatch: UserMatch(matchId: "24234", champ: 895, eloChange: -19, champLevel: 13, goldEarned: 10359, mainPerk: 8010, subPerk: 8400, kill: 4, death: 6, assist: 5, cs: 204, killP: 53, item: [1055,6673,3046,3006,3133,1018,3363], ward: 1, matchDate: Date(), win: false),my: false),
            MatchDetail(name: "Bloris10", userMatch: UserMatch(matchId: "24234", champ: 895, eloChange: -19, champLevel: 13, goldEarned: 10359, mainPerk: 8010, subPerk: 8400, kill: 4, death: 6, assist: 5, cs: 204, killP: 53, item: [1055,6673,3046,3006,3133,1018,3363], ward: 1, matchDate: Date(), win: false),my: false)
        ]))
    }
}
