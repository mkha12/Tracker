import YandexMobileMetrica


struct AnalyticsService {
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "76126919-6bda-4a1e-a47d-7a69744e45eb") else { return }
        
        YMMYandexMetrica.activate(with: configuration)
    }
    
    func report(event: String, params : [AnyHashable : Any]) {
        YMMYandexMetrica.reportEvent(event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}


