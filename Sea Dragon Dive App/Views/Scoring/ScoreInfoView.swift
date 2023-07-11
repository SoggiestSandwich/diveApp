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
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var diverList: [divers]
    
    @State var backAlert = false
    @State private var currentDiver: Int = 0
    @State private var currentDive: Int = 0
    @State private var halfAdded: Bool = true
    @State private var currentIndex: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button {
                        //toggles to previous diver or sends notification that this is the first dive?
                        if currentDiver - 1 > -1 {
                            currentDiver = currentDiver - 1
                            currentIndex = 0
                        }
                        else if currentDiver == 0 && currentDive == 0 {
                            
                        }
                        else {
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
                    if currentDiver + 1 == diverList.count && currentDive + 1 == diverList[currentDiver].dives.count {
                        //finish event
                        NavigationLink(destination: ResultsView(unsortedDiverList: diverList)) {
                                Text("Finish Event")
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
                    else {
                        Button {
                            //toggles to next diver or sends notification that this is the last dive?
                            if diverList[currentDiver].dives[currentDive].score.count > 2 && diverList[currentDiver].dives[currentDive].score.count != 4 && diverList[currentDiver].dives[currentDive].score.count != 6 {
                                if currentDiver + 1 < diverList.count {
                                    currentDiver = currentDiver + 1
                                    currentIndex = 0
                                }
                                else {
                                    currentDiver = 0
                                    currentDive = currentDive + 1
                                    currentIndex = 0
                                }
                            }
                            else {
                                
                            }
                            halfAdded = true
                        } label: {
                            Text(currentDiver == diverList.count - 1 && currentDive >= diverList[currentDiver].dives.count - 1 ? "Finish Event" : "Next Diver")
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
                }
                .padding(verticalSizeClass == .regular ? .horizontal : .top)
                
                Spacer()
                Text(diverList[currentDiver].diverEntries.name)
                    .font(.title2.bold())
                Text("\(diverList[currentDiver].diverEntries.team ?? "")\nDive \(currentDive + 1) - \(diverList[currentDiver].dives[currentDive].name) - \(diverList[currentDiver].dives[currentDive].position)\nDegree of Difficulty: \(String(diverList[currentDiver].dives[currentDive].degreeOfDiff))")
                    .frame(alignment: .center)
                    .padding(.horizontal)
                    .font(.system(size: verticalSizeClass == .regular ? 20 : 15))
                
                Spacer()
                
                ScoreSelectorView(halfAdded: $halfAdded, currentIndex: $currentIndex, currentDiver: $currentDiver, diverList: $diverList, currentDive: $currentDive)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    //triggers alert to confirm back
                    backAlert = true
                } label: {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("Back")
                    }
                }
                .alert("Are you sure you want to go back?", isPresented: $backAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Confirm") {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                } message: {
                    Text("If you go back you will lose all entered scores")
                }
            }
        }
    }
    
    func nextDiver() -> String {
        if currentDiver < diverList.count - 1 {
            return diverList[currentDiver + 1].diverEntries.name
        }
        else if currentDiver == diverList.count - 1 && currentDive != diverList[currentDiver].dives.count - 1 {
            return diverList[0].diverEntries.name
        }
        else {
            return ""
        }
    }
    
    func previousDiver() -> String {
        if currentDiver > 0 {
            return diverList[currentDiver - 1].diverEntries.name
        }
        else if currentDiver == 0 && currentDive != 0 {
            return diverList[diverList.count - 1].diverEntries.name
        }
        else {
            return ""
        }
    }
}

struct ScoreInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreInfoView(diverList: [divers(dives: [dives(name: "diveName", degreeOfDiff: 1, score: [], position: "tempPos", roundScore: 0)], diverEntries: diverEntry(dives: ["test1", "test2"], level: 0, name: "Kakaw", team: "teamName"))])
    }
}
