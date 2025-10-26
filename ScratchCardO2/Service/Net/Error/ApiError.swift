enum ApiError: String, AlertableError {
	case invalidUrl = "Invalid URL"

	var message: String { rawValue }
}
