import Foundation

struct ScratchCard: Equatable {
	enum State: Equatable {
		case unscratched, scratched, activated
	}
	
	let id = UUID().uuidString
	var state: State
}
