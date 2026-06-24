//
//  File.swift
//  SwiftRL
//
//  Created by SJ Basak on 23/06/26.
//

import Foundation


@available(macOS 15.0, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public struct TokenBucket {
    private let maxSize         : Int
    private var currentSize     : Int
    private let insertDuration  : Duration
    private var lastRefill      : ContinuousClock.Instant
    
    /// Initialisation
    /// - Parameters:
    ///   - maxSize: The maximum amount of token the bucket is able to hold
    ///   - insertDuration: How often one token should get added to the bucket
    public init(maxSize: Int, insertDuration: Duration) {
        self.maxSize         = maxSize
        self.currentSize     = maxSize
        self.insertDuration  = insertDuration
        self.lastRefill      = .now
    }
    
    /// Try Consuming token
    mutating public func consume() throws(RLError) {
        _ = try? refill()
        guard currentSize > 0 else { throw .limitExceeded }
        currentSize -= 1
    }
    
    /// ## Refilling Algorithm
    /// - Calculate elapsed time
    /// - Calculate how many token could have been added during this time
    /// - Making sure it doesn't overflows
    /// - Eg.
    ///     - A token is to be added for each 5 sec, bucket volume is 10
    ///     - Token quantity in bucket after last consumption is 5
    ///     - So after 6 seconds from last consumption current token quantity should be 6
    ///     - With 1 second in hand
    ///     - But on if the bucket gets filled up to max then time in hand should be ignored, and calculation will start from later consumptions
    @discardableResult
    mutating private func refill() throws(RFError) -> Bool {
        let elapsedTime   = lastRefill.duration(to: .now)
        guard elapsedTime > insertDuration else { throw .refillConditionMismatch }
        
        let tokensToBeAdded = Int(elapsedTime / insertDuration)
        currentSize         = min(maxSize, currentSize+tokensToBeAdded)
        
        if currentSize < maxSize {
            let tokensCost  = insertDuration * Double(tokensToBeAdded)
            lastRefill      = lastRefill.advanced(by: tokensCost)
        } else {
            lastRefill      = .now
        }
        
        return true
    }
}
