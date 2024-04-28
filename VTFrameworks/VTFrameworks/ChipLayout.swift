// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import UIKit

//MARK: Chip Layout API
@available(iOS 16.0, *)
public struct ChipLayout: Layout {
    var alignment: Alignment = .center
    var spacing: CGFloat = 10
    
    public init(alignment: Alignment, spacing: CGFloat) {
        self.alignment = alignment
        self.spacing = spacing
    }
    
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 0
        var height: CGFloat = 0
        
        let rows = generateRows(maxWidth, proposal, subviews)
        
        for (index, row) in rows.enumerated() {
            if index == (rows.count - 1) {
                height+=row.maxHeight(proposal)
            }else {
                height+=row.maxHeight(proposal) + spacing
            }
        }
        
        return .init(width: maxWidth, height: height)
    }
    
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var origin = bounds.origin
        let maxWidth = bounds.width
        let rows = generateRows(maxWidth, proposal, subviews)
        
        for row in rows {
            //Changing Origin X Based on Alignments
            let leading: CGFloat = bounds.maxX - maxWidth
            let trailing = bounds.maxX - (row.reduce(CGFloat.zero) { partialResult, view in
                let width = view.sizeThatFits(proposal).width
                
                if view == row.last {
                    //No Spacing
                    return partialResult + width
                }
                //with spacing

                return partialResult + width + spacing
            })
            
            let center = (trailing + leading) / 2
            
            //Reset origin X to Zero for each row
            origin.x = (alignment == .leading ? leading : alignment == .trailing ? trailing : center)
            for view in row {
                let viewSize = view.sizeThatFits(proposal)
                view.place(at: origin, proposal: proposal)
                //Updating Origin
                origin.x += (viewSize.width + spacing)
            }
            
            //Updating Origin Y
            origin.y += (row.maxHeight(proposal) + spacing)
        }
        
    }
    
    public func generateRows(_ maxWidth: CGFloat, _ proposal: ProposedViewSize, _ subviews: Subviews)-> [[LayoutSubviews.Element]]{
        var row: [LayoutSubviews.Element] = []
        var rows: [[LayoutSubviews.Element]] = []
        
        var origin = CGRect.zero.origin
        
        
        for view in subviews {
            let viewSize = view.sizeThatFits(proposal)
            
            //Pushing to New Row
            if (origin.x + viewSize.width + spacing) > maxWidth {
                rows.append(row)
                row.removeAll()
                //Reseting X Origin since it needs to start from left to right
                origin.x = 0
                row.append(view)
                //Updating Origin x
                origin.x+=(viewSize.width + spacing)
            }else {
                //Adding Item to same row
                row.append(view)
                //Updating Origin x
                origin.x+=(viewSize.width + spacing)
            }
        }
        
        //checking for any exhaust row
        if !row.isEmpty {
            rows.append(row)
            row.removeAll()
        }
        
        return rows
        
    }
    
 
}

@available(iOS 16.0, *)
public extension [LayoutSubviews.Element] {
    func maxHeight(_ proposal: ProposedViewSize)-> CGFloat {
        return self.compactMap { view in
            return view.sizeThatFits(proposal).height
        }.max() ?? 0
    }
}
