//
//  ViewUtils.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/08/12.
//

import Foundation
import SwiftUI

/// GeometryReader를 통해 View Size정보를 전달하기 위한 PreferenceKey
private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}


extension View {
    ///SwiftUI에서 View Size 정보를 가져오기 위한 함수
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}
