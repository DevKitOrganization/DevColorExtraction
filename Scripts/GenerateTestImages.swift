#!/usr/bin/env swift

import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let resourcesPath = "/Users/prachi/Developer/DevColorExtraction/Tests/DevColorExtractionTests/Resources"

func createContext(width: Int, height: Int) -> CGContext? {
    return CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: width * 4,
        space: CGColorSpace(name: CGColorSpace.sRGB)!,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )
}

func saveImage(_ image: CGImage, filename: String) {
    let url = URL(fileURLWithPath: "\(resourcesPath)/\(filename)")
    guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
        print("Failed to create destination for \(filename)")
        return
    }
    
    CGImageDestinationAddImage(destination, image, nil)
    if CGImageDestinationFinalize(destination) {
        print("Created: \(filename)")
    } else {
        print("Failed to save: \(filename)")
    }
}

// MARK: - Basic Color Distribution Images

func generateBasicColorImages() {
    print("Generating basic color distribution images...")
    
    // Equal distribution (4 colors at 25% each)
    if let context = createContext(width: 400, height: 400) {
        // Red quarter (top-left)
        context.setFillColor(CGColor(srgbRed: 1.0, green: 0.0, blue: 0.0, alpha: 1.0))
        context.fill(CGRect(x: 0, y: 200, width: 200, height: 200))
        
        // Green quarter (top-right)
        context.setFillColor(CGColor(srgbRed: 0.0, green: 1.0, blue: 0.0, alpha: 1.0))
        context.fill(CGRect(x: 200, y: 200, width: 200, height: 200))
        
        // Blue quarter (bottom-left)
        context.setFillColor(CGColor(srgbRed: 0.0, green: 0.0, blue: 1.0, alpha: 1.0))
        context.fill(CGRect(x: 0, y: 0, width: 200, height: 200))
        
        // Yellow quarter (bottom-right)
        context.setFillColor(CGColor(srgbRed: 1.0, green: 1.0, blue: 0.0, alpha: 1.0))
        context.fill(CGRect(x: 200, y: 0, width: 200, height: 200))
        
        if let image = context.makeImage() {
            saveImage(image, filename: "Equal-4-Colors.png")
        }
    }
    
    // Single dominant color (90% white, 10% black)
    if let context = createContext(width: 400, height: 400) {
        // White background
        context.setFillColor(CGColor(srgbRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        context.fill(CGRect(x: 0, y: 0, width: 400, height: 400))
        
        // Black strip (10% of area = 40 pixels wide)
        context.setFillColor(CGColor(srgbRed: 0.0, green: 0.0, blue: 0.0, alpha: 1.0))
        context.fill(CGRect(x: 0, y: 0, width: 40, height: 400))
        
        if let image = context.makeImage() {
            saveImage(image, filename: "Dominant-White-90-Black-10.png")
        }
    }
}

// MARK: - Edge Detection Images

func generateEdgeImages() {
    print("Generating edge detection images...")
    
    // Gradient border image (different color on each edge)
    if let context = createContext(width: 200, height: 200) {
        // White center
        context.setFillColor(CGColor(srgbRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        context.fill(CGRect(x: 1, y: 1, width: 198, height: 198))
        
        // Red top edge
        context.setFillColor(CGColor(srgbRed: 1.0, green: 0.0, blue: 0.0, alpha: 1.0))
        context.fill(CGRect(x: 0, y: 199, width: 200, height: 1))
        
        // Green right edge
        context.setFillColor(CGColor(srgbRed: 0.0, green: 1.0, blue: 0.0, alpha: 1.0))
        context.fill(CGRect(x: 199, y: 0, width: 1, height: 200))
        
        // Blue bottom edge
        context.setFillColor(CGColor(srgbRed: 0.0, green: 0.0, blue: 1.0, alpha: 1.0))
        context.fill(CGRect(x: 0, y: 0, width: 200, height: 1))
        
        // Yellow left edge
        context.setFillColor(CGColor(srgbRed: 1.0, green: 1.0, blue: 0.0, alpha: 1.0))
        context.fill(CGRect(x: 0, y: 0, width: 1, height: 200))
        
        if let image = context.makeImage() {
            saveImage(image, filename: "Edge-Colors.png")
        }
    }
    
    // Frame-style image (thick colored border)
    if let context = createContext(width: 200, height: 200) {
        // Purple background
        context.setFillColor(CGColor(srgbRed: 0.5, green: 0.0, blue: 0.5, alpha: 1.0))
        context.fill(CGRect(x: 0, y: 0, width: 200, height: 200))
        
        // Orange center
        context.setFillColor(CGColor(srgbRed: 1.0, green: 0.5, blue: 0.0, alpha: 1.0))
        context.fill(CGRect(x: 20, y: 20, width: 160, height: 160))
        
        if let image = context.makeImage() {
            saveImage(image, filename: "Frame-Purple-Orange.png")
        }
    }
}

// MARK: - Complex Distribution Images

func generateComplexImages() {
    print("Generating complex distribution images...")
    
    // Multiple similar colors (different shades of red)
    if let context = createContext(width: 300, height: 300) {
        // Light red (40%)
        context.setFillColor(CGColor(srgbRed: 1.0, green: 0.7, blue: 0.7, alpha: 1.0))
        context.fill(CGRect(x: 0, y: 0, width: 300, height: 120))
        
        // Medium red (35%)
        context.setFillColor(CGColor(srgbRed: 1.0, green: 0.3, blue: 0.3, alpha: 1.0))
        context.fill(CGRect(x: 0, y: 120, width: 300, height: 105))
        
        // Dark red (25%)
        context.setFillColor(CGColor(srgbRed: 0.6, green: 0.0, blue: 0.0, alpha: 1.0))
        context.fill(CGRect(x: 0, y: 225, width: 300, height: 75))
        
        if let image = context.makeImage() {
            saveImage(image, filename: "Red-Shades.png")
        }
    }
    
    // Small color patches (checkerboard pattern)
    if let context = createContext(width: 200, height: 200) {
        let squareSize = 25
        let colors = [
            CGColor(srgbRed: 1.0, green: 0.0, blue: 0.0, alpha: 1.0), // Red
            CGColor(srgbRed: 0.0, green: 1.0, blue: 0.0, alpha: 1.0), // Green
            CGColor(srgbRed: 0.0, green: 0.0, blue: 1.0, alpha: 1.0), // Blue
            CGColor(srgbRed: 1.0, green: 1.0, blue: 0.0, alpha: 1.0), // Yellow
        ]
        
        for row in 0..<8 {
            for col in 0..<8 {
                let colorIndex = (row + col) % colors.count
                context.setFillColor(colors[colorIndex])
                context.fill(CGRect(x: col * squareSize, y: row * squareSize, width: squareSize, height: squareSize))
            }
        }
        
        if let image = context.makeImage() {
            saveImage(image, filename: "Checkerboard.png")
        }
    }
}

// MARK: - Edge Cases

func generateEdgeCases() {
    print("Generating edge case images...")
    
    // 1x1 pixel image (single red pixel)
    if let context = createContext(width: 1, height: 1) {
        context.setFillColor(CGColor(srgbRed: 1.0, green: 0.0, blue: 0.0, alpha: 1.0))
        context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        
        if let image = context.makeImage() {
            saveImage(image, filename: "Single-Red-Pixel.png")
        }
    }
    
    // Large uniform image (100x100 blue)
    if let context = createContext(width: 100, height: 100) {
        context.setFillColor(CGColor(srgbRed: 0.0, green: 0.0, blue: 1.0, alpha: 1.0))
        context.fill(CGRect(x: 0, y: 0, width: 100, height: 100))
        
        if let image = context.makeImage() {
            saveImage(image, filename: "Uniform-Blue-100x100.png")
        }
    }
    
    // Noisy image (base colors with noise)
    if let context = createContext(width: 200, height: 200) {
        // Base: 50% red, 50% blue (split vertically)
        context.setFillColor(CGColor(srgbRed: 1.0, green: 0.0, blue: 0.0, alpha: 1.0))
        context.fill(CGRect(x: 0, y: 0, width: 100, height: 200))
        
        context.setFillColor(CGColor(srgbRed: 0.0, green: 0.0, blue: 1.0, alpha: 1.0))
        context.fill(CGRect(x: 100, y: 0, width: 100, height: 200))
        
        // Add some noise pixels (green and yellow)
        let noiseColors = [
            CGColor(srgbRed: 0.0, green: 1.0, blue: 0.0, alpha: 1.0), // Green
            CGColor(srgbRed: 1.0, green: 1.0, blue: 0.0, alpha: 1.0), // Yellow
        ]
        
        // Add scattered noise pixels (about 2% of image)
        for _ in 0..<800 {
            let x = Int.random(in: 0..<200)
            let y = Int.random(in: 0..<200)
            let colorIndex = Int.random(in: 0..<noiseColors.count)
            
            context.setFillColor(noiseColors[colorIndex])
            context.fill(CGRect(x: x, y: y, width: 1, height: 1))
        }
        
        if let image = context.makeImage() {
            saveImage(image, filename: "Noisy-Red-Blue.png")
        }
    }
}

// MARK: - Additional test images for different scenarios

func generateAdditionalImages() {
    print("Generating additional test images...")
    
    // Transparent regions test
    if let context = createContext(width: 200, height: 200) {
        // Clear the context (transparent)
        context.clear(CGRect(x: 0, y: 0, width: 200, height: 200))
        
        // Semi-transparent red circle
        context.setFillColor(CGColor(srgbRed: 1.0, green: 0.0, blue: 0.0, alpha: 0.5))
        context.fillEllipse(in: CGRect(x: 50, y: 50, width: 100, height: 100))
        
        // Opaque blue rectangle
        context.setFillColor(CGColor(srgbRed: 0.0, green: 0.0, blue: 1.0, alpha: 1.0))
        context.fill(CGRect(x: 25, y: 25, width: 50, height: 150))
        
        if let image = context.makeImage() {
            saveImage(image, filename: "Transparency-Test.png")
        }
    }
    
    // Gradient test image
    if let context = createContext(width: 256, height: 100) {
        // Create a horizontal gradient from red to blue
        for x in 0..<256 {
            let redComponent = 1.0 - (CGFloat(x) / 255.0)
            let blueComponent = CGFloat(x) / 255.0
            
            context.setFillColor(CGColor(srgbRed: redComponent, green: 0.0, blue: blueComponent, alpha: 1.0))
            context.fill(CGRect(x: x, y: 0, width: 1, height: 100))
        }
        
        if let image = context.makeImage() {
            saveImage(image, filename: "Gradient-Red-Blue.png")
        }
    }
}

// MARK: - Main execution

print("Generating test images for MostCommonColors...")

generateBasicColorImages()
generateEdgeImages()
generateComplexImages() 
generateEdgeCases()
generateAdditionalImages()

print("Done! All test images have been generated.")