import Foundation

struct NotificatingCenter {
	let publisher: (_ name: Notification.Name, _ object: AnyObject?) -> NotificationCenter.Publisher
	let post: (_ name: Notification.Name, _ object: Any?, _ userInfo: [AnyHashable : Any]?) -> Void
}
