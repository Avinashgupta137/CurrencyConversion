//
//  NetworkManager.swift
//  CurrencyConversion
//
//  Created by Avinash Gupta on 20/08/24.
//

import Foundation

struct ExchangeRatesResponse: Codable {
    let rates: [String: Double]
    let base: String
    let timestamp: TimeInterval
}

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://openexchangerates.org/api/"
    private let appID = "acbfa184f212465ab06f7c3b4021196a"

    func fetchExchangeRates(completion: @escaping (Result<ExchangeRatesResponse, Error>) -> Void) {
        let urlString = "\(baseURL)latest.json?app_id=\(appID)"
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else { return }
            do {
                let response = try JSONDecoder().decode(ExchangeRatesResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
