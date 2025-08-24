//
//  EdgeSetTests.swift
//  DevColorExtraction
//
//  Created by Prachi Gauriar on 8/23/25.
//

import DevColorExtraction
import Foundation
import Testing

struct EdgeSetTests {
    @Test
    func distinctValues() {
        #expect(EdgeSet.top != EdgeSet.right)
        #expect(EdgeSet.top != EdgeSet.bottom)
        #expect(EdgeSet.top != EdgeSet.left)

        #expect(EdgeSet.right != EdgeSet.bottom)
        #expect(EdgeSet.right != EdgeSet.left)

        #expect(EdgeSet.bottom != EdgeSet.left)
    }


    @Test
    func compositeEdges() {
        #expect(!EdgeSet.none.contains(.top))
        #expect(!EdgeSet.none.contains(.right))
        #expect(!EdgeSet.none.contains(.bottom))
        #expect(!EdgeSet.none.contains(.left))

        #expect(EdgeSet.vertical.contains(.top))
        #expect(EdgeSet.vertical.contains(.bottom))
        #expect(!EdgeSet.vertical.contains(.right))
        #expect(!EdgeSet.vertical.contains(.left))

        #expect(EdgeSet.horizontal.contains(.right))
        #expect(EdgeSet.horizontal.contains(.left))
        #expect(!EdgeSet.horizontal.contains(.top))
        #expect(!EdgeSet.horizontal.contains(.bottom))

        #expect(EdgeSet.all.contains(.top))
        #expect(EdgeSet.all.contains(.right))
        #expect(EdgeSet.all.contains(.bottom))
        #expect(EdgeSet.all.contains(.left))
    }
}
