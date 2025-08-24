//
//  MostCommonColorsTests.swift
//  DevColorExtraction
//
//  Created by Prachi Gauriar on 8/23/25.
//

import CoreGraphics
import DevColorExtraction
import Foundation
import ImageIO
import RealModule
import Testing

struct MostCommonColorsTests {
    @Test
    func testEqualFourColors() throws {
        let image = try loadTestPNG("Equal-4-Colors")
        let result = try #require(image.mostCommonColors(count: 3))
        #expect(result.count == 3)

        // Should get 3 meaningful clusters with reasonable weights
        let totalWeight = result.map(\.weight).reduce(0, +)
        #expect(totalWeight.isApproximatelyEqual(to: 1.0, absoluteTolerance: 0.05))

        // All colors should have meaningful weight (> 10%)
        for (_, weight) in result {
            #expect(weight > 0.1)
        }

        // Should detect yellow, green, and purple/red-blue cluster
        let colors = result.map(\.color)

        let hasYellow = colors.contains { color in
            guard let components = color.components else {
                return false
            }
            return components[0] > 0.9 && components[1] > 0.9 && components[2] < 0.1
        }

        let hasGreen = colors.contains { color in
            guard let components = color.components else {
                return false
            }
            return components[0] < 0.1 && components[1] > 0.9 && components[2] < 0.1
        }

        let hasRedBlueCluster = colors.contains { color in
            guard let components = color.components else {
                return false
            }
            return (components[0] > 0.5 && components[2] > 0.5)    // Purple/magenta
                || (components[0] > 0.9 && components[1] < 0.1)    // Pure red
                || (components[2] > 0.9 && components[1] < 0.1)    // Pure blue
        }

        #expect(hasYellow, "Does not detect yellow")
        #expect(hasGreen, "Does not detect green")
        #expect(hasRedBlueCluster, "Does not detect red-blue cluster")
    }


