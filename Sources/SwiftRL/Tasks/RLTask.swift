//
//  File.swift
//  SwiftRL
//
//  Created by Cepheus on 28/06/26.
//

import Foundation


/// An actor that manages the execution of tasks while enforcing rate limiting constraints.
///
/// `RLExecutor` uses an algorithm to ensure that tasks are performed in accordance
/// with specified rate limits, preventing system overload or resource exhaustion.
///
/// It provides methods to execute both asynchronous and synchronous tasks, ensuring that
/// the rate limiter's capacity is consumed before the task proceeds.
///
/// ## Usage
/// ```swift
/// func purchaseButtonTapped() {
/// 	Task {
/// 		do {
/// 			try await purchaseLimiter.perform {
/// 				try await paymentService.purchase()
/// 			}
///	 		} catch {
/// 			showAlert(error)
/// 		}
/// 	}
/// }
/// ```
public actor RLExecutor {
	private var rateLimiter: any RLAlgo
	
	public init(rateLimiter: any RLAlgo) {
		self.rateLimiter = rateLimiter
	}
	
	/// Executes a task after ensuring the rate limiter has sufficient capacity.
	///
	/// This method checks for task cancellation before attempting to consume capacity from the rate limiter.
	/// If the rate limiter's capacity is exhausted, it will throw an error.
	///
	/// - Parameter task: A sendable closure that performs the work to be executed.
	/// - Returns: The result of the executed task.
	/// - Throws: An error if the rate limiter cannot consume capacity, if the task itself throws, or if the task is cancelled.
	public func perform<T>(
		task: @Sendable () async throws -> T
	) async throws -> T {
		try Task.checkCancellation()
		
		try self.rateLimiter.consume()
		
		return try await task()
	}
	
	/// Executes a synchronous task after ensuring the rate limiter has sufficient capacity.
	///
	/// This method checks for capacity from the rate limiter before the task proceeds.
	///
	/// - Parameter task: A sendable closure that performs the work to be executed.
	/// - Returns: The result of the executed task.
	/// - Throws: An error if the rate limiter cannot consume capacity, or if the task itself throws.
	public func perform<T>(
		task: @Sendable () throws -> T
	) throws -> T {
		try self.rateLimiter.consume()
		
		return try task()
	}
}
