import SwiftUI

struct SlotReelView: View {
    let images: [String]
    let targetIndex: Int
    let spinTrigger: Bool
    let onSpinEnd: () -> Void
    @ObservedObject var viewModel: SlotMachineViewModel
    
    @State private var offset: CGFloat = 0
    @State private var currentIndex: Int = 0
    @State private var isSpinning = false
    @State private var displayedIndices: [Int] = []
    
    private let imageSize: CGFloat = 180
    private let spinningImages = 15 // Number of images to show during spin
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Debug background
                Color.black.opacity(0.3)
                
                // Main reel content
                VStack(spacing: 0) {
                    if isSpinning {
                        // During spin, show multiple images
                        ForEach(0..<spinningImages, id: \.self) { i in
                            let index = (currentIndex + i) % images.count
                            if let image = viewModel.getPreloadedImage(images[index]) {
                                Image(nsImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: imageSize, height: imageSize)
                                    .clipped()
                            }
                        }
                    } else {
                        // At rest, show 3 images
                        ForEach(-1...1, id: \.self) { offset in
                            let index = (currentIndex + offset + images.count) % images.count
                            if let image = viewModel.getPreloadedImage(images[index]) {
                                Image(nsImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: imageSize, height: imageSize)
                                    .clipped()
                            }
                        }
                    }
                }
                .offset(y: offset)
                
                // Gradient overlay for fade effect
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .black.opacity(0.8), location: 0),
                        .init(color: .clear, location: 0.3),
                        .init(color: .clear, location: 0.7),
                        .init(color: .black.opacity(0.8), location: 1)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        .frame(width: imageSize, height: imageSize)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .onAppear {
            currentIndex = Int.random(in: 0..<images.count)
            offset = -imageSize
        }
        .onChange(of: spinTrigger) { newValue in
            if newValue && !isSpinning {
                startSpin()
            }
        }
    }
    
    private func startSpin() {
        isSpinning = true
        
        // Initial quick acceleration
        withAnimation(.easeIn(duration: 0.3)) {
            offset = -imageSize * 3
        }
        
        // Main spinning animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(
                .linear(duration: 2.0)
                .repeatCount(3, autoreverses: false)
            ) {
                offset -= imageSize * CGFloat(spinningImages)
            }
            
            // Final deceleration to target
            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                withAnimation(.easeOut(duration: 0.5)) {
                    currentIndex = targetIndex
                    offset = -imageSize
                    isSpinning = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onSpinEnd()
                }
            }
        }
    }
}

struct ReelContent: View {
    let images: [String]
    let currentImage: String
    let reelHeight: CGFloat
    let scrollOffset: CGFloat
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let currentTime = timeline.date.timeIntervalSince1970
            
            VStack(spacing: 0) {
                ForEach(0..<20) { index in
                    let imageIndex = Int(((currentTime * 2 + Double(index)) * 5).truncatingRemainder(dividingBy: Double(images.count)))
                    if let image = Bundle.module.image(forResource: images[imageIndex]) {
                        Image(nsImage: image)
                            .resizable()
                            .interpolation(.medium)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: reelHeight, height: reelHeight)
                            .clipped()
                    }
                }
            }
            .offset(y: -scrollOffset)
        }
    }
}

private func slotEmoji(for slot: String) -> String {
    switch slot {
    case "slot1": return "🎯"
    case "slot2": return "🎲"
    case "slot3": return "🎰"
    case "slot4": return "🎪"
    case "slot5": return "🎨"
    case "slot6": return "🎭"
    default: return ""
    }
} 