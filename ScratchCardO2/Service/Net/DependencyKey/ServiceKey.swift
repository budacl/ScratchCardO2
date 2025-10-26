import Dependencies

enum ServiceKey: DependencyKey {
	static var liveValue: Service {
		ServiceImpl()
	}
}

extension DependencyValues {
	var service: Service {
		get { self[ServiceKey.self] }
		set { self[ServiceKey.self] = newValue }
	}
}
