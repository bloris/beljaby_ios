//
//  FlexibleView.swift
//  beljaby
//
//  Created by Hoyoun Lee on 2022/08/14.
//

import SwiftUI

struct FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let availableWidth: CGFloat // Availablewidth
    let data: Data // Data
    let spacing: CGFloat // Spacing between button
    let alignment: HorizontalAlignment // Alignment of Element
    let content: (Data.Element) -> Content // View Content
    @State var elementsSize: [Data.Element: CGSize] = [:]
    
    var body : some View {
        VStack(alignment: alignment, spacing: spacing) {
            ForEach(computeRows(), id: \.self) { rowElements in
                HStack(spacing: spacing) {
                    ForEach(rowElements, id: \.self) { element in
                        content(element)
                            .fixedSize() // Label 한줄 고정
                            .readSize { size in // Label 사이즈 측정 및 업데이트
                                elementsSize[element] = size
                            }
                    }
                }
            }
        }
    }
    
    /// 가용 너비와 element의 크기를 이용하여 Flexible한 row별 element 할당
    func computeRows() -> [[Data.Element]] {
        var rows: [[Data.Element]] = [[]] // Row 당 할당 되는 element 저장
        var currentRow = 0
        var remainingWidth = availableWidth // 남은 너비, 초기값 = 가용 너비
        
        for element in data {
            let elementSize = elementsSize[element, default: CGSize(width: availableWidth, height: 1)] // 현재 element의 너비
            
            // 가용 너비 내에 들어갈 수 있으면 현재 row에 data apend
            // 불가능하면 다음 row에 data append
            if remainingWidth - (elementSize.width + spacing) >= 0 {
                rows[currentRow].append(element)
            } else {
                currentRow = currentRow + 1
                rows.append([element])
                remainingWidth = availableWidth
            }
            
            // 추가한 element 너비 및 spacing만큼 가용 너비에서 감소
            remainingWidth = remainingWidth - (elementSize.width + spacing)
        }
        
        return rows
    }
}
