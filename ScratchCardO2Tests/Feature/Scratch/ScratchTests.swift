import ComposableArchitecture
import Testing

@testable import ScratchCardO2

@MainActor
struct ScratchTests {

	private let delay: Int = 2
	private let clock: TestClock = .init()

	@Test
	func scratchUnscratched() async {
		var scratchCard: ScratchCard = .init(state: .unscratched)
		let store = createStore(scratchCard: scratchCard)

		await store.send(.view(.scratch)) {
			$0.isLoading = true
		}

		await clock.advance(by: .seconds(delay))

		await store.receive(.didReveal) {
			$0.isLoading = false
			$0.scratchCard.state = .scratched
		}

		scratchCard.state = .scratched
		await store.receive(.delegate(.didReveal(scratchCard)))
	}

	@Test
	func scratchScratched() async {
		let store = createStore(scratchCard: .init(state: .scratched))

		await store.send(.view(.scratch))
	}

	@Test
	func scratchActivated() async {
		let store = createStore(scratchCard: .init(state: .activated))

		await store.send(.view(.scratch))
	}

	private func createStore(scratchCard: ScratchCard) -> TestStoreOf<Scratch> {
		.init(
			initialState: .init(scratchCard: scratchCard, delayInSeconds: delay),
			reducer: { Scratch() }
		) {
			$0.continuousClock = clock
		}
	}
}
