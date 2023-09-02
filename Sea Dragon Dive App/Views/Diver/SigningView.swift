//
//  SigningView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 7/27/23.
//

import SwiftUI

struct Line {
    var points = [CGPoint]()
    var color: Color = .black
    var lineWidth: Double = 1.0
}

struct SigningView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var currentLine = Line()
    @State private var lines: [Line] = []
    
    @Binding var entry: divers
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Sign yor dive entry")
                    .font(.title.bold())
                    .padding(.top)
                Text("I agree that I can perform these dives")
                
                ZStack {
                    Canvas { context, size in
                        for line in lines {
                            var path = Path()
                            path.addLines(line.points)
                            context.stroke(path, with: .color(line.color), lineWidth: line.lineWidth)
                        }
                        
                    }.gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
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
                    else {
                        NavigationLink(destination: DiverEntryQRCodeView(url: makeQRCode())) {
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
    }
    func makeQRCode() -> String {
        var finalCode: String = "{\"dives\":["
        for dive in 0..<entry.dives.count {
            if dive == entry.dives.count - 1 {
                finalCode += "\"\(entry.dives[dive].code ?? "")\""
            }
            else {
                finalCode += "\"\(entry.dives[dive].code ?? "")\","
            }
        }
        finalCode += "],\"level\":\(entry.diverEntries.level),\"name\":\"\(entry.diverEntries.name)\"}"
        return finalCode
    }
}

struct SigningView_Previews: PreviewProvider {
    static var previews: some View {
        SigningView(entry: .constant(divers(dives: [], diverEntries: diverEntry(dives: [], level: 0, name: ""))))
    }
}
