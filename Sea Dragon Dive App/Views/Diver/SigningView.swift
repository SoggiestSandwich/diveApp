//
//  SigningView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/27/23.
//

import SwiftUI

//simple struct for holding the data the signiture
struct Line {
    var points = [CGPoint]() //list of the poits in the line
    var color: Color = .black //color of the line
    var lineWidth: Double = 1.0 //width of the line
}

struct SigningView: View {
    @Environment(\.colorScheme) var colorScheme //detects if the device is in dark mode
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode> //used to make custom back button
    
    @State private var currentLine = Line() //the line that is currently being drawn
    @State private var lines: [Line] = [] //list of all drawn lines
    
    @Binding var entry: divers //the dive entry being confirmed
    
    var body: some View {
            NavigationStack {
                //dismisses this sheet
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Dismiss")
                }
                .padding()
                Text("Sign your dive entry")
                    .font(.title.bold())
                    .padding(.top)
                Text("I agree that I can perform these dives")
                
                ZStack {
                    //canvas that can be written on
                    Canvas { context, size in
                        for line in lines {
                            var path = Path()
                            path.addLines(line.points)
                            context.stroke(path, with: .color(colorScheme == .dark ? .white : .black), lineWidth: line.lineWidth)
                        }
                        
                    }.gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local) //as you drag points are added to the current line and when dragging ends the current line is added to the line list and the current line becomes a new line
                        .onChanged({ value in
                            let newPoint = value.location
                            currentLine.points.append(newPoint)
                            self.lines.append(currentLine)
                        })
                            .onEnded({ value in
                                self.lines.append(currentLine)
                                self.currentLine = Line(points: [])
                            })
                    )
                    VStack {
                        Text("Sign Here")
                            .font(.title)
                            .foregroundColor(self.lines.isEmpty ? .gray : .clear)
                        Text("X _________________")
                            .font(.largeTitle)
                    }
                }
                
                HStack {
                    //removes all lines from the area clearing any writing
                    Button {
                        self.lines.removeAll()
                    } label: {
                        HStack {
                            Image(systemName: "eraser.line.dashed.fill")
                            Text("Clear")
                        }
                        .padding()
                        .background(
                            Rectangle()
                                .stroke(lineWidth: 2)
                        )
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                    //shows a gray done box that does nothing if there is no writing
                    if self.lines.isEmpty {
                        Text("Done")
                            .padding()
                            .padding(.horizontal)
                            .padding(.horizontal)
                            .padding(.horizontal)
                            .padding(.horizontal)
                            .background(
                                Rectangle()
                                    .stroke(lineWidth: 2)
                            )
                            .foregroundColor(.gray)
                    }
                    //shows a navigation link to the qr code view
                    else {
                        NavigationLink(destination: DiverEntryQRCodeView(code: makeQRCode())) {
                                Text("Done")
                                    .padding()
                                    .padding(.horizontal)
                                    .padding(.horizontal)
                                    .padding(.horizontal)
                                    .padding(.horizontal)
                                    .background(
                                        Rectangle()
                                            .stroke(lineWidth: 2)
                                    )
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    }
                }
            }
    }
    //assembles a simplified diverEntry, encrypts it into JSON and then gzip compresses it and returns that as a string
    func makeQRCode() -> String {
        //diverEntry assembly
        var entries = diverEntry(dives: [], level: entry.diverEntries.level, name: entry.diverEntries.name)
        for dive in 0..<entry.dives.count {
            entries.dives!.append(entry.dives[dive].code ?? "")
        }
        entries.volentary = []
        for dive in 0..<entry.dives.count {
            entries.volentary!.append(entry.dives[dive].volentary ?? false)
            
        }
        
        //json encoding
        let encoder = JSONEncoder()
        let data = try! encoder.encode(entries)
        //print(String(data: data, encoding: .utf8) ?? "")
        
        // json compression
        let optimizedData : Data = try! data.gzipped(level: .bestCompression)
        return optimizedData.base64EncodedString()
        
    }
}

struct SigningView_Previews: PreviewProvider {
    static var previews: some View {
        SigningView(entry: .constant(divers(dives: [], diverEntries: diverEntry(dives: [], level: 0, name: ""))))
    }
}
