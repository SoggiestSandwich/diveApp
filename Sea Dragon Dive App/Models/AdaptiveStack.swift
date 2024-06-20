//
//  AdaptiveStack.swift
//  Sea Dragon Dive App
//
//  Created by Jacob Richardt on 8/11/23.
//

import SwiftUI

//struct used to easily go back to the login view
struct adaptiveStack<Content: View>: View {
    let horizontalStack: Bool
    let content: () -> Content
    
    init(
        horizontalStack: Bool,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.horizontalStack = horizontalStack
        self.content = content
    }
    
    var body: some View {
        Group {
            if horizontalStack {
                HStack(content: content)
            }
            else {
                VStack(content: content)
            }
        }
    }
}
