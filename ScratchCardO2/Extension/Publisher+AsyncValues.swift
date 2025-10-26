import Combine
import ComposableArchitecture

extension Publisher {

	// https://forums.swift.org/t/asyncpublisher-causes-crash-in-rather-simple-situation/56574
	func asyncValues(_ size: Int = 1) -> AsyncStream<Output> {
		buffer(size: size, prefetch: .byRequest, whenFull: .dropOldest)
			.values
			.eraseToStream()
	}
}
