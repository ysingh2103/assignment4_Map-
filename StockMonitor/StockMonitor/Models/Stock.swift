import Foundation

enum StockRank: String, Codable {
    case cold = "Cold"
    case hot = "Hot"
    case veryHot = "Very Hot"
}

struct Stock: Codable {
    let symbol: String
    let name: String
    var price: Double
    var isActive: Bool
    var isInWatchlist: Bool
    var rank: StockRank
    
    init(entity: StockEntity) {
        self.symbol = entity.symbol ?? ""
        self.name = entity.name ?? ""
        self.price = entity.price
        self.isActive = entity.isActive
        self.isInWatchlist = entity.isInWatchlist
        self.rank = StockRank(rawValue: entity.rank ?? "Cold") ?? .cold
    }
    
    init(symbol: String, name: String, price: Double, isActive: Bool, isInWatchlist: Bool, rank: StockRank) {
        self.symbol = symbol
        self.name = name
        self.price = price
        self.isActive = isActive
        self.isInWatchlist = isInWatchlist
        self.rank = rank
    }
}
