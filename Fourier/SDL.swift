import SDL
import SwiftUI
import ComplexModule
    
func calculateFourierTransform(points: [Complex<Double>]) -> [Complex<Double>] {
    
    var coefficients: [Complex<Double>] = []
    
    for k in (0..<points.count) {
        
        var coefficient: Complex<Double> = 0
        for n in (0..<points.count) {
            
            let point = points[n]
            
            let function = -2 * Double.pi * Double(n) * Double(k) / Double(points.count)
            
            
            coefficient += point * Complex<Double>(cos(function), sin(function))
            
        }
        coefficients.append(coefficient)
    }
    
    
    return coefficients
    
}

struct Wave {
    
    var frequency: Int
    var amplitude: Double
    var phase: Double
    
}
    
func coefficientsToWaves(coefficients: [Complex<Double>]) -> [Wave] {
    
    var waves: [Wave] = []
    
    for i in 0...coefficients.count - 1 {
        
        
        let coefficient = coefficients[i]
        
        let amplitude = sqrt(pow(coefficient.real, 2) + pow(coefficient.imaginary, 2))
        
        
        let phase = atan2(coefficient.imaginary, coefficient.real)
        
        let frequency = i
        
        let wave = Wave(frequency: frequency, amplitude: amplitude, phase: phase)
        
        waves.append(wave)

    }
    
    return waves
    
    
}


func openSDLWindow(numberWaves: Binding<Double>) {
    let w: Int32 = 1200
    let h: Int32 = 800
    
    // Initialize SDL video systems
    guard SDL_Init(SDL_INIT_VIDEO) == 0 else {
        fatalError("SDL could not initialize! SDL_Error: \(String(cString: SDL_GetError()))")
    }
    
    // Create a window at the center of the screen with 800x600 pixel resolution
    let window = SDL_CreateWindow(
        "SDL2 Minimal Demo",
        Int32(SDL_WINDOWPOS_CENTERED_MASK), Int32(SDL_WINDOWPOS_CENTERED_MASK),
        w, h,
        UInt32(SDL_WINDOW_SHOWN.rawValue)
    )
    
    // Create a renderer associated with the window
    let renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED.rawValue)

    var quit = false
    var event = SDL_Event()
    
    
    
    var clicked = false
    
    var points: [Complex<Double>] = []
    
    var doCalculation = false
    var calculated = false
    // Run until app is quit
    
    
    var frameNumber: Int = 0
    
    var waves: [Wave] = []

    
    while !quit {
        
        
        var mouseXLocation: Int32 = -2
        var mouseYLocation: Int32 = -2

        // Poll for (input) events
        while SDL_PollEvent(&event) > 0 {
            // if the quit event is triggered ...
            if event.type == SDL_QUIT.rawValue {
                // ... quit the run loop
                quit = true
            }
            
        
            
            if event.type == SDL_MOUSEBUTTONDOWN.rawValue {
                
                clicked = true
                
                
            } else if event.type == SDL_MOUSEBUTTONUP.rawValue {
                clicked = false
            }
          
            
            
            if event.type == SDL_MOUSEMOTION.rawValue {
                mouseXLocation = event.motion.x
                mouseYLocation = event.motion.y
            }
            
        }
        
        // Set the draw color for clearing the screen (black)
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255)
        SDL_RenderClear(renderer) // Clear the renderer
        
        
        SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255)

        
        if clicked && mouseXLocation != -2 && mouseYLocation != -2 {
            
            
            //let point = Complex(Double(mouseXLocation / w) * 2 - 1, Double(mouseYLocation / h) * 2 - 1)
            var point = Complex(Double(mouseXLocation) / Double(w) * 2 - 1, Double(mouseYLocation) / Double(h) * 2 - 1)
            

            //point /= Complex(Double(w), Double(h)) * 2 - 1
            
            points.append(point)
            
            waves = []

            
            
            doCalculation = true
        }
        
        if doCalculation && !clicked {
            
            let coefficients = calculateFourierTransform(points: points)
            
            
            waves = coefficientsToWaves(coefficients: coefficients)
            
            calculated = true
            doCalculation = false
            
        }
        
        
        
        if calculated {
            
            let angle = 2 * Double.pi * Double(frameNumber + 1) / Double(waves.count)
            

            var offset: Complex<Double> = Complex(0, 0)
            
            waves.sort{ $0.amplitude > $1.amplitude }
            
            
            var reducedWaves: [Wave] = waves
            
            if numberWaves.wrappedValue < Double(waves.count) {
                
                
                reducedWaves = Array(waves[0 ..< Int(numberWaves.wrappedValue)])
                
            }
            
            
            
            for wave in reducedWaves {
                
                
                let prevPoint = offset
                
                
                
                let function = (angle * Double(wave.frequency) + wave.phase)
                

                
                offset += Complex<Double>(cos(function), sin(function)) * Complex<Double>(wave.amplitude) / Complex<Double>(waves.count) / 2
                
                
                SDL_RenderDrawLine(renderer, w / 2 + Int32(prevPoint.real * Double(w)), h / 2 + Int32(prevPoint.imaginary * Double(h)), w / 2 + Int32(offset.real * Double(w)), h / 2 + Int32(offset.imaginary * Double(h)))

            }
            
            SDL_RenderDrawPoint(renderer, w / 2 + Int32(offset.real * Double(w)), h / 2 + Int32(offset.imaginary * Double(h)))
            
            
            
            SDL_Delay(10)

        }
                
        // Set the draw color for the rectangle (white)

        for point in points {
            
            let transformedPoint = Complex((point.real + 1) / 2 * Double(w), (point.imaginary + 1) / 2 * Double(h))
            
            SDL_RenderDrawPoint(renderer, Int32(transformedPoint.real), Int32(transformedPoint.imaginary))
            
        }
        
        
        
        
        

        // Present the back buffer
        SDL_RenderPresent(renderer)
        
        
        frameNumber += 1
        

        
    }
    
    // Destroy the renderer
    SDL_DestroyRenderer(renderer)
    // Destroy the window
    SDL_DestroyWindow(window)
    
    // Quit all SDL systems
    SDL_Quit()
}

// Call the function to open the SDL window
