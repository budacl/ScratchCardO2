import ComposableArchitecture
import SwiftUI

@ViewAction(for: Main.self)
struct MainView: View {

	@Bindable
	var store: StoreOf<Main>

	var body: some View {
		VStack(spacing: 16) {
			ScratchCardView(
				card: store.scratchCard,
				isLoading: false
			)
			.padding(.top, 32)

			Spacer()

			O2Button("Scratch") {
				send(.scratch)
			}
			.disabled(store.scratchCard.state != .unscratched)

			O2Button("Activate") {
				send(.activate)
			}
			.disabled(store.scratchCard.state != .scratched)

			O2Button("RESET") {
				send(.reset)
			}
			.padding(.top, 32)
		}
		.task { await send(.start).finish() }
		.navigationTitle("Scratch card")
		.padding()
	}

	init(store: StoreOf<Main>) {
		self.store = store
	}
}
