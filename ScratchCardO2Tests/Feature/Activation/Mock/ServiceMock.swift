@testable import ScratchCardO2

struct ServiceMock: Service {

	private let activate: (String) async throws -> ActivationResponse

	init(activate: @escaping (String) async throws -> ActivationResponse) {
		self.activate = activate
	}

	func activate(code: String) async throws -> ActivationResponse {
		try await activate(code)
	}
}
