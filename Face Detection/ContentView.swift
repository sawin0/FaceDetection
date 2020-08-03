//
//  ContentView.swift
//  Face Detection
//
//  Created by Sabin RanaBhat on 8/3/20.
//  Copyright © 2020 Sabin Ranabhat. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            VCSwiftUIView(storyboard: "Main", VC: "initialVC")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
