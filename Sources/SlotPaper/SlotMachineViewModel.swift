import SwiftUI
import AppKit

class SlotMachineViewModel: ObservableObject {
    // currentImages will reflect the final state of the reels
    @Published var currentImages: [String] = Array(repeating: "pexels-chevanon-1335971", count: 3)
    @Published var isSpinning = false
    @Published var hasWon = false
    // targetIndices drives the SlotReelView's landing position
    @Published var targetIndices: [Int] = [0, 0, 0]
    
    let slotImages = [
        "pexels-chevanon-1335971",
        "pexels-dreamypixel-547115",
        "pexels-eberhardgross-640809",
        "pexels-lum3n-44775-406014",
        "pexels-martinpechy-5335216",
        "pexels-moose-photos-170195-1037992",
        "pexels-nicole-avagliano-1132392-2236703",
        "pexels-rdne-6691864",
        "pexels-umkreisel-app-1146134"
    ]
    
    private var imageCache: [String: NSImage] = [:]
    private var spinCount = 0
    private var reelsStopped = 0
    
    var canSpin: Bool { !isSpinning }
    
    init() {
        print("SlotMachineViewModel: Initializing...")
        preloadImages()
        self.targetIndices = (0..<3).map { _ in Int.random(in: 0..<slotImages.count) }
        self.currentImages = self.targetIndices.map { self.slotImages[$0] }
        print("SlotMachineViewModel: Initialization complete. Image cache has \(imageCache.count) images")
    }
    
    private func preloadImages() {
        print("SlotMachineViewModel: Starting image preload...")
        
        // Get the bundle containing our resources
        let bundle = Bundle.module
        print("SlotMachineViewModel: Using bundle: \(bundle)")
        
        for imageName in slotImages {
            let imageNameWithExt = imageName + ".jpg"
            print("SlotMachineViewModel: Attempting to load \(imageNameWithExt)")
            
            if let imagePath = bundle.path(forResource: imageName, ofType: "jpg") {
                print("SlotMachineViewModel: Found path for \(imageNameWithExt): \(imagePath)")
                if let image = NSImage(contentsOfFile: imagePath) {
                    imageCache[imageName] = image
                    print("SlotMachineViewModel: Successfully loaded \(imageNameWithExt)")
                } else {
                    print("SlotMachineViewModel: Failed to create NSImage from path: \(imagePath)")
                }
            } else {
                print("SlotMachineViewModel: Could not find path for \(imageNameWithExt)")
            }
        }
        
        print("SlotMachineViewModel: Image preload complete. Loaded \(imageCache.count) images")
    }
    
    func getPreloadedImage(_ name: String) -> NSImage? {
        // Remove .jpg extension if it exists
        let baseName = name.replacingOccurrences(of: ".jpg", with: "")
        return imageCache[baseName]
    }
    
    func spin() {
        if !canSpin { return }
        
        print("SlotMachineViewModel: Starting spin")
        isSpinning = true
        hasWon = false
        reelsStopped = 0
        spinCount += 1
        
        let shouldWin = spinCount >= 3 || Double.random(in: 0...1) < 0.3
        if shouldWin {
            let winIndex = Int.random(in: 0..<slotImages.count)
            targetIndices = [winIndex, winIndex, winIndex]
            spinCount = 0
            print("SlotMachineViewModel: Win condition triggered. All reels will show \(slotImages[winIndex])")
        } else {
            var newIndices: [Int]
            repeat {
                newIndices = (0..<3).map { _ in Int.random(in: 0..<slotImages.count) }
            } while Set(newIndices).count == 1 && slotImages.count > 1
            targetIndices = newIndices
            print("SlotMachineViewModel: Non-win spin. Target indices: \(targetIndices)")
        }
    }
    
    func reelDidStop() {
        reelsStopped += 1
        print("SlotMachineViewModel: Reel stopped. \(reelsStopped)/3 reels have stopped")
        
        if reelsStopped >= 3 {
            isSpinning = false
            self.currentImages = self.targetIndices.map { self.slotImages[$0] }
            hasWon = Set(targetIndices).count == 1
            
            if hasWon {
                print("SlotMachineViewModel: Win condition achieved!")
                NSSound(named: "Glass")?.play()
            }
            
            reelsStopped = 0
        }
    }
} 