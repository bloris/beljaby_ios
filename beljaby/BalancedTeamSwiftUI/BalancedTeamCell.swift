//
//  BalancedTeamCell.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/08/23.
//

import SwiftUI
import Kingfisher

struct BalancedTeamCell: View {
    
    @StateObject var viewModel: BalancedTeamCellViewModel
    
    var body: some View {
        HStack {
            KFImage(viewModel.profileIconURL)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .cornerRadius(30)
            
            Text(viewModel.name)
            
            Spacer()
            
            Text(viewModel.elo)
            
            Image(viewModel.tier)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .cornerRadius(30)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

struct BalancedTeamCell_Previews: PreviewProvider {
    static var previews: some View {
        BalancedTeamCell(viewModel: BalancedTeamCellViewModel(
            user: beljaby.User(puuid: "R4_rzHg8JmfW8kYA-rn8c1WwIOjvOW29he_mg90PXc5X37X2UVQIHAQFiE_wcY1XFET_chfUjHbQzA", name: "HTMLProgrammer", profileIconId: 4657, elo: 987, tier: "Bronze", win: 28, lose: 50)
        ))
    }
}
