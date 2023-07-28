//
//  CoachEditSigningView.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 8/21/23.
//

import SwiftUI

struct CoachEditSigningView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var currentLine = Line()
    @State private var lines: [Line] = []
    
    @EnvironmentObject var coachEntryStore: CoachEntryStore
    
    var body: some View {
            NavigationStack {
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Dismiss")
                }
                .padding()
                Text("Diver Must Signs Their Dive Entry")
                    .font(.title2.bold())
                    .padding(.top)
                Text("I agree that I can perform these dives")
                
                ZStack {
                    Canvas { context, size in
                        for line in lines {
                            var path = Path()
                            path.addLines(line.points)
                            context.stroke(path, with: .color(colorScheme == .dark ? .white : .black), lineWidth: line.lineWidth)
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
                        Button {
                            self.presentationMode.wrappedValue.dismiss()
                        } label: {
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

struct CoachEditSigningView_Previews: PreviewProvider {
    static var previews: some View {
        CoachEditSigningView()
    }
}
