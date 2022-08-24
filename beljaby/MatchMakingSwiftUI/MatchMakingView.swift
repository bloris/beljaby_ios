//
//  MatchMaking.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/08/12.
//

import SwiftUI

struct MatchMakingView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var viewModel: MatchMakingViewModel
    // 아이폰의 경우 UIScreen의 bound.width가 modal.width의 가용 범위
    // ipad, mac의 경우 UIScreen의 bound와 modal view의 bound가 달라져 width를 측정한 뒤 view update 필요
    @State var availableWidth = UIScreen.main.bounds.width
    
    // MARK: - BODY
    var body: some View {
        VStack(spacing: 30) {
            FlexibleView(availableWidth: availableWidth, data: viewModel.gridValue, spacing: 15, alignment: .center) { item in
                // User select Button
                Button {
                    viewModel.Select(name: item.name)
                } label: {
                    // User가 select 되었는지 color로 정보 제공
                    Text(verbatim: item.name)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(item.isSelected ? Color.blue : Color.gray.opacity(0.8))
                        .cornerRadius(8)
                }
            }
            
            // Matchmaking Button
            Button {
                viewModel.buttonTapped = true
                presentationMode.wrappedValue.dismiss()
            } label: {
                // 몇명의 user를 더 선택해야 하는지, 현재 tap 가능한지 text 및 color로 정보 제공
                Text(viewModel.buttonLabel)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                    .background(viewModel.makeButtonDisable ? Color.red : Color.blue)
                    .clipShape(Capsule(style: .circular))
            }
            .disabled(viewModel.makeButtonDisable) // 10명의 user가 선택 되었을 때만 클릭 가능
            
        }
        .frame(maxWidth: .infinity)
        .readSize { size in
            availableWidth = size.width - 10 // leading, trailing padding 고려해 가용범위 계산
        }
        .onDisappear {
            // Match Making 버튼을 통해 view가 dismiss 되면 선택 된 user들의 elo를 통해 balancing 진행
            if viewModel.buttonTapped {
                viewModel.Balance()
            }
        }
    }
}
