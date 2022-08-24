//
//  BalancedTeamView.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/08/14.
//

import SwiftUI
import Kingfisher

struct BalancedTeamView: View {
    
    @StateObject var viewModel: BalancedTeamViewModel
    
    let layout: [GridItem] = [
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            VStack {
                LazyVGrid(columns: layout,spacing: 0) {
                    TealBalanceView(text: "블루 팀", team: $viewModel.team1)
                    TealBalanceView(text: "레드 팀", team: $viewModel.team2)
                }
            }
        }
    }
}

struct TealBalanceView: View {
    let text: String
    @Binding var team: [User]
    
    var body: some View {
        Section(header: HeaderView(text: text)) {
            ForEach(team, id: \.puuid) { user in
                VStack(spacing: 0) {
                    BalancedTeamCell(viewModel: BalancedTeamCellViewModel(user: user))
                    
                    // Cell 사이에 Divider 추가
                    if user != team.last {
                        RoundedRectangle(cornerRadius: 1)
                            .foregroundColor( Color( UITableView().separatorColor ?? .gray) )
                            .frame(height: 2)
                    }
                }
            }
        }
    }
}

struct BalancedTeamView_Previews: PreviewProvider {
    static var previews: some View {
        BalancedTeamView(viewModel: BalancedTeamViewModel(
            team1: [
                beljaby.User(puuid: "R4_rzHg8JmfW8kYA-rn8c1WwIOjvOW29he_mg90PXc5X37X2UVQIHAQFiE_wcY1XFET_chfUjHbQzA", name: "HTMLProgrammer", profileIconId: 4657, elo: 987, tier: "Bronze", win: 28, lose: 50),
                beljaby.User(puuid: "FL7oEMl9A5Tp0gspZdb6sEqGaIZXcqQImTsoIr7LIpZ1vO59971WvXElCH0IHqFJAISrkpVgFC_bfA", name: "starply", profileIconId: 4022, elo: 1311, tier: "Gold", win: 3, lose: 3),
                beljaby.User(puuid: "fPY-lr2y5eMFPAQJPHxHuMe60WsuTTvPnPRYRuFg3VjAjLtGNdroDl0gUIFcXIJBMIkrW5dBaGx3Kg", name: "LuLu랄라", profileIconId: 4832, elo: 1395, tier: "Gold", win: 68, lose: 79),
                beljaby.User(puuid: "bfTl4B1LJEKvQT50NWZ-qCxsXt1wNL7R3i1dr5NzhtC0u7_QPNiQ2zxPuq9GeJkch1BLV_PeSUI-bQ", name: "Bloris", profileIconId: 4902, elo: 1319, tier: "Gold", win: 86, lose: 93),
                beljaby.User(puuid: "Jq0zpBUIyLO0VInbBlUl6y00YRGMohX4VOjoly3UC4_fu9T1wgcYP0UCQEASSk2T6tsiwR05ofstQw", name: "ByeongKeon Lee", profileIconId: 23, elo: 1376, tier: "Gold", win: 72, lose: 66)],
            team2: [
                beljaby.User(puuid: "f3EpU--xUBPU3c3t06HTksYHw8n4fgKkaP05gNLp6D_BbVtwIv3lL3emKIJEWYqThwi3T4X150oCIQ", name: "능금능금1", profileIconId: 4031, elo: 1163, tier: "Silver", win: 12, lose: 9),
                beljaby.User(puuid: "qZftWmglH26JGEyKFBYL90MEKnysMws-jLRad68als6v6dEl_N6NYqtMadQJsUvGZNqzvJpv-CBZaQ", name: "깨물기 없다 앙", profileIconId: 1114, elo: 1407, tier: "Gold", win: 11, lose: 6),
                beljaby.User(puuid: "_MHZXKBMErhmDMvdl7GQM8vJfC8qyHodjsXbZt1y7Wkf1BeYgsdVdOT93bnj-tFccJH4n72YkRgVlQ", name: "두정동 제어와드", profileIconId: 23, elo: 1303, tier: "Gold", win: 3, lose: 1),
                beljaby.User(puuid: "3sjHcOun6XK_mnlKPLf4lgHDansphYzpc9jdKMzOZE3nBS_HQLT6LYov8VwrAs0nXi9MCy1wWaq0Kw", name: "나의작은컵케이크", profileIconId: 3868, elo: 1292, tier: "Silver", win: 3, lose: 4),
                beljaby.User(puuid: "kyvfQs1BJ9O-V6AtTqOm_MLrmTA8P10HqlMjXIExN6mkHhaX79PHnsIxmYIAMIeGO_ioOwMYKARerg", name: "김이박최장", profileIconId: 1391, elo: 1223, tier: "Silver", win: 1, lose: 5)]
        ))
    }
}
