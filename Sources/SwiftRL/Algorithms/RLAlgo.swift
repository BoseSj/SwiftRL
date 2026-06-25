import Foundation


public protocol RLAlgo {
    mutating func consume() throws(RLError)
}