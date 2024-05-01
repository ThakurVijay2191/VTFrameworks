//
//  Carousel.swift
//  VTFrameworks
//
//  Created by Nap Works on 01/05/24.
//

import SwiftUI

import SwiftUI

struct VTCarousel<Content: View, T: Identifiable>: View {
    
    @StateObject private  var UIState: UIStateModel = .init()
    @Binding var items: [T]
    var spacing: CGFloat
    var widthOfHiddenCards: CGFloat/// UIScreen.main.bounds.width - 10
    var cardHeight: CGFloat
    var hiddenCardScale: CGFloat
    var content: (Binding<T>)-> Content

    init(spacing: CGFloat = 16, widthOfHiddenCards: CGFloat = 20, cardHeight: CGFloat, hiddenCardScale: CGFloat = 40, items: Binding<[T]>, @ViewBuilder content: @escaping (Binding<T>)->Content) {
        self._items = items
        self.content = content
        self.spacing = spacing
        self.widthOfHiddenCards = widthOfHiddenCards
        self.cardHeight = cardHeight
        self.hiddenCardScale = hiddenCardScale
    }
    var body: some View {
   
        return Canvas {
            Carousel(
                numberOfItems: CGFloat(items.count),
                spacing: spacing,
                widthOfHiddenCards: widthOfHiddenCards
            ) {
                ForEach($items, id: \.self.id) { $item in
                    let index = items.firstIndex(where: { $0.id == item.id})
                    GeometryReader { reader in
                        content($item)
                            .frame(width: reader.size.width, height: reader.size.height)
                    }
                    .frame(width: UIScreen.main.bounds.width - (widthOfHiddenCards*2) - (spacing*2), height: index == UIState.activeCard ? cardHeight : cardHeight - hiddenCardScale, alignment: .center)
                    .transition(AnyTransition.slide)
                    .animation(.spring(), value: UIState.activeCard)
                }
            }
            .environmentObject(UIState)
        }
        .environmentObject(UIState)
    }
}

struct Card: Decodable, Hashable, Identifiable {
    var id: Int
    var name: String = ""
}

@MainActor
public class UIStateModel: ObservableObject {
    @Published var activeCard: Int = 0
    @Published var screenDrag: Float = 0.0
}

struct Carousel<Items : View> : View {
    let items: Items
    let numberOfItems: CGFloat //= 8
    let spacing: CGFloat //= 16
    let widthOfHiddenCards: CGFloat //= 32
    let totalSpacing: CGFloat
    let cardWidth: CGFloat
    
    @GestureState var isDetectingLongPress = false
    
    @EnvironmentObject var UIState: UIStateModel
        
    @inlinable public init(
        numberOfItems: CGFloat,
        spacing: CGFloat,
        widthOfHiddenCards: CGFloat,
        @ViewBuilder _ items: () -> Items) {
        
        self.items = items()
        self.numberOfItems = numberOfItems
        self.spacing = spacing
        self.widthOfHiddenCards = widthOfHiddenCards
        self.totalSpacing = (numberOfItems - 1) * spacing
        self.cardWidth = UIScreen.main.bounds.width - (widthOfHiddenCards*2) - (spacing*2) //279
        
    }
    
    var body: some View {
        let totalCanvasWidth: CGFloat = (cardWidth * numberOfItems) + totalSpacing
        let xOffsetToShift = (totalCanvasWidth - UIScreen.main.bounds.width) / 2
        let leftPadding = widthOfHiddenCards + spacing
        let totalMovement = cardWidth + spacing
                
        let activeOffset = xOffsetToShift + (leftPadding) - (totalMovement * CGFloat(UIState.activeCard))
        let nextOffset = xOffsetToShift + (leftPadding) - (totalMovement * CGFloat(UIState.activeCard) + 1)

        var calcOffset = Float(activeOffset)
        
        if (calcOffset != Float(nextOffset)) {
            calcOffset = Float(activeOffset) + UIState.screenDrag
        }
        
        return HStack(alignment: .center, spacing: spacing) {
            items
        }
        .offset(x: CGFloat(calcOffset), y: 0)
        .gesture(DragGesture().updating($isDetectingLongPress) { currentState, gestureState, transaction in
            DispatchQueue.main.async {
                self.UIState.screenDrag = Float(currentState.translation.width)
            }
        }.onEnded { value in
            DispatchQueue.main.async {
                
                self.UIState.screenDrag = 0
                
                if (value.translation.width < -50) {
                    if self.UIState.activeCard < Int(self.numberOfItems - 1){
                        self.UIState.activeCard = self.UIState.activeCard + 1
                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                        impactMed.impactOccurred()
                    }
                }
                
                if (value.translation.width > 50) {
                    if self.UIState.activeCard > 0 {
                        self.UIState.activeCard = self.UIState.activeCard - 1
                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                        impactMed.impactOccurred()
                    }
                  
                }
            }
        })
    }
}

struct Canvas<Content : View> : View {
    let content: Content
    @EnvironmentObject var UIState: UIStateModel
    
    @inlinable init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            .background(Color.white.edgesIgnoringSafeArea(.all))
    }
}
