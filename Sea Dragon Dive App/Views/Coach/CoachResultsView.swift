//
//  CoachResultsView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 8/23/23.
//

import SwiftUI


struct CoachResultsView: View {
    @State var entry: coachEntry //coaches selected entry
    
    var body: some View {
        VStack {
            HStack {
                Text("\(entry.team)")
                    .font(.title.bold())
            }
            //list of each diver in the entry
            List {
                ForEach(entry.diverEntries, id: \.hashValue) { diver in
                    //goes to a qr code view for the selected divers results
                    NavigationLink(destination: CoachToDiverQRView(url: makeQRCode(diver: diver))) {
                        HStack {
                            Text(diver.name)
                            Spacer()
                            Text("\(String(format: "%.2f", diver.totalScore ?? 0))")
                        }
                    }
                }
            }
        }
    }
    //converts entered string to json and compresses it then returns it in string form
    func makeQRCode(diver: diverEntry) -> String {
//        var diverResults = resultsList(diveResults: [], placement: diver.placement ?? 0)
//        var tempScore = [0.0, 0.0, 0.0]
//        tempScore = []
//        for dive in 0..<diver.scoringDives!.count {
//            for score in diver.scoringDives![dive].scores {
//                tempScore.append(Double(score)!)
//            }
//            diverResults.diveResults.append(diveResults(code: diver.scoringDives![dive].diveId!, score: tempScore))
//        }
        
        let encoder = JSONEncoder()
        let data = try! encoder.encode(diver)
        
        // json compression
        let optimizedData : Data = try! data.gzipped(level: .bestCompression)
        return optimizedData.base64EncodedString()
    }
}

struct CoachResultsView_Previews: PreviewProvider {
    static var previews: some View {
        CoachResultsView(entry: coachEntry(diverEntries: [diverEntry(dives: [], level: 0, name: "diver", totalScore: 10)], team: "Team", version: 0))
    }
}
