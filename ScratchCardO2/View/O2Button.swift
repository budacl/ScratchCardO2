import SwiftUI

struct O2Button: View {

	let text: String
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			Text(text)
				.frame(maxWidth: .infinity)
				.frame(height: 50)
		}
		.buttonStyle(.borderedProminent)
	}

	init(_ text: String, action: @escaping () -> Void) {
		self.text = text
		self.action = action
	}
}
