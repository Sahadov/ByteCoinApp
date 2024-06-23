//
//  CurrencyData.swift
//  ByteCoin
//
//  Created by Дмитрий Волков on 22.06.2024.
//


import Foundation

protocol CoinManagerDelegate {
    func didUpdateCurrency(price: String, currency: String)
    func didFailWithError(error: Error)
}


struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "86afa338-6818-40ed-9bbd-5de83c3a2663"
    
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    func getCoinPrice(for currency: String) {
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        performCoinRequest(with: urlString, currency: currency)
        
    }
    
    func performCoinRequest(with urlString: String, currency: String){
            if let url = URL(string: urlString) {
                let session = URLSession(configuration: .default)
                let task = session.dataTask(with: url) { data, response, error in
                    if error != nil {
                        self.delegate?.didFailWithError(error: error!)
                        return
                    }
                    if let safeData = data {
                        if let bitcoinPrice = self.parseJSON(safeData) {
                            let priceString = String(format: "%.2f", bitcoinPrice)
                            delegate?.didUpdateCurrency(price: priceString, currency: currency)
                        }
                    }
                }
                task.resume()
            }
        }
    
    func parseJSON(_ currencyData: Data) -> Double? {
            let decoder = JSONDecoder()
            do {
                let decodedData = try decoder.decode(CurrencyData.self, from: currencyData)
                let rate = decodedData.rate
                return rate
            } catch {
                delegate?.didFailWithError(error: error)
                return nil
            }
        }
    
}

