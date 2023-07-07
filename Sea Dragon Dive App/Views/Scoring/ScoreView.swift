//
//  ScoreView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/19/23.
//

import SwiftUI

enum DragState {
    case unknown
    case good
}

struct ScoreView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @State var score: Double
    @State var offset = CGSize.zero
    
    var index: Int
    
    @State var dragState = DragState.unknown
    
    var onChanged: ((CGPoint, Double) -> DragState)?
    var onEnded: ((CGPoint, Int, Double) -> Void)?
    
    var body: some View {
        Text(String(format: setFormat(score: Float(score)), score))
                    .font(.title)
                    .frame(width: verticalSizeClass == .regular ? UIScreen.main.bounds.size.width * 0.13 : UIScreen.main.bounds.size.width * 0.06, height: verticalSizeClass == .regular ? UIScreen.main.bounds.size.height * 0.05 : UIScreen.main.bounds.size.width * 0.033)
                    .overlay(
                        Rectangle()
                            .stroke(colorScheme == .dark ? .white : .black, lineWidth: 2)
                    )
                    .shadow(color: dragState == .good ? .red : .clear, radius: 10)
                    .offset(x: offset.width, y: offset.height)
                    .gesture(
                        DragGesture(coordinateSpace: .global)
                            .onChanged( {
                                self.offset = CGSize(width: $0.translation.width, height: $0.translation.height)
                                self.dragState = self.onChanged?($0.location, self.score) ?? .unknown
                            })
                            .onEnded( {
                                if self.dragState == .good {
                                    self.onEnded?($0.location, self.index, self.score)
                                }
                                offset = .zero
                            })
                    )
                    .padding(.horizontal)
    }
    
    func setFormat(score: Float) -> String {
        var tempScore = score
        
        while tempScore >= 0 {
            if tempScore == 0 {
                return "%.f"
            }
            else if tempScore == 0.5 {
                return "%.1f"
            }
            else {
                tempScore = tempScore - 1
            }
        }
            return ""
    }
}

struct ScoreView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreView(score: 9.5, index: 0)
    }
}
