//
//  MatchDetailView.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/08/10.
//

import SwiftUI

struct MatchDetailView: View {
    
    var matchId: String
    
    var body: some View {
        VStack{
            Text(matchId)
        }
    }
}

struct MatchDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MatchDetailView(matchId: "1234")
    }
}
