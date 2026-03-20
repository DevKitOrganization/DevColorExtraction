# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this
repository.


## Development Commands

### Building and Testing

  - **Build**: `swift build`
  - **Test all**: `swift test`
  - **Test specific target**: `swift test --filter DevColorExtractionTests`

### Code Quality

  - **Lint**: `Scripts/lint` (uses `swift format lint --recursive --strict`)
  - **Format**: `Scripts/format` (uses `swift format --in-place`)

### GitHub Actions

The repository uses GitHub Actions for CI/CD with the workflow in
`.github/workflows/VerifyChanges.yaml`. The workflow:

  - Lints code on PRs using `swift format`
  - Builds and tests on iOS, macOS, and tvOS
  - Generates code coverage reports using xccovPretty
  - Uses Xcode 26.3 and macOS 26 runners


## Architecture Overview

DevColorExtraction is a Swift package that extracts the most common colors from images using
k-means clustering. It provides efficient color analysis with support for edge-based extraction.

### Source Structure

    Sources/DevColorExtraction/
    ├── MostCommonColors.swift   # Core color extraction via CGImage extensions
    ├── EdgeSet.swift            # Edge set type for edge-based extraction
    └── Documentation.docc/      # DocC documentation

### Key APIs

  - `CGImage.mostCommonColors(count:passes:)` — extract most common colors from an image
  - `CGImage.mostCommonColors(count:passes:edges:)` — extract colors from specific edges
  - `EdgeSet` — option set for specifying image edges (top, left, bottom, right)


## Dependencies

External dependencies managed via Swift Package Manager:

  - **swift-numerics**: Numeric utilities (RealModule, used in tests)


## Testing

The codebase maintains >97% test coverage. Tests are in `Tests/DevColorExtractionTests/` with
test image resources in `Tests/DevColorExtractionTests/Resources/`.


## Platform Support

  - iOS 18+
  - macOS 15+
  - tvOS 18+


## Code Formatting and Spacing

The project follows strict spacing conventions for readability and consistency:

  - **2 blank lines between major sections** including:
    - Between the last property declaration and first function declaration
    - Between all function/computed property implementations at the same scope level
    - Between top-level type declarations (class, struct, enum, protocol, extension)
    - Before MARK comments that separate major sections
  - **1 blank line** for minor separations:
    - Between property declarations and nested type definitions
    - Between all function definitions in protocols
    - After headers in documentation
    - After MARK comments that separate major sections
  - **File endings**: All Swift files must end with exactly one blank line


## Documentation Style

When writing Markdown documentation, reference `@Documentation/MarkdownStyleGuide.md` to
ensure consistent formatting, structure, and style across all project documentation. Key
standards:

  - **Line Length**: 100 characters maximum
  - **Code Blocks**: Use 4-space indentation instead of fenced blocks
  - **Lists**: Use `-` for bullets with proper indentation alignment
  - **Spacing**: 2 blank lines between major sections, 1 blank line after headers
  - **Terminology**: Use "function" over "method", "type" over "class"


## Development Notes

  - Follows Swift API Design Guidelines
  - Uses Swift 6.2 with `ExistentialAny` and `MemberImportVisibility` features enabled
  - All public APIs are documented and tested
  - Test coverage target: >97%
