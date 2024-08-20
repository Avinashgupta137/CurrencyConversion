//
//  ContentView.swift
//  CurrencyConversion
//
//  Created by Avinash Gupta on 20/08/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var amount: String = ""
    @State private var selectedCurrency: String = "USD"
    @State private var exchangeRates: [String: Double] = [:]

    var body: some View {
        VStack {
            TextField("Enter amount", text: $amount)
                .keyboardType(.decimalPad)
                .padding()
            
            Picker("Select Currency", selection: $selectedCurrency) {
                ForEach(exchangeRates.keys.sorted(), id: \.self) { currency in
                    Text(currency).tag(currency)
                }
            }
            .padding()
            
            List(exchangeRates.keys.sorted(), id: \.self) { currency in
                HStack {
                    Text(currency)
                    Spacer()
                    if let amount = Double(amount), let rate = exchangeRates[currency] {
                        Text(String(format: "%.2f", amount * rate))
                    }
                }
            }
        }
        .onAppear {
            fetchRatesIfNeeded()
        }
    }
    
    func fetchRatesIfNeeded() {
        if DataPersistenceManager.shared.shouldFetchNewRates() {
            NetworkManager.shared.fetchExchangeRates { result in
                switch result {
                case .success(let response):
                    exchangeRates = response.rates
                    DataPersistenceManager.shared.saveRates(response.rates, base: response.base, timestamp: response.timestamp)
                case .failure(let error):
                    print("Error fetching rates: \(error)")
                }
            }
        } else {
            exchangeRates = DataPersistenceManager.shared.fetchRates() ?? [:]
        }
    }
}
