//
//  MatchDetailCell.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/08/10.
//

import SwiftUI

struct MatchDetailCell: View {
    
    var body: some View {
        HStack {
            ZStack(alignment: .bottom) {
                Image(systemName: "sun.max")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                
                Text("16")
                    .font(.system(size: 12, weight: .bold))
                    .frame(width: 20, height: 20)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            VStack(alignment: .leading){
                Text("Bloris")
                HStack{
                    Image("8008")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .background(Color.black)
                        .cornerRadius(15)
                    
                    Image("8100")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                }
            }
            Spacer()
            VStack(alignment: .trailing) {
                HStack(spacing: 25){
                    Text("123")
                    Text("123")
                    Text("123")
                }
                HStack{
                    ForEach(0..<7){ idx in
                        Image(systemName: "sun.min")
                            .resizable()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .cornerRadius(5)
                            .padding(.leading,-5)
                    }
                }
            }
        }
        .padding()
    }
}

struct MatchDetailCell_Previews: PreviewProvider {
    static var previews: some View {
        MatchDetailCell()
            .previewLayout(.fixed(width: 390, height: 120))
    }
}
