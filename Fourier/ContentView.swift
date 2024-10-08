//
//  ContentView.swift
//  Fourier
//
//  Created by Peter Vine on 30/09/2024.
//

import SwiftUI
import SDL2
import Cocoa

struct ContentView: View {
    
    
    @State var numberCircles: Double = 100
    
    var body: some View {
        
        VStack {

                        
            VStack {
                Text("number of circles: \(String(numberCircles))")
                Slider(value: ($numberCircles), in: 1 ... 200, step: 1)
                    
            }
            .onAppear() {
                DispatchQueue.main.async {
                    openSDLWindow(numberWaves: $numberCircles)
                }
            }
            

            
          

        }
      
        .padding()
        
    }
        
}

#Preview {
    ContentView()
}
