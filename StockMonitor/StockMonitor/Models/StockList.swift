import Foundation
import CoreData
import UIKit

class StockList {
    static let shared = StockList()

    var activeStocks: [Stock] = []
    var watchlistStocks: [Stock] = []

    private init() {}

    // MARK: - Add Stock

    func addStock(_ stock: Stock, toActiveList: Bool) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        if toActiveList {
            activeStocks.append(stock)
        } else {
            watchlistStocks.append(stock)
        }

        // Save the new stock to Core Data
        let stockEntity = StockEntity(context: context)
        stockEntity.symbol = stock.symbol
        stockEntity.name = stock.name
        stockEntity.price = stock.price
        stockEntity.isActive = toActiveList
        stockEntity.isInWatchlist = !toActiveList
        stockEntity.rank = stock.rank.rawValue

        do {
            try context.save()
        } catch {
            print("Failed to save stock to Core Data: \(error)")
        }
    }

    // MARK: - Update Stock Rank

    func updateStock(_ stock: Stock, withRank rank: StockRank) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        // Update the rank in memory
        if let index = activeStocks.firstIndex(where: { $0.symbol == stock.symbol }) {
            activeStocks[index].rank = rank
        } else if let index = watchlistStocks.firstIndex(where: { $0.symbol == stock.symbol }) {
            watchlistStocks[index].rank = rank
        }

        // Save the updated rank to Core Data
        let fetchRequest: NSFetchRequest<StockEntity> = StockEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "symbol == %@", stock.symbol)

        do {
            if let stockEntity = try context.fetch(fetchRequest).first {
                stockEntity.rank = rank.rawValue
                try context.save()
            }
        } catch {
            print("Failed to update stock rank in Core Data: \(error)")
        }
    }

    // MARK: - Move Stock Between Lists

    func moveStock(_ stock: Stock, toActiveList: Bool) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        if toActiveList {
            // Move from watchlist to active list
            if let index = watchlistStocks.firstIndex(where: { $0.symbol == stock.symbol }) {
                var movedStock = watchlistStocks.remove(at: index)
                movedStock.isActive = true
                movedStock.isInWatchlist = false
                activeStocks.append(movedStock)
            }
        } else {
            // Move from active list to watchlist
            if let index = activeStocks.firstIndex(where: { $0.symbol == stock.symbol }) {
                var movedStock = activeStocks.remove(at: index)
                movedStock.isActive = false
                movedStock.isInWatchlist = true
                watchlistStocks.append(movedStock)
            }
        }

        // Save the changes to Core Data
        let fetchRequest: NSFetchRequest<StockEntity> = StockEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "symbol == %@", stock.symbol)

        do {
            if let stockEntity = try context.fetch(fetchRequest).first {
                stockEntity.isActive = toActiveList
                stockEntity.isInWatchlist = !toActiveList
                try context.save()
            }
        } catch {
            print("Failed to move stock in Core Data: \(error)")
        }
    }

    // MARK: - Remove Stock

    func removeStock(_ stock: Stock) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        // Remove from in-memory list
        if let index = activeStocks.firstIndex(where: { $0.symbol == stock.symbol }) {
            activeStocks.remove(at: index)
        } else if let index = watchlistStocks.firstIndex(where: { $0.symbol == stock.symbol }) {
            watchlistStocks.remove(at: index)
        }

        // Remove from Core Data
        let fetchRequest: NSFetchRequest<StockEntity> = StockEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "symbol == %@", stock.symbol)

        do {
            if let stockEntity = try context.fetch(fetchRequest).first {
                context.delete(stockEntity)
                try context.save()
            }
        } catch {
            print("Failed to delete stock from Core Data: \(error)")
        }
    }

    // MARK: - Fetch Stocks from Core Data

    func fetchStocks(withPredicate predicate: NSPredicate, context: NSManagedObjectContext) throws -> [Stock] {
        let fetchRequest: NSFetchRequest<StockEntity> = StockEntity.fetchRequest()
        fetchRequest.predicate = predicate
        
        let stockEntities = try context.fetch(fetchRequest)
        return stockEntities.map { Stock(entity: $0) }
    }
}
