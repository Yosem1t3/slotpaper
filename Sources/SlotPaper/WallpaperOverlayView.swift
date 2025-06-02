import SwiftUI

struct WallpaperOverlayView: View {
    @Binding var isShowing: Bool
    let slotImage: String
    @State private var scale: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            if let image = NSImage(named: slotImage) ?? Bundle.module.image(forResource: slotImage) {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay {
                        overlayContent
                    }
            }
        }
        .onAppear {
            // Play success sound
            NSSound.beep()
            
            withAnimation(.spring(duration: 0.6)) {
                scale = 1
            }
        }
    }
    
    private var overlayContent: some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)
            
            Text("New Wallpaper Set!")
                .font(.title)
                .bold()
                .foregroundStyle(.white)
            
            Button("Done") {
                withAnimation(.spring(duration: 0.5)) {
                    isShowing = false
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(40)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .scaleEffect(scale)
    }
    
    private func slotEmoji(for slot: String) -> String {
        switch slot {
        case "slot1": return "🎯"
        case "slot2": return "🎲"
        case "slot3": return "🎰"
        case "slot4": return "🎪"
        case "slot5": return "🎨"
        case "slot6": return "🎭"
        default: return "��"
        }
    }
} 