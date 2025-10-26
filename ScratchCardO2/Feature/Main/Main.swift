import ComposableArchitecture

@Reducer
struct Main {

	@ObservableState
	struct State: Equatable {
		var scratchCard: ScratchCard
	}

	enum Action: Equatable, ViewAction {
		case delegate(Delegate)
		case view(View)
		case activate

		public enum View: Equatable {
			case start
			case scratch
			case activate
			case reset
		}
	}

	enum Delegate: Equatable {
		case scratch
		case activate
	}

	enum CancellableId: String {
		case notificationCenter
	}

	@Dependency(\.notificatingCenter)
	var notificationCenter

	var body: some Reducer<State, Action> {
		Reduce { state, action in
			switch action {

			case .view(.start):
				return .run { send in
					await withTaskCancellation(
						id: CancellableId.notificationCenter,
						cancelInFlight: true
					) {
						for await _ in await notificationCenter.publisher(.scratchCardDidActivate, nil).asyncValues() {
							await send(.activate)
						}
					}
				}

			case .view(.scratch):
				return .send(.delegate(.scratch))

			case .view(.activate):
				return .send(.delegate(.activate))

			case .view(.reset):
				state.scratchCard.state = .unscratched
				return .none

			case .delegate:
				return .none

			case .activate:
				state.scratchCard.state = .activated
				return .none
			}
		}
	}
}
