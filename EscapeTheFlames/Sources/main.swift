import SwiftUI

@main
struct EscapeTheFlamesApp: App {
    var body: some Scene {
        WindowGroup {
            InfernoMainView()
        }
    }
}

struct InfernoMainView: View {
    @State private var isLoading = true
    private var escapeGameEndpoint: URL { URL(string: "https://escapeteflanes.com/view")! }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.27, blue: 0.0),
                    Color(red: 0.86, green: 0.08, blue: 0.24),
                    Color(red: 0.55, green: 0.0, blue: 0.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if isLoading {
                InfernoAnimationView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            withAnimation(.easeInOut(duration: 1.2)) {
                                isLoading = false
                            }
                        }
                    }
            } else {
                VStack {
                    Text("🔥 Escape The Flames 🔥")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .padding()
                    
                    Text("Game Loading Complete!")
                        .font(.title2)
                        .foregroundColor(.orange)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

struct InfernoAnimationView: View {
    @State private var animateFlames = false
    @State private var animateEmbers = false
    @State private var pulseIntensity = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Fire gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 1.0, green: 0.27, blue: 0.0),
                        Color(red: 0.86, green: 0.08, blue: 0.24),
                        Color(red: 0.55, green: 0.0, blue: 0.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Animated Flames
                FlameParticlesView(animate: $animateFlames)
                
                // Floating Embers
                EmbersView(animate: $animateEmbers)
                    .offset(y: -geo.size.height * 0.2)
                
                VStack {
                    Spacer()
                    
                    // Pulsing fire icon
                    Image(systemName: "flame.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 80)
                        .foregroundColor(.orange)
                        .scaleEffect(pulseIntensity ? 1.3 : 1.0)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulseIntensity)
                    
                    Text("Igniting Flames...")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .opacity(animateFlames ? 1 : 0)
                        .animation(.easeInOut(duration: 1.5).delay(0.8), value: animateFlames)
                        .padding(.bottom, 80)
                }
            }
            .onAppear {
                animateFlames = true
                animateEmbers = true
                pulseIntensity = true
            }
        }
    }
}

struct FlameParticlesView: View {
    @Binding var animate: Bool
    
    var body: some View {
        ZStack {
            FlameParticle(delay: 0, speed: 3.0, color: .orange)
                .offset(x: animate ? 200 : -200, y: animate ? -100 : 100)
            FlameParticle(delay: 0.8, speed: 2.5, color: .red)
                .offset(x: animate ? -180 : 180, y: animate ? -80 : 120)
            FlameParticle(delay: 1.5, speed: 3.5, color: .yellow)
                .offset(x: animate ? 150 : -150, y: animate ? -120 : 80)
        }
    }
}

struct FlameParticle: View {
    let delay: Double
    let speed: Double
    let color: Color
    
    var body: some View {
        Circle()
            .fill(RadialGradient(
                gradient: Gradient(colors: [color, color.opacity(0.3)]),
                center: .center,
                startRadius: 5,
                endRadius: 25
            ))
            .frame(width: 50, height: 50)
            .blur(radius: 8)
            .animation(.easeInOut(duration: speed).repeatForever(autoreverses: true).delay(delay), value: UUID())
    }
}

struct EmbersView: View {
    @Binding var animate: Bool
    
    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(Color.orange.opacity(0.7))
                    .frame(width: 8, height: 8)
                    .offset(
                        x: animate ? CGFloat.random(in: -200...200) : CGFloat.random(in: -50...50),
                        y: animate ? CGFloat.random(in: -300...300) : CGFloat.random(in: -100...100)
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 2...4))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.3),
                        value: animate
                    )
            }
        }
    }
}
