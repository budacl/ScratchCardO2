import ComposableArchitecture
import SwiftUI

@ViewAction(for: Scratch.self)
struct ScratchView: View {

	@Bindable
	var store: StoreOf<Scratch>

	var body: some View {
		VStack(spacing: 16) {
			ScratchCardView(
				card: store.scratchCard,
				isLoading: store.isLoading
			)
			.padding(.top, 32)

			Spacer()

			O2Button("Scratch") {
				send(.scratch)
			}
			.disabled(store.isLoading || store.scratchCard.state == .scratched)
		}
		.navigationTitle("Scratch card")
		.padding()
	}

	init(store: StoreOf<Scratch>) {
		self.store = store
	}
}
