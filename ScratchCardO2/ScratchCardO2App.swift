import ComposableArchitecture
import SwiftUI

@main
struct ScratchCardO2App: App {
	var body: some Scene {
		WindowGroup {
			AppView(store: .init(initialState: .init()) {
				AppReducer()
			})
		}
	}
}
