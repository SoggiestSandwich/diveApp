//
//  AnnounceDiveView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/13/24.
//

import SwiftUI

struct AnnounceDiveView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var currentDiver: Int = 0
    @State var currentDive: Int = 0
    
    //@State var announceEvent
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button {
                    
                } label: {
                    Text("Withdraw")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .bold()
                        .padding(10)
                        .padding(.horizontal)
                        .overlay(
                            Rectangle()
                                .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 2)
                        )
                }
                .padding()
                Spacer()
                Text("Verbose Script")
                    .bold()
                    .padding()
            }
            Spacer()
            Text(currentDiver == 0 ? "Starting Round \(currentDive + 1) is" : "Next up is our \(currentDiver + 1)\(currentDiver == 1 ? "nd" : currentDiver == 2 ? "rd" : "th") diver")
                .font(.title)
                .padding()
            Text("name of diver")
                .font(.title)
                .bold()
                .padding(.horizontal)
            Spacer()
        }
    }
}

#Preview {
    AnnounceDiveView()
}
