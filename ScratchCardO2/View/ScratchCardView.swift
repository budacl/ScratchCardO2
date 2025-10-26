import SwiftUI

struct ScratchCardView: View {
	let card: ScratchCard
	let isLoading: Bool

	@State private var isVisible = true
	@State private var sentenceIndex = 0
	@State private var blinkCount = 0
	@State private var timer: Timer?
	@State private var shakeOffset: CGFloat = 0

	var body: some View {
		ZStack {
			cardId

			if card.state == .unscratched {
				overlay
				blinkingText
			}
		}
		.frame(maxWidth: .infinity)
		.frame(height: 200)
		.background(backgroundColor(for: card.state))
		.cornerRadius(16)
		.offset(x: shakeOffset)
		.animation(.easeInOut(duration: 0.3), value: card.state)
		.onChange(of: isLoading) { _, newValue in
			handleLoadingChange(newValue)
		}
	}
}

// MARK: - Subviews

private extension ScratchCardView {
	var cardId: some View {
		Text(card.id)
			.font(.caption)
			.multilineTextAlignment(.center)
			.foregroundColor(.black)
			.padding()
	}

	var overlay: some View {
		RoundedRectangle(cornerRadius: 20)
			.fill(.gray)
			.shadow(radius: 5)
	}

	var blinkingText: some View {
		Text(Self.sentences[sentenceIndex])
			.font(.system(size: 18))
			.multilineTextAlignment(.center)
			.padding()
			.opacity(isVisible ? 1 : 0)
			.shadow(color: .blue.opacity(0.8), radius: 20)
			.shadow(color: .blue.opacity(0.6), radius: 40)
			.shadow(color: .blue.opacity(0.4), radius: 60)
			.onAppear { startBlinking() }
			.onDisappear { stopBlinking() }
	}
}

// MARK: - Timer & Animation Logic

private extension ScratchCardView {
	func startBlinking() {
		stopBlinking()
		resetBlinkState()

		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
			withAnimation(.easeInOut(duration: 1)) {
				isVisible.toggle()
			}

			blinkCount += 1

			if blinkCount.isMultiple(of: 2) {
				sentenceIndex = (sentenceIndex + 1) % Self.sentences.count
			}
		}
	}

	func stopBlinking() {
		timer?.invalidate()
		timer = nil
	}

	func resetBlinkState() {
		isVisible = true
		blinkCount = 0
	}
}

// MARK: - Shaking Logic

private extension ScratchCardView {
	func handleLoadingChange(_ isLoading: Bool) {
		isLoading ? startShaking() : stopShaking()
	}

	func startShaking() {
		withAnimation(.linear(duration: 0.05).repeatForever(autoreverses: true)) {
			shakeOffset = 10
		}
	}

	func stopShaking() {
		withAnimation(.easeOut(duration: 0.2)) {
			shakeOffset = 0
		}
	}
}

// MARK: - Helpers

private extension ScratchCardView {
	func backgroundColor(for state: ScratchCard.State) -> Color {
		switch state {
		case .unscratched: return .gray
		case .scratched: return .gray.opacity(0.5)
		case .activated: return .green
		}
	}

	static let sentences = [
		"Scratch me like a DJ dropping the hottest track of 2005.",
		"Scratch me like a cat who just saw a laser pointer.",
		"Scratch me like a mosquito in mosquito heaven.",
		"Scratch me like a record in your uncle’s midlife-crisis garage band.",
		"Scratch me like your Wi-Fi signal just came back after 3 hours.",
		"Scratch me like you’re trying to reveal a winning lottery ticket.",
		"Scratch me like your dog scratches the door at 3 AM for no reason.",
		"Scratch me like your back’s got an unsaved game and the itch is the boss fight.",
		"Scratch me like a toddler with a crayon and no supervision.",
		"Scratch me like you’re auditioning for “America’s Next Top Masseuse.”"
	]
}

// MARK: - Preview

#Preview {
	VStack(spacing: 20) {
		ScratchCardView(card: ScratchCard(state: .unscratched), isLoading: false)
		ScratchCardView(card: ScratchCard(state: .scratched), isLoading: false)
		ScratchCardView(card: ScratchCard(state: .activated), isLoading: false)
	}
	.padding()
	.background(Color(.systemBackground))
}
