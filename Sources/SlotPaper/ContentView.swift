import SwiftUI

struct ContentView: View {
    @StateObject private var slotMachine = SlotMachineViewModel()
    @State private var isShowingWallpaperOverlay = false
    @State private var isShowingShareSheet = false
    @State private var spinTrigger = false // Used to trigger spin on all reels
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.2, green: 0.1, blue: 0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Slot machine display
                ZStack {
                    // Background container with glass effect
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.ultraThinMaterial)
                        .shadow(radius: 20, y: 10)
                    
                    // Slots container
                    HStack(spacing: 20) {
                        ForEach(0..<3) { index in
                            SlotReelView(
                                images: slotMachine.slotImages,
                                targetIndex: slotMachine.targetIndices[index],
                                spinTrigger: slotMachine.isSpinning,
                                onSpinEnd: {
                                    slotMachine.reelDidStop()
                                },
                                viewModel: slotMachine
                            )
                        }
                    }
                    .padding(20)
                }
                .frame(height: 240)
                
                // Controls
                HStack(spacing: 30) {
                    Button(action: {
                        slotMachine.spin()
                    }) {
                        Label("Spin", systemImage: "arrow.2.circlepath")
                            .font(.title2)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .disabled(slotMachine.isSpinning)
                    
                    Button(action: { isShowingShareSheet = true }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .font(.title2)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Wallpaper set overlay
            if isShowingWallpaperOverlay {
                WallpaperOverlayView(
                    isShowing: $isShowingWallpaperOverlay,
                    slotImage: slotMachine.slotImages[slotMachine.targetIndices[0]]
                )
            }
            
            // Share sheet overlay
            if isShowingShareSheet {
                ShareOverlayView(isShowing: $isShowingShareSheet)
            }
        }
        .onChange(of: slotMachine.hasWon) { hasWon in
            if hasWon {
                withAnimation(.spring(duration: 0.5)) {
                    isShowingWallpaperOverlay = true
                }
            }
        }
    }
} 