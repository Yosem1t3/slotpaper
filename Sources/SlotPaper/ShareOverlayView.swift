import SwiftUI

struct ShareOverlayView: View {
    @Binding var isShowing: Bool
    @State private var progress: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "square.and.arrow.up.circle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.blue)
                
                Text("Sharing Screenshot...")
                    .font(.title2)
                    .foregroundStyle(.white)
                
                ProgressView(value: progress)
                    .progressViewStyle(.linear)
                    .frame(width: 200)
            }
            .padding(30)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .onAppear {
            // Simulate sharing progress
            withAnimation(.easeInOut(duration: 1.5)) {
                progress = 1.0
            }
            
            // Dismiss after "completion"
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.spring(duration: 0.5)) {
                    isShowing = false
                }
            }
        }
    }
} 