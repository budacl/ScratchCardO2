import ComposableArchitecture
import SwiftUI

@ViewAction(for: Activation.self)
struct ActivationView: View {

	@Bindable
	var store: StoreOf<Activation>

	var body: some View {
		VStack(spacing: 16) {
			ScratchCardView(
				card: store.scratchCard,
				isLoading: store.isLoading
			)
			.padding(.top, 32)

			Spacer()

			O2Button("Activate") {
				send(.activate)
			}
			.disabled(store.scratchCard.state == .activated)
		}
		.alert($store.scope(state: \.alert, action: \.alert))
		.navigationTitle("Activate card")
		.padding()
	}

	init(store: StoreOf<Activation>) {
		self.store = store
	}
}