    @Test
    func testDominantWhiteWithBlack() throws {
        let image = try loadTestPNG("Dominant-White-90-Black-10")
        let result = try #require(image.mostCommonColors(count: 2))
        #expect(result.count == 2)

        // First color should be white with ~90% weight
        let color1 = result[0]
        expectEqualColors(color1.color, CGColor(srgbRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        #expect(color1.weight.isApproximatelyEqual(to: 0.9, absoluteTolerance: 0.05))

        // Second color should be black with ~10% weight
        let color2 = result[1]
        expectEqualColors(color2.color, CGColor(srgbRed: 0.0, green: 0.0, blue: 0.0, alpha: 1.0))
        #expect(color2.weight.isApproximatelyEqual(to: 0.1, absoluteTolerance: 0.05))
    }


    @Test
    func testResultsOrderedByWeight() throws {
        let image = try loadTestPNG("Dominant-White-90-Black-10")
        let result = try #require(image.mostCommonColors(count: 2))
        #expect(result.count == 2)

        // Results should be ordered by descending weight
        #expect(result[0].weight > result[1].weight)
    }


    @Test
    func testSingleRedPixel() throws {
        let image = try loadTestPNG("Single-Red-Pixel")
        let result = try #require(image.mostCommonColors(count: 1))

        #expect(result.count == 1)
        expectEqualColors(result[0].color, CGColor(srgbRed: 1.0, green: 0.0, blue: 0.0, alpha: 1.0))
        #expect(result[0].weight.isApproximatelyEqual(to: 1.0, absoluteTolerance: 0.01))
    }


    @Test
    func testUniformBlue() throws {
        let image = try loadTestPNG("Uniform-Blue-100x100")
        let result = try #require(image.mostCommonColors(count: 1))

        #expect(result.count == 1)
        expectEqualColors(result[0].color, CGColor(srgbRed: 0.0, green: 0.0, blue: 1.0, alpha: 1.0))
        #expect(result[0].weight.isApproximatelyEqual(to: 1.0, absoluteTolerance: 0.01))
    }


    @Test(
        arguments: [
            (EdgeSet.top, 1.0, 0.0, 0.0),
            (EdgeSet.left, 1.0, 1.0, 0.0),
            (EdgeSet.bottom, 0.0, 0.0, 1.0),
            (EdgeSet.right, 0.0, 1.0, 0.0),
        ]
    )
    func testEdgeExtraction(edge: EdgeSet, red: CGFloat, green: CGFloat, blue: CGFloat) throws {
        let image = try loadTestPNG("Edge-Colors")
        let result = try #require(image.mostCommonColors(count: 1, edges: edge))
        #expect(result.count == 1)
        expectEqualColors(
            result[0].color,
            CGColor(srgbRed: red, green: green, blue: blue, alpha: 1.0),
            tolerance: 0.15
        )
    }


    @Test
    func testMultipleEdgeExtraction() throws {
        let image = try loadTestPNG("Edge-Colors")

        let result = try #require(image.mostCommonColors(count: 2, edges: .vertical))

        #expect(result.count == 2)

        // Algorithm clusters red+blue edges into purple/magenta
        let hasPurple = result.contains { (color, weight) in
            guard let components = color.components else { return false }
            return components[0] > 0.6 && components[2] > 0.6 && components[1] < 0.2 && weight > 0.9
        }

        #expect(hasPurple, "Does not detect purple cluster from red+blue edges")
    }


    @Test
    func testAllEdgesExtraction() throws {
        let image = try loadTestPNG("Edge-Colors")
        let result = try #require(image.mostCommonColors(count: 4, edges: .all))

        #expect(result.count == 4)

        // Should detect three meaningful edge colors with reasonable weights
        let meaningfulColors = result.filter { $0.weight > 0.15 }
        #expect(meaningfulColors.count == 3, "Does not detect exactly 3 meaningful edge colors")

        // Total weight should be close to 1.0
        let totalWeight = result.map(\.weight).reduce(0, +)
        #expect(totalWeight.isApproximatelyEqual(to: 1.0, absoluteTolerance: 0.05))

        // Should have purple (red+blue cluster), yellow, and green
        let hasPurple = result.contains { (color, weight) in
            guard let components = color.components else { return false }
            return components[0] > 0.6 && components[2] > 0.6 && components[1] < 0.2 && weight > 0.4
        }

        let hasYellow = result.contains { (color, weight) in
            guard let components = color.components else { return false }
            return components[0] > 0.9 && components[1] > 0.9 && components[2] < 0.1 && weight > 0.2
        }

        let hasGreen = result.contains { (color, weight) in
            guard let components = color.components else { return false }
            return components[0] < 0.1 && components[1] > 0.9 && components[2] < 0.1 && weight > 0.2
        }

        #expect(hasPurple, "Does not detect purple cluster from red+blue edges")
        #expect(hasYellow, "Does not detect yellow from left edge")
        #expect(hasGreen, "Does not detect green from right edge")
    }


    @Test
    func testRedShades() throws {
        let image = try loadTestPNG("Red-Shades")
        let result = try #require(image.mostCommonColors(count: 3))

        #expect(result.count == 3)

        // Should detect 3 different shades of red with different weights
        let totalWeight = result.map(\.weight).reduce(0, +)
        #expect(totalWeight.isApproximatelyEqual(to: 1.0, absoluteTolerance: 0.05))

        // All colors should be reddish (red component dominant)
        for (color, weight) in result where weight > 0 {
            guard let components = color.components else {
                Issue.record("Could not get color components")
                continue
            }
            #expect(components[0] > components[1], "Red component is not greater than green")
            #expect(components[0] > components[2], "Red component is not greater than blue")
        }
    }


    @Test
    func testFrameImage() throws {
        let image = try loadTestPNG("Frame-Purple-Orange")
        let result = try #require(image.mostCommonColors(count: 2))

        #expect(result.count == 2)

        // Should detect two distinct color regions
        let colors = result.map(\.color)

        let hasPurple = colors.contains { color in
            guard let components = color.components else {
                return false
            }
            return components[0] > 0.3 && components[0] < 0.7    // Moderate red
                && components[1] < 0.2    // Low green
                && components[2] > 0.3 && components[2] < 0.7    // Moderate blue
        }

        let hasOrange = colors.contains { color in
            guard let components = color.components else {
                return false
            }
            return components[0] > 0.8    // High red
                && components[1] > 0.3 && components[1] < 0.7    // Moderate green
                && components[2] < 0.2    // Low blue
        }

        #expect(hasPurple, "Does not detect purple border color")
        #expect(hasOrange, "Does not detect orange center color")
    }


    @Test
    func testNoisyImage() throws {
        let image = try loadTestPNG("Noisy-Red-Blue")
        let result = try #require(image.mostCommonColors(count: 2))

        #expect(result.count == 2)

        // Algorithm clusters red+blue base into purple/magenta, noise into separate cluster
        let hasPurplish = result.contains { (color, weight) in
            guard let components = color.components else {
                return false
            }
            // Purple with high weight
            return components[0] > 0.6 && components[2] > 0.6 && components[1] < 0.2 && weight > 0.9
        }

        let hasNoiseColor = result.contains { (color, weight) in
            guard let components = color.components else {
                return false
            }
            // High green component with low weight
            return components[1] > 0.8 && weight < 0.1
        }

        #expect(hasPurplish, "Does not detect purple cluster from red+blue base")
        #expect(hasNoiseColor, "Does not detect noise cluster with small weight")
    }


    @Test
    func testCheckerboardPattern() throws {
        let image = try loadTestPNG("Checkerboard")
        let result = try #require(image.mostCommonColors(count: 4))

        #expect(result.count == 4)

        // Should detect primary colors with roughly balanced weights
        let totalWeight = result.map(\.weight).reduce(0, +)
        #expect(totalWeight.isApproximatelyEqual(to: 1.0, absoluteTolerance: 0.05))

        // Each meaningful color should have reasonable weight (at least 15%)
        for (_, weight) in result where weight > 0 {
            #expect(weight > 0.15, "Each color does not have a meaningful representation")
        }
    }


    @Test
    func testGradientImage() throws {
        let image = try loadTestPNG("Gradient-Red-Blue")

        let result = try #require(image.mostCommonColors(count: 3))
        #expect(result.count == 3)

        // Should find colors along the red-blue spectrum
        let colors = result.map(\.color)

        // Check that we have colors spanning the red-blue range
        let redValues = colors.compactMap { $0.components?[0] }
        let blueValues = colors.compactMap { $0.components?[2] }

        let minRed = redValues.min() ?? 0
        let maxRed = redValues.max() ?? 0
        let minBlue = blueValues.min() ?? 0
        let maxBlue = blueValues.max() ?? 0

        #expect(maxRed - minRed > 0.5, "Does not span significant red range")
        #expect(maxBlue - minBlue > 0.5, "Does not span significant blue range")
    }


    @Test
    func testDifferentColorCounts() throws {
        let image = try loadTestPNG("Red-Shades")

        let result2 = try #require(image.mostCommonColors(count: 2))
        let result3 = try #require(image.mostCommonColors(count: 3))

        #expect(result2.count == 2)
        #expect(result3.count == 3)

        // First color in both should be similar (most dominant)
        expectEqualColors(result2[0].color, result3[0].color, tolerance: 0.1)
    }


    @Test(arguments: [1, 5, 10, 20])
    func testDifferentPassCounts(passes: Int) throws {
        let image = try loadTestPNG("Red-Shades")

        let result = try #require(image.mostCommonColors(count: 3, passes: passes))

        #expect(result.count == 3)

        let totalWeight = result.map(\.weight).reduce(0, +)
        #expect(totalWeight.isApproximatelyEqual(to: 1.0, absoluteTolerance: 0.05))

        for i in 1 ..< result.count {
            #expect(result[i - 1].weight >= result[i].weight, "Results are not ordered by descending weight")
        }
    }


    private func loadTestPNG(_ filename: String) throws -> CGImage {
        let url = try #require(Bundle.module.url(forResource: filename, withExtension: "png"))
        let imageSource = try #require(CGImageSourceCreateWithURL(url as CFURL, nil))
        return try #require(CGImageSourceCreateImageAtIndex(imageSource, 0, nil))
    }


    private func expectEqualColors(
        _ actual: CGColor,
        _ expected: CGColor,
        tolerance: CGFloat = 0.01,
        fileID: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column
    ) {
        let sourceLocation = SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column)

        guard
            let actualComponents = actual.components,
            let expectedComponents = expected.components
        else {
            Issue.record("Did not get color components", sourceLocation: sourceLocation)
            return
        }

        for (actualComponent, expectedComponent) in zip(actualComponents, expectedComponents) {
            #expect(
                actualComponent.isApproximatelyEqual(to: expectedComponent, absoluteTolerance: tolerance),
                "Color component \(actualComponent) not within tolerance \(tolerance) of \(expectedComponent)",
                sourceLocation: sourceLocation
            )
        }
    }
}
