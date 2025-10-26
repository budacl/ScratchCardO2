import Dependencies
import Foundation

enum NotificatingCenterKey: DependencyKey {
	static var liveValue: NotificatingCenter {
		.init(
			publisher: { name, object in
				NotificationCenter.default.publisher(for: name, object: object)
			},
			post: { name, object, userInfo in
				NotificationCenter.default.post(name: name, object: object, userInfo: userInfo)
			}
		)
	}
}

extension DependencyValues {

	var notificatingCenter: NotificatingCenter {
		get { self[NotificatingCenterKey.self] }
		set { self[NotificatingCenterKey.self] = newValue }
	}

}
