//
//  ScoreSelectorView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 6/16/23.
//

import SwiftUI

struct ScoreSelectorView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @Binding var scoresArray: [scores]
    
    @Binding var halfAdded: Bool
    @State var buttonFrames = [CGRect](repeating: .zero, count: 1)
    
    @Binding var currentIndex: Int
    @Binding var currentDiver: Int
    @Binding var diverList: [Divers]
    @Binding var currentDive: Int
    
    @State var findTrash: Int = 0
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text("Judges' Scores:")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(-10)
                        .padding(.bottom)
                    //scores
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 30, maximum: 150)), count: verticalSizeClass == .regular ? 3 : 7)) {
                        ForEach(scoresArray) { score in
                            ScoreView(score: score.score, index: score.index, onChanged: self.scoreMoved, onEnded: self.scoreDropped)
                        }
                    }
                    Spacer()
                }
                VStack {
                    //expand overlay over text
                    Image(systemName: "trash")
                        .interpolation(.none).resizable().frame(width: verticalSizeClass == .regular ? UIScreen.main.bounds.size.height * 0.055 : 30, height: verticalSizeClass == .regular ? UIScreen.main.bounds.size.height * 0.06 : 35, alignment: .bottomTrailing)
                        .overlay(GeometryReader { geo in
                            Color.clear
                                .onChange(of: findTrash) { halfAdded in
                                    buttonFrames[0] = geo.frame(in: .global)
                                }
                        }
                        )
                    Text("Drag Scores\nto Delete")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
            }
            .padding(.trailing)
            Spacer()
            HStack {
                Text("Score: ")
                    .font(.title2.bold())
                Text(String(format: "%.2f", diverList[currentDiver].dives[currentDive].score))
                    .padding(5)
                    .frame(width: UIScreen.main.bounds.size.width * 0.2, height: 25, alignment: .trailing)
                    .overlay(
                        Rectangle()
                            .stroke(lineWidth: 2)
                    )
                
                Text("Total: ")
                    .font(.title2.bold())
                Text(String(format: "%.2f", diverList[currentDiver].totalScore))
                    .padding(5)
                    .frame(width: UIScreen.main.bounds.size.width * 0.2, height: 25, alignment: .trailing)
                    .overlay(
                        Rectangle()
                            .stroke(lineWidth: 2)
                    )
            }
            .padding()
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 30, maximum: 2000)), count: verticalSizeClass == .regular ? UIDevice.current.localizedModel == "iPad" ? 4 : 3 : 12)) {
                ForEach(1...12, id: \.self) { number in
                    if number < 10 {
                        Button {
                            if scoresArray.count < 7 {
                                currentIndex = currentIndex + 1
                                let tempScore = scores(score: Float(number), index: currentIndex)
                                scoresArray.append(tempScore)
                            }
                            halfAdded = false
                            SetRoundScore()
                        } label: {
                            Text("\(number)")
                                .frame(width: verticalSizeClass == .regular ? UIScreen.main.bounds.size.width * 0.18 : 30, height: verticalSizeClass == .regular ? UIScreen.main.bounds.size.height * 0.04 : 0)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .font(verticalSizeClass == .regular ? .title : .title2)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(colorScheme == .dark ? .white : .black, lineWidth: 2)
                                )
                        }
                    }
                    else if number == 10 {
                        Button {
                            if !halfAdded {
                                if scoresArray[scoresArray.count - 1].score < 10 {
                                    scoresArray[currentIndex - 1] = scores(score: scoresArray[currentIndex - 1].score + 0.5, index: currentIndex)
                                }
                            }
                            halfAdded = true
                            SetRoundScore()
                        } label: {
                            Text("+.5")
                                .frame(width: verticalSizeClass == .regular ? UIScreen.main.bounds.size.width * 0.18 : 30, height: verticalSizeClass == .regular ? UIScreen.main.bounds.size.height * 0.04 : 0)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .font(verticalSizeClass == .regular ? .title2 : .title3)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(colorScheme == .dark ? .white : .black, lineWidth: 2)
                                )
                        }
                    }
                    else if number == 11 {
                        Button {
                            if scoresArray.count < 7 {
                                currentIndex = currentIndex + 1
                                let tempScore = scores(score: 0, index: currentIndex)
                                scoresArray.append(tempScore)
                            }
                            halfAdded = false
                            SetRoundScore()
                        } label: {
                            Text("0")
                                .frame(width: verticalSizeClass == .regular ? UIScreen.main.bounds.size.width * 0.18 : 30, height: verticalSizeClass == .regular ? UIScreen.main.bounds.size.height * 0.04 : 0)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .font(verticalSizeClass == .regular ? .title : .title2)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(colorScheme == .dark ? .white : .black, lineWidth: 2)
                                )
                        }
                    }
                    else if number == 12 {
                        Button {
                            if scoresArray.count < 7 {
                                currentIndex = currentIndex + 1
                                let tempScore = scores(score: 10, index: currentIndex)
                                scoresArray.append(tempScore)
                            }
                            halfAdded = true
                            SetRoundScore()
                        } label: {
                            Text("10")
                                .frame(width: verticalSizeClass == .regular ? UIScreen.main.bounds.size.width * 0.18 : 30, height: verticalSizeClass == .regular ? UIScreen.main.bounds.size.height * 0.04 : 0)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .font(verticalSizeClass == .regular ? .title : .title2)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(colorScheme == .dark ? .white : .black, lineWidth: 2)
                                )
                        }
                    }
                }
            }
            .padding(.horizontal)
            .ignoresSafeArea()
        }
    }
    
    func SetRoundScore() {
        diverList[currentDiver].dives[currentDive].score = 0
        diverList[currentDiver].totalScore = 0
        var max: Float = -1
        var min: Float = 11
        var maxIndex: Int = 0
        var minIndex: Int = 8
        for scores in scoresArray {
            diverList[currentDiver].dives[currentDive].score = diverList[currentDiver].dives[currentDive].score + scores.score
        }
        if scoresArray.count >= 5 {
            for scores in scoresArray {
                if scores.score > max {
                    max = scores.score
                    maxIndex = scores.index
                }
            }
            diverList[currentDiver].dives[currentDive].score = diverList[currentDiver].dives[currentDive].score - max
            
            for scores in scoresArray {
                if scores.score < min {
                    min = scores.score
                    minIndex = scores.index
                }
            }
            diverList[currentDiver].dives[currentDive].score = diverList[currentDiver].dives[currentDive].score - min
            max = -1
            min = 11
        }
        if scoresArray.count == 7 {
            for scores in scoresArray {
                if scores.score >= max && scores.index != maxIndex {
                    max = scores.score
                }
            }
            diverList[currentDiver].dives[currentDive].score = diverList[currentDiver].dives[currentDive].score - max
            
            for scores in scoresArray {
                if scores.score <= min && scores.index != minIndex {
                    min = scores.score
                }
            }
            diverList[currentDiver].dives[currentDive].score = diverList[currentDiver].dives[currentDive].score - min
        }
        diverList[currentDiver].dives[currentDive].score = diverList[currentDiver].dives[currentDive].score * diverList[currentDiver].dives[currentDive].degreeOfDiff
        
        for dive in diverList[currentDiver].dives {
            diverList[currentDiver].totalScore = diverList[currentDiver].totalScore + dive.score
        }
    }
    
    func scoreMoved(location: CGPoint, score: Float) -> DragState {
        findTrash = findTrash + 1
        let match = buttonFrames.firstIndex(where: {
            $0.contains(location)
        })
        if match != nil {
            return .good
        }
        else {
            return .unknown
        }
    }
    
    func scoreDropped(location: CGPoint, scoreIndex: Int, score: Float) {
        let match = buttonFrames.firstIndex(where: {
            $0.contains(location)
        })
        if match != nil {
            currentIndex = currentIndex - 1
            
            scoresArray.remove(at: scoreIndex - 1)
            SetRoundScore()
            
            var i = 0
            while i < scoresArray.count {
                scoresArray[i].index = i + 1
                i = i + 1
            }
        }
    }
}

struct ScoreSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreSelectorView(scoresArray: .constant([]), halfAdded: .constant(false), currentIndex: .constant(0), currentDiver: .constant(0), diverList: .constant([
            Divers(name: "fob Inker", school: "Quarter Mule High School", dives: [dives(name: "dive1", degreeOfDiff: 1, score: 0), dives(name: "dive2", degreeOfDiff: 1.2, score: 0), dives(name: "dive3", degreeOfDiff: 1.4, score: 0)], totalScore: 0),
            Divers(name: "Bob Trinket", school: "Half Donkey High School", dives: [dives(name: "dive1", degreeOfDiff: 1, score: 0), dives(name: "dive2", degreeOfDiff: 1.2, score: 0), dives(name: "dive3", degreeOfDiff: 1.4, score: 0)], totalScore: 0),
            Divers(name: "Rob Winker", school: "Full Pony High School", dives: [dives(name: "dive1", degreeOfDiff: 1, score: 0), dives(name: "dive2", degreeOfDiff: 1.2, score: 0), dives(name: "dive3", degreeOfDiff: 1.4, score: 0)], totalScore: 0)
        ]), currentDive: .constant(0))
    }
}
