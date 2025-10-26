import ComposableArchitecture
import Foundation
import Testing

@testable import ScratchCardO2

@MainActor
class ActivationTests {

	private let minimumVersion = 1.0
	private var postedNotificationName: Notification.Name?

	@Test
	func activate() async {
		await withDependencies {
			$0.service = ServiceMock { _ in
				ActivationResponse(ios: "1.1")
			}
		} operation: {
			var scratchCard: ScratchCard = .init(state: .scratched)
			let store = createStore(scratchCard: scratchCard)

			await store.send(.view(.activate)) {
				$0.isLoading = true
			}

			await store.receive(.didActivate) {
				$0.isLoading = false
				$0.scratchCard.state = .activated
			}

			scratchCard.state = .activated
			await store.receive(.delegate(.didActivate(scratchCard)))

			#expect(postedNotificationName == .scratchCardDidActivate)
		}
	}

	@Test
	func activateErrorVersionFormat() async {
		await withDependencies {
			$0.service = ServiceMock { _ in
				ActivationResponse(ios: "asdf")
			}
		} operation: {
			let store = createStore(scratchCard: .init(state: .scratched))

			await store.send(.view(.activate)) {
				$0.isLoading = true
			}

			await store.receive(.error("Invalid iOS version format")) {
				$0.isLoading = false
				$0.alert = self.createAlertState(message: "Invalid iOS version format")
			}

			#expect(postedNotificationName == nil)
		}
	}

	@Test
	func activateErrorMinimumVersion() async {
		await withDependencies {
			$0.service = ServiceMock { _ in
				ActivationResponse(ios: "0.9")
			}
		} operation: {
			let store = createStore(scratchCard: .init(state: .scratched))

			await store.send(.view(.activate)) {
				$0.isLoading = true
			}

			await store.receive(.error("iOS ≤ \(self.minimumVersion)")) {
				$0.isLoading = false
				$0.alert = self.createAlertState(message: "iOS ≤ \(self.minimumVersion)")
			}

			#expect(postedNotificationName == nil)
		}
	}

	@Test
	func activateErrorOther() async {
		await withDependencies {
			$0.service = ServiceMock { _ in
				throw NSError(domain: "Test", code: 0)
			}
		} operation: {
			let store = createStore(scratchCard: .init(state: .scratched))

			await store.send(.view(.activate)) {
				$0.isLoading = true
			}

			await store.receive(.error("Unknown error")) {
				$0.isLoading = false
				$0.alert = self.createAlertState(message: "Unknown error")
			}

			#expect(postedNotificationName == nil)
		}
	}

	private func createStore(scratchCard: ScratchCard) -> TestStoreOf<Activation> {
		.init(
			initialState: .init(scratchCard: scratchCard, minimumVersion: minimumVersion),
			reducer: { Activation() }
		) {
			$0.notificatingCenter = .init(
				publisher: { name, object in
					NotificationCenter.default.publisher(for: name, object: object)
				},
				post: { name, object, userInfo in
					self.postedNotificationName = name
				}
			)
		}
	}

	private func createAlertState(message: String) -> AlertState<Activation.Alert> {
		AlertState {
			TextState("Error :-(")
		} actions: {
			ButtonState {
				TextState("OK")
			}
		} message: {
			TextState(message)
		}
	}
}
