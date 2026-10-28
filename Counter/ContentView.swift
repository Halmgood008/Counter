//
//  ContentView.swift
//  Counter
//
//  Created by ZhuliK on 27.10.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var counter = 0

    var body: some View {
        VStack(spacing: 30) {
            Text("Значение счётчика: \(counter)")
                .font(.title)
                .fontWeight(.medium)
            
            Button(action: {
                counter += 1
            }) {
                Text("Click")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
        }
        .padding()
    }
}
