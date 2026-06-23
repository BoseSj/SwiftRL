# SwiftRL

SwiftRL is a lightweight Swift package for rate limiting using the Token Bucket algorithm. It is designed to be simple, easy to integrate, and extensible for future rate limiting strategies.

## Features

- Token Bucket rate limiting implementation
- Minimal API surface for easy integration
- Works on Apple platforms that support Swift `Duration`
- MIT licensed

## Status

This project currently implements a general-purpose `TokenBucket` rate limiter. Additional algorithms and higher-level task wrappers may be added in future releases.

## Installation

This package is built using Swift Package Manager. Add the package dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/BoseSj/SwiftRL.git", from: "0.1.0"),
],
```

Then add the package target to your executable or library target dependencies.

## Usage

The current implementation exposes a `TokenBucket` struct.

```swift
import SwiftRL

var bucket = TokenBucket(maxSize: 10, insertDuration: .seconds(5))

for _ in 0..<20 {
    do {
        try bucket.consume()
        print("Allowed")
    } catch {
        print("Rate limit exceeded")
    }
}
```

### Behavior

- The bucket starts full with `maxSize` tokens.
- Each `consume()` call uses a single token.
- If no tokens remain, `consume()` throws `RLError.limitExceeded`.
- Tokens are refilled automatically over time using the configured `insertDuration`.

## Algorithm

The Token Bucket algorithm is implemented in `TokenBucket.swift` and works as follows:

1. Track the maximum bucket capacity (`maxSize`), current token count (`currentSize`), refill interval (`insertDuration`), and the last refill instant (`lastRefill`).
2. On each `consume()` call:
   - Attempt to refill the bucket depending on elapsed time.
   - If there is at least one token available, decrement `currentSize` and allow the request.
   - If the bucket is empty, throw `.limitExceeded`.
3. Refill logic:
   - Calculate elapsed time since `lastRefill`.
   - Determine how many tokens should be added: `Int(elapsedTime / insertDuration)`.
   - Add tokens, but never exceed `maxSize`.
   - If the bucket is still not full after refilling, advance `lastRefill` by the time used to generate the newly added tokens.
   - If the bucket becomes full, reset `lastRefill` to `now` so the refill cycle starts fresh after the bucket is full.

This implementation ensures the bucket accumulates tokens gradually over time while enforcing the configured maximum burst capacity.

## API

Current public API:

- `TokenBucket(maxSize:insertDuration:)`
- `mutating func consume() throws`

Error types:

- `RLError.limitExceeded`
- `RLError.refillError(RFError)`
- `RFError.refillConditionMismatch`

## License

This repository is licensed under the MIT License. See the `LICENSE` file for details.
