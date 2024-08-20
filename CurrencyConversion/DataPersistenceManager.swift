//
//  DataPersistenceManager.swift
//  CurrencyConversion
//
//  Created by Avinash Gupta on 20/08/24.
//


import CoreData

class DataPersistenceManager {
    static let shared = DataPersistenceManager()
    private let context = PersistenceController.shared.container.viewContext
    
    func saveRates(_ rates: [String: Double], base: String, timestamp: TimeInterval) {
        let exchangeRate = ExchangeRate(context: context)
        exchangeRate.timestamp = Date(timeIntervalSince1970: timestamp)
        exchangeRate.baseCurrency = base
        exchangeRate.rates = rates as NSObject
        
        do {
            try context.save()
        } catch {
            print("Error saving data: \(error)")
        }
    }
    
    func fetchRates() -> [String: Double]? {
        let request: NSFetchRequest<ExchangeRate> = ExchangeRate.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        request.fetchLimit = 1
        
        do {
            let result = try context.fetch(request)
            return result.first?.rates as? [String: Double]
        } catch {
            print("Error fetching data: \(error)")
            return nil
        }
    }
    
    func shouldFetchNewRates() -> Bool {
        let request: NSFetchRequest<ExchangeRate> = ExchangeRate.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        request.fetchLimit = 1
        
        do {
            if let lastFetch = try context.fetch(request).first {
                let thirtyMinutesAgo = Date().addingTimeInterval(-1800)
                return lastFetch.timestamp ?? Date.distantPast < thirtyMinutesAgo
            }
        } catch {
            print("Error checking last fetch time: \(error)")
        }
        return true
    }
}
