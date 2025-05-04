//
//  ContentView.swift
//  squaregame
//
//  Created by Akash01 on 2025-05-04.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "circle")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ContentView1: View {
    var body: some View {
        VStack {
            Image(systemName: "circle")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("View, world!")
            Text("View, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
    ContentView1()
}
