import YandexMobileMetrica

@objc(Metrica)
class Metrica: NSObject {

    @objc func activate(_ apiKey: String) {
        let configuration = YMMYandexMetricaConfiguration.init(apiKey: apiKey)
        YMMYandexMetrica.activate(with: configuration!)
        
  }
    
    @objc func reportEvent(_ eventName: String, _ params: [AnyHashable : Any]) {
        YMMYandexMetrica.reportEvent(eventName, parameters: params)
  }
}
