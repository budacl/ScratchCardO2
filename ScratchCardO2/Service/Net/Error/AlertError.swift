struct AlertError: AlertableError {
	let message: String

	nonisolated init(_ message: String) {
		self.message = message
	}
}
