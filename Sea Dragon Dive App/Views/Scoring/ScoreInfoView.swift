//
//  ScoreInfoView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/26/23.
//

import SwiftUI

struct ScoreInfoView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @State var diverList: [diverEntry]
    
    @State private var currentDiver: Int = 0
    @State private var currentDive: Int = 0
    @State private var halfAdded: Bool = true
    @State private var currentIndex: Int = 0
    
    @State private var scoresArray: [scores] = []
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    //toggles to previous diver or sends notification that this is the first dive?
                    if currentDiver - 1 > -1 {
                        while !scoresArray.isEmpty {
                            scoresArray.remove(at: 0)
                        }
                        currentDiver = currentDiver - 1
                        currentIndex = 0
                    }
                    else if currentDiver == 0 && currentDive == 0 {
                        
                    }
                    else {
                        while !scoresArray.isEmpty {
                            scoresArray.remove(at: 0)
                        }
                        currentDiver = diverList.count - 1
                        currentDive = currentDive - 1
                        currentIndex = 0
                    }
                    halfAdded = true
                } label: {
                    Text("Previous Diver")
                        .padding(.bottom)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .bold()
                        .frame(width: UIScreen.main.bounds.size.width * 0.45, height: verticalSizeClass == .compact ? 40 : UIScreen.main.bounds.size.height * 0.06)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 2)
                        )
                        .overlay(
                            Text(previousDiver())
                                .padding(.top)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .font(.subheadline)
                        )
                        .padding(.leading)
                }
                Spacer()
                Button {
                    //toggles to next diver or sends notification that this is the last dive?
                    if scoresArray.count > 2 && scoresArray.count != 4 && scoresArray.count != 6 {
                        if currentDiver + 1 < diverList.count {
                            while !scoresArray.isEmpty {
                                scoresArray.remove(at: 0)
                            }
                            currentDiver = currentDiver + 1
                            currentIndex = 0
                        }
                        else if currentDiver + 1 == diverList.count && currentDive + 1 == diverList.count {
                            
                        }
                        else {
                            while !scoresArray.isEmpty {
                                scoresArray.remove(at: 0)
                            }
                            currentDiver = 0
                            currentDive = currentDive + 1
                            currentIndex = 0
                        }
                    }
                    else {
                        
                    }
                    halfAdded = true
                } label: {
                    Text(currentDiver == diverList.count - 1 && currentDive == diverList[currentDiver].dives.count - 1 ? "Finish Event" : "Next Diver")
                        .padding(.bottom)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .bold()
                        .frame(width: UIScreen.main.bounds.size.width * 0.45, height: verticalSizeClass == .compact ? 40 : UIScreen.main.bounds.size.height * 0.06)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 2)
                        )
                        .overlay(
                            Text(nextDiver())
                                .padding(.top)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .font(.subheadline)
                        )
                        .padding(.trailing)
                }
            }
            .padding(verticalSizeClass == .regular ? .horizontal : .top)
            
            Spacer()
            Text(diverList[currentDiver].name)
                .font(.title2.bold())
            Text("\(diverList[currentDiver].team ?? "")\nDive \(currentDive + 1) - \(diverList[currentDiver].dives[currentDive])\nDegree of Difficulty: ")
                .frame(alignment: .center)
                .padding(.horizontal)
                .font(.system(size: verticalSizeClass == .regular ? 20 : 15))
            
            Spacer()
            
            ScoreSelectorView(scoresArray: $scoresArray, halfAdded: $halfAdded, currentIndex: $currentIndex, currentDiver: $currentDiver, diverList: $diverList, currentDive: $currentDive)
        }    }
    
    func nextDiver() -> String {
        if currentDiver < diverList.count - 1 {
            return diverList[currentDiver + 1].name
        }
        else if currentDiver == diverList.count - 1 && currentDive != diverList[currentDiver].dives.count - 1 {
            return diverList[0].name
        }
        else {
            return ""
        }
    }
    
    func previousDiver() -> String {
        if currentDiver > 0 {
            return diverList[currentDiver - 1].name
        }
        else if currentDiver == 0 && currentDive != 0 {
            return diverList[diverList.count - 1].name
        }
        else {
            return ""
        }
    }
}

struct ScoreInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreInfoView(diverList: [diverEntry(dives: ["Kakorward Kakwist"], level: 0, name: "Kakaw", team: "Kakawington High")])
    }
}
/*
struct diverEntry: Codable, Hashable {
    let dives: [String]
    let level: Int
    let name: String
    var team: String?
}
*/
