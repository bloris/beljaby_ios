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
    @State var availableWidth = UIScreen.main.bounds.width
    
    // MARK: - BODY
    var body: some View {
        VStack(spacing: 30) {
            FlexibleView(
                availableWidth: availableWidth,
                data: viewModel.gridValue,
                spacing: 15,
                alignment: .center
            ) { item in
                Button {
                    viewModel.Select(name: item.name)
                } label: {
                    Text(verbatim: item.name)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(item.isSelected ? Color.blue : Color.gray.opacity(0.8))
                        .cornerRadius(8)
                }
            }
            
            Button {
                viewModel.buttonTapped = true
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text(viewModel.buttonLabel)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                    .background(viewModel.makeButtonDisable ? Color.red : Color.blue)
                    .clipShape(Capsule(style: .circular))
            }
            .disabled(viewModel.makeButtonDisable)
            
        }
        .frame(maxWidth: .infinity)
        .readSize { size in
            availableWidth = size.width - 10
        }
        .onDisappear {
            if viewModel.buttonTapped {
                viewModel.Balance()
            }
        }
    }
}