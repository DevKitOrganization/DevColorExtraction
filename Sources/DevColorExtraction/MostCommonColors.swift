//
//  MostCommonColors.swift
//  DevColorExtraction
//
//  Created by Prachi Gauriar on 8/20/25.
//

import CoreGraphics
import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation

extension CGImage {
    /// Applies the k-means algorithm to find the most common colors in the image.
    ///
    /// - Parameters:
    ///   - count: The number of colors to return.
    ///   - passes: The number of k-means passes that should run. Maximum is 20, and default is 5.
    ///   - edges: The edges of the image from which to get pixel data. If ``EdgeSet/none``, the entire image is used.
    /// - Returns: An array of colors and their associated weights in order of descending weight. Returns `nil` if the
    ///   colors could not be found.
    public func mostCommonColors(
        count: Int,
        passes: Int = 5,
        edges: EdgeSet = .none
    ) -> [(color: CGColor, weight: CGFloat)]? {
        // Create a CIImage from which to extract the most common colors
        let ciImage: CIImage
        switch edges {
        case .none, .top, .left, .bottom, .right:
            // We can easily represent the edge pixels using an extent, so we use the whole image and set an extent
            // below
            ciImage = CIImage(cgImage: self)
        default:
            // We can’t just create an extent, so we need to create a new image that contains only pixels from the
            // relevant edges
            guard let edgeImage = edgePixelImage(for: edges) else {
                return nil
            }
            ciImage = CIImage(cgImage: edgeImage)
        }

        // Create an extent that defines how much of the image we’ll evaluate. This will be the whole image unless the
        // edge set contains a single edge
        var extent = ciImage.extent
        if edges == .top {
            extent.origin.y = extent.size.height - 1
            extent.size.height = 1
        } else if edges == .left {
            extent.size.width = 1
        } else if edges == .bottom {
            extent.size.height = 1
        } else if edges == .right {
            extent.origin.x = extent.size.width - 1
            extent.size.width = 1
        }

        return ciImage.mostCommonColors(count: count, extent: extent, passes: passes)
    }


    /// Returns a new image composed of pixels from the specified edges of this one.
    ///
    /// - Parameter edges: The edges from which to get pixels.
    /// - Returns: An image containing this image’s edge pixels. Returns `nil` if the image data could not be generated.
    private func edgePixelImage(for edges: EdgeSet) -> CGImage? {
        // Render this image to a bitmap
        guard let context = CGContext.makeRGBContext(width: width, height: height) else {
            return nil
        }

        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let bitmap = context.data?.assumingMemoryBound(to: UInt8.self) else {
            return nil
        }

        var edgePixels: [UInt8] = []
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel

        // Get pixels from the horizontal (top and bottom) edges
        for (edge, row) in [(EdgeSet.top, 0), (.bottom, height - 1)] where edges.contains(edge) {
            let rowData = (0 ..< width).flatMap { x in
                (0 ..< bytesPerPixel).map { component in
                    bitmap[row * bytesPerRow + x * bytesPerPixel + component]
                }
            }
            edgePixels.append(contentsOf: rowData)
        }

        // Get pixels from the vertical (left and right) edges
        for (edge, column) in [(EdgeSet.left, 0), (.right, width - 1)] where edges.contains(edge) {
            let columnData = (0 ..< height).flatMap { y in
                (0 ..< bytesPerPixel).map { component in
                    bitmap[y * bytesPerRow + column * bytesPerPixel + component]
                }
            }
            edgePixels.append(contentsOf: columnData)
        }

        // Write our edge pixels to a new graphics context and render an image
        guard
            !edgePixels.isEmpty,
            let edgeContext = CGContext.makeRGBContext(width: edgePixels.count / bytesPerPixel, height: 1),
            let edgeData = edgeContext.data
        else {
            return nil
        }

        edgeData.copyMemory(from: edgePixels, byteCount: edgePixels.count)
        return edgeContext.makeImage()
    }
}


extension CGContext {
    /// Creates a new RGB context with the specified width and height.
    ///
    /// - Parameters:
    ///   - width: The width of the context.
    ///   - height: The height of the context.
    /// - Returns: The new context, or `nil` if it could not be created.
    fileprivate static func makeRGBContext(width: Int, height: Int) -> CGContext? {
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
}


extension CIImage {
    /// Applies the k-means algorithm to find the most common colors in the image.
    ///
    /// This function uses the `kMeans` `CIFilter` for its implementation.
    ///
    /// - Parameters:
    ///   - count: The number of colors to return.
    ///   - extent: The extent of the image to use when
    ///   - passes: The number of k-means passes that should run. Maximum is 20, and default is 5.
    /// - Returns: An array of colors and their associated weights in order of descending weight. Returns `nil` if the
    ///   colors could not be found.
    fileprivate func mostCommonColors(
        count: Int,
        extent: CGRect,
        passes: Int
    ) -> [(color: CGColor, weight: CGFloat)]? {
        // Run the k-means filter.
        let filter = CIFilter.kMeans()
        filter.inputImage = self
        filter.extent = extent
        filter.count = count
        filter.passes = Float32(passes)

        guard let outputImage = filter.outputImage else {
            return nil
        }

        // The k-means filter produces an image whose pixels are the most common colors, but their alpha channels are
        // the weights of the images. We need to use settingAlphaOne(in:) to get the true color values.
        let alphaOneImage = outputImage.settingAlphaOne(in: outputImage.extent)

        // Get the colors from the alpha one image and the weights from the original output image.
        let colors = alphaOneImage.colorsAndWeights().map(\.color)
        let weights = outputImage.colorsAndWeights().map(\.weight)

        // Put together the colors and weights and sort in order of descending weight
        return zip(colors, weights).map { (color: $0, weight: $1) }.sorted { $0.weight > $1.weight }
    }


    /// Returns the colors and weights for the pixels in the image.
    private func colorsAndWeights() -> [(color: CGColor, weight: Float64)] {
        let count = Int(extent.width)

        // Allocate a bitmap for the image’s pixels
        let bitmapSize = count * 4
        let bitmap = UnsafeMutableRawPointer.allocate(
            byteCount: bitmapSize,
            alignment: MemoryLayout<UInt8>.alignment
        )
        defer { bitmap.deallocate() }

        // Render the image into the bitmap
        let ciContext = CIContext()
        ciContext.render(
            self,
            toBitmap: bitmap,
            rowBytes: bitmapSize,
            bounds: CGRect(x: 0, y: 0, width: count, height: 1),
            format: .RGBA8,
            colorSpace: CGColorSpace(name: CGColorSpace.sRGB)
        )

        // Extract the RGBA values, with weight corresponding to the alpha value.
        let rgbaBuffer = bitmap.assumingMemoryBound(to: UInt8.self)
        return (0 ..< count).map { (i) in
            (
                CGColor(
                    srgbRed: CGFloat(rgbaBuffer[4 * i + 0]) / 255.0,
                    green: CGFloat(rgbaBuffer[4 * i + 1]) / 255.0,
                    blue: CGFloat(rgbaBuffer[4 * i + 2]) / 255.0,
                    alpha: 1.0
                ),
                weight: CGFloat(rgbaBuffer[4 * i + 3]) / 255.0
            )
        }
    }
}
