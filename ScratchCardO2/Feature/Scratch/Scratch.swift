import ComposableArchitecture

@Reducer
struct Scratch {

	@ObservableState
	struct State: Equatable {
		var scratchCard: ScratchCard
		var isLoading: Bool
		let delayInSeconds: Int

		init(
			scratchCard: ScratchCard,
			isLoading: Bool = false,
			delayInSeconds: Int = 2
		) {
			self.scratchCard = scratchCard
			self.isLoading = isLoading
			self.delayInSeconds = delayInSeconds
		}
	}

	enum Action: Equatable, ViewAction {
		case didReveal
		case view(View)
		case delegate(Delegate)

		public enum View: Equatable {
			case scratch
		}

		public enum Delegate: Equatable {
			case didReveal(ScratchCard)
		}
	}

	enum CancellableId: String {
		case scratch
	}

	@Dependency(\.continuousClock)
	private var continuousClock

	var body: some Reducer<State, Action> {
		Reduce { state, action in
			switch action {
			case .view(.scratch):
				guard state.scratchCard.state == .unscratched else {
					return .none
				}
				state.isLoading = true
				return scratch(delayInSeconds: state.delayInSeconds)

			case .didReveal:
				state.isLoading = false
				state.scratchCard.state = .scratched
				return .send(.delegate(.didReveal(state.scratchCard)))

			case .delegate:
				return .none
			}
		}
	}

	private func scratch(delayInSeconds: Int) -> Effect<Action> {
		.run { send in
			await withTaskCancellation(id: CancellableId.scratch, cancelInFlight: true) {
				try? await continuousClock.sleep(for: .seconds(delayInSeconds))
				await send(.didReveal)
			}
		}
	}
}
