import ComposableArchitecture
import Dependencies

@Reducer
struct Activation {

	@ObservableState
	struct State: Equatable {
		var scratchCard: ScratchCard
		var isLoading: Bool
		let minimumVersion: Double
		@Presents
		var alert: AlertState<Alert>?

		init(
			scratchCard: ScratchCard,
			isLoading: Bool = false,
			minimumVersion: Double = 6.1,
			alert: AlertState<Alert>? = nil
		) {
			self.scratchCard = scratchCard
			self.isLoading = isLoading
			self.minimumVersion = minimumVersion
			self.alert = alert
		}
	}

	enum Action: Equatable, ViewAction {
		case didActivate
		case error(String)
		case alert(PresentationAction<Alert>)
		case view(View)
		case delegate(Delegate)

		public enum View: Equatable {
			case activate
		}

		public enum Delegate: Equatable {
			case didActivate(ScratchCard)
		}
	}

	@CasePathable
	enum Alert: Equatable {}

	@Dependency(\.service)
	private var service

	@Dependency(\.notificatingCenter)
	var notificationCenter

	var body: some Reducer<State, Action> {
		Reduce { state, action in
			switch action {
			case .view(.activate):
				state.isLoading = true
				return activate(code: state.scratchCard.id, minimumVersion: state.minimumVersion)

			case .didActivate:
				state.isLoading = false
				state.scratchCard.state = .activated
				return .send(.delegate(.didActivate(state.scratchCard)))

			case let .error(error):
				state.isLoading = false
				state.createAlert(title: "Error :-(", message: error, buttonTitle: "OK")
				return .none

			case .alert:
				return .none

			case .delegate:
				return .none
			}
		}
		.ifLet(\.$alert, action: \.alert)
	}

	private func activate(code: String, minimumVersion: Double) -> Effect<Action> {
		.run { send in
			do {
				let didActivate = try await activateDetached(code: code, minimumVersion: minimumVersion)
				if didActivate {
					await send(.didActivate)
				} else {
					await send(.error("Activation failed"))
				}
			} catch let error as AlertableError {
				await send(.error(error.message))
			} catch {
				await send(.error("Unknown error"))
			}
		}
	}

	private func activateDetached(code: String, minimumVersion: Double) async throws -> Bool {
		try await Task.detached {
			let activationResult = try await service.activate(code: code)

			guard let iosVersion = Double(activationResult.ios) else {
				throw AlertError("Invalid iOS version format")
			}
			guard iosVersion > minimumVersion else {
				throw AlertError("iOS ≤ \(minimumVersion)")
			}

			await notificationCenter.post(.scratchCardDidActivate, nil, nil)
			return true
		}.value
	}
}

extension Activation.State {

	mutating func createAlert(
		title: String,
		message: String,
		buttonTitle: String,
	) {
		alert = AlertState {
			TextState(title)
		} actions: {
			ButtonState {
				TextState(buttonTitle)
			}
		} message: {
			TextState(message)
		}
	}

}

