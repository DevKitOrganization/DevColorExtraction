# DevColorExtraction

DevColorExtraction is a Swift package that extracts the most common colors from images using
k-means clustering. It provides efficient color analysis with support for edge-based extraction and
is fully documented and tested. It supports iOS 18+, macOS 15+, and tvOS 18+.

View our [changelog](CHANGELOG.md) to see what’s new.


## Features

  - Extract the most common colors from `CGImage` using Core Image’s k-means clustering
  - Support for edge-based color extraction (top, left, bottom, right edges)
  - Configurable number of colors and clustering passes
  - Results include both colors and their relative weights
  - Comprehensive test suite with various image scenarios


## Usage

    import DevColorExtraction

    // Extract the 3 most common colors from an entire image
    let colors = cgImage.mostCommonColors(count: 3)

    // Extract colors from specific edges only
    let edgeColors = cgImage.mostCommonColors(count: 2, edges: [.top, .bottom])

    // Customize k-means parameters
    let preciseColors = cgImage.mostCommonColors(count: 5, passes: 10)


## Development Requirements

DevColorExtraction requires a Swift 6.2+ toolchain to build. We only test on Apple platforms. We follow
the [Swift API Design Guidelines][SwiftAPIDesignGuidelines]. We take pride in the fact that our
public interfaces are fully documented and tested. We aim for overall test coverage over 97%.

[SwiftAPIDesignGuidelines]: https://swift.org/documentation/api-design-guidelines/

### Development Setup

To set up the development environment:

  1. Run `Scripts/install-git-hooks` to install git hooks that automatically check code
     formatting on commits and run comprehensive tests before pushing.
  2. Use `Scripts/lint` to manually check code formatting at any time.
  3. Use `Scripts/test-all-platforms` to run tests on all supported platforms locally.


## Continuous Integration

DevColorExtraction uses GitHub Actions for continuous integration. The CI pipeline:

  - **Linting**: Automatically checks code formatting on all pull requests using `swift format`
  - **Testing**: Runs tests on macOS (iOS and tvOS testing are disabled in CI due to reliability
    issues)
  - **Coverage**: Generates code coverage reports using xccovPretty

For comprehensive cross-platform testing, developers should run `Scripts/test-all-platforms`
locally or rely on the pre-push git hook which automatically runs all platform tests before
pushing changes.


## Bugs and Feature Requests

Find a bug? Want a new feature? Create a GitHub issue and we’ll take a look.


## License

All code is licensed under the MIT license. Do with it as you will.
