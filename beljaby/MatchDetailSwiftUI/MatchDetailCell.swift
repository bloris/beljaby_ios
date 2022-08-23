//
//  MatchDetailCell.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/08/10.
//

import SwiftUI
import Kingfisher
import CarPlay

struct MatchDetailCell: View {
    
    @StateObject var viewModel: MatchDetailCellViewModel
    
    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .center) {
                KFImage(viewModel.champImgURl)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .cornerRadius(30)
                    .overlay(
                        Capsule(style: .circular)
                            .stroke(Color.white, lineWidth: 2)
                    )
                
                Text(viewModel.champLevel)
                    .font(.system(size: 10, weight: .bold))
                    .frame(width: 16, height: 16)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .overlay(
                        Capsule(style: .circular)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.top, -16)
                
            }
            
            VStack(spacing: 5) {
                HStack(spacing: 20) {
                    DetailTextView(text: viewModel.name)
                    
                    Spacer()
                    
                    HStack(spacing: 3) {
                        DetailTextView(text: viewModel.kill)
                        SeperatorTextView()
                        DetailTextView(text: viewModel.death)
                        SeperatorTextView()
                        DetailTextView(text: viewModel.assist)
                    }
                    
                    DetailTextView(text: viewModel.cs)
                    
                    DetailTextView(text: viewModel.goldEarned)
                }
                
                HStack {
                    HStack(spacing: 5) {
                        Image(viewModel.mainPerk)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .cornerRadius(15)
                        
                        Image(viewModel.subPerk)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 13, height: 13)
                    }
                    
                    Spacer()
                    
                    HStack {
                        ForEach(viewModel.itemImgURL, id: \.self) { url in
                            KFImage(url)
                                .resizable()
                                .background(Color(UIColor(red: 0.26, green: 0.26, blue: 0.26, alpha: 1.00)))
                                .foregroundColor(.white)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 25)
                                .cornerRadius(5)
                                .padding(.leading,-5)
                        }
                    }
                }
            }
            
        }
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
        .background(viewModel.my ? LinearGradient(gradient: Gradient(colors: [.gray,.black]), startPoint: .leading, endPoint: .trailing) : LinearGradient(colors: [.black], startPoint: .leading, endPoint: .trailing))
    }
}

struct DetailTextView: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .bold))
            .foregroundColor(.white)
            .lineLimit(1)
    }
}

struct SeperatorTextView: View {
    var body: some View {
        Text("/")
            .font(.system(size: 13, weight: .regular))
            .foregroundColor(.gray)
    }
}

struct MatchDetailCell_Previews: PreviewProvider {
    static var previews: some View {
        MatchDetailCell(viewModel: MatchDetailCellViewModel(matchDetail: MatchDetail(name: "Bloris", userMatch: UserMatch(matchId: "24234", champ: 895, eloChange: -19, champLevel: 13, goldEarned: 10359, mainPerk: 8010, subPerk: 8400, kill: 4, death: 6, assist: 5, cs: 204, killP: 53, item: [1055,6673,3046,3006,3133,1018,3363], ward: 1, matchDate: Date(), win: false), my: false)))
            .previewLayout(.fixed(width: 390, height: 120))
        
    }
}
