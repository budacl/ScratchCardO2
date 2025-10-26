import ComposableArchitecture

@Reducer
struct AppReducer: Reducer {
	@ObservableState
	struct State {
		var path = StackState<Path.State>()
		var main: Main.State = .init(scratchCard: .init(state: .unscratched))
	}

	enum Action {
		case main(Main.Action)
		case path(StackActionOf<Path>)
	}

	@Reducer
	enum Path {
		case activation(Activation)
		case scratch(Scratch)
	}

	var body: some Reducer<State, Action> {
		Scope(state: \.main, action: \.main) {
			Main()
		}

		Reduce { state, action in
			switch action {

			case .main(.delegate(.scratch)):
				state.path.append(.scratch(.init(scratchCard: state.main.scratchCard)))
				return .none

			case .main(.delegate(.activate)):
				state.path.append(.activation(.init(scratchCard: state.main.scratchCard)))
				return .none

			case .main:
				return .none

			case let .path(.element(_, .scratch(.delegate(.didReveal(scratchCard))))):
				state.main.scratchCard = scratchCard
				return .none

			case let .path(.element(_, .activation(.delegate(.didActivate(scratchCard))))):
				state.main.scratchCard = scratchCard
				return .none

			case .path:
				return .none
			}
		}
		.forEach(\.path, action: \.path)
	}
}
