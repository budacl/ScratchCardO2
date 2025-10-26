import ComposableArchitecture
import SwiftUI

struct AppView: View {

	@Bindable
	private var store: StoreOf<AppReducer>

	var body: some View {
		NavigationStack(
			path: $store.scope(state: \.path, action: \.path),
			root: root,
			destination: destination(for:)
		)
	}

	init(store: StoreOf<AppReducer>) {
		self.store = store
	}

	@ViewBuilder
	private func destination(for store: Store<AppReducer.Path.State, AppReducer.Path.Action>) -> some View {
		Group {
			switch store.case {
			case let .activation(store):
				ActivationView(store: store)

			case let .scratch(store):
				ScratchView(store: store)
			}
		}
	}

	@ViewBuilder
	private func root() -> some View {
		MainView(store: store.scope(state: \.main, action: \.main))
	}
}
