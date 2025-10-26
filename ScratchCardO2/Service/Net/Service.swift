import Foundation

protocol Service {
	func activate(code: String) async throws -> ActivationResponse
}

struct ServiceImpl: Service {

	func activate(code: String) async throws -> ActivationResponse {
		guard let url = URL(string: "https://api.o2.sk/version")?.appending("code", value: code) else {
			throw ApiError.invalidUrl
		}

		let (data, _) = try await URLSession.shared.data(from: url)
		let response = try JSONDecoder().decode(ActivationResponse.self, from: data)
		return response
	}
	
}
