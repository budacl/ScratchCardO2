import ComposableArchitecture
import Foundation
import Testing

@testable import ScratchCardO2

@MainActor
class MainTests {

	private let notificationCenter = NotificationCenter()

	@Test
	func start() async {
		let store = createStore(scratchCard: .init(state: .unscratched))

		await store.send(.view(.start))

		notificationCenter.post(name: .scratchCardDidActivate, object: nil)

		await store.receive(.activate) {
			$0.scratchCard.state = .activated
		}

		Task.cancel(id: Main.CancellableId.notificationCenter)

		await store.finish()
	}

	@Test
	func viewScratch() async {
		let store = createStore(scratchCard: .init(state: .unscratched))

		await store.send(.view(.scratch))
		await store.receive(.delegate(.scratch))
	}

	@Test
	func viewActivate() async {
		let store = createStore(scratchCard: .init(state: .unscratched))

		await store.send(.view(.activate))
		await store.receive(.delegate(.activate))
	}

	@Test
	func viewReset() async {
		let store = createStore(scratchCard: .init(state: .scratched))

		await store.send(.view(.reset)) {
			$0.scratchCard.state = .unscratched
		}
	}

	@Test
	func activate() async {
		let store = createStore(scratchCard: .init(state: .unscratched))

		await store.send(.activate) {
			$0.scratchCard.state = .activated
		}
	}

	private func createStore(scratchCard: ScratchCard) -> TestStoreOf<Main> {
		.init(
			initialState: .init(scratchCard: scratchCard),
			reducer: { Main() }
		) {
			$0.notificatingCenter = .init(
				publisher: { name, object in
					self.notificationCenter.publisher(for: name, object: object)
				},
				post: { _, _, _ in }
			)
		}
	}
}
