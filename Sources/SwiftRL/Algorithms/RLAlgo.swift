import Foundation


public protocol RLAlgo: Sendable {
    mutating func consume() throws(RLError)
}
