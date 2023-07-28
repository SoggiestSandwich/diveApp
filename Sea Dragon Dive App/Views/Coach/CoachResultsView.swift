//
//  CoachResultsView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 8/23/23.
//

import SwiftUI


struct CoachResultsView: View {
    @State var coachList: coachEntry
    
    var body: some View {
        VStack {
            HStack {
                Text("\(coachList.team)")
                    .font(.title.bold())
            }
            List {
                ForEach(coachList.diverEntries, id: \.hashValue) { diver in
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
    
    func makeQRCode(diver: diverEntry) -> String {
        var qrCode: String = "{\"diveResults\":["
        
        for dive in 0..<diver.dives.count {
            qrCode += "{\"score\":["
            for score in 0..<diver.fullDives![dive].score.count {
                qrCode += "\(diver.fullDives![dive].score[score].score)"
                if score != diver.fullDives![dive].score.count - 1 {
                    qrCode += ","
                }
            }
            qrCode += "],\"code\":\"\(diver.dives[dive])\"}"
            if dive != diver.dives.count - 1 {
                qrCode += ","
            }
            
        }
        qrCode += "],\"placement\":\(diver.placement ?? 0)}"
        
        return qrCode
    }
}

struct CoachResultsView_Previews: PreviewProvider {
    static var previews: some View {
        CoachResultsView(coachList: coachEntry(diverEntries: [diverEntry(dives: [], level: 0, name: "diver", totalScore: 10)], eventDate: "Date", team: "Team", version: 0))
    }
}
