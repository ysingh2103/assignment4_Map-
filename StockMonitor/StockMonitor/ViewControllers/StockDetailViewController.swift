import UIKit

class StockDetailViewController: UIViewController {

    @IBOutlet weak var stockSymbolLabel: UILabel!
    @IBOutlet weak var stockPriceLabel: UILabel!
    @IBOutlet weak var predictedPriceLabel: UILabel!
    
    var stock: Stock?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let stock = stock else { return }
        
        stockSymbolLabel.text = stock.symbol
        stockPriceLabel.text = String(format: "$%.2f", stock.price)
        
        // Fetch recent prices and calculate prediction
        fetchRecentPrices(for: stock.symbol) { [weak self] recentPrices in
            let predictedPrice = self?.calculatePricePrediction(recentPrices: recentPrices)
            DispatchQueue.main.async {
                self?.displayPredictedPrice(predictedPrice)
            }
        }
    }
    
    private func fetchRecentPrices(for symbol: String, completion: @escaping ([Double]) -> Void) {
        // Simulate fetching recent prices from an API or database
        let recentPrices = [100.0, 101.0, 102.5, 103.0, 104.0, 105.5, 106.0] // Example data
        completion(recentPrices)
    }
    
    private func calculatePricePrediction(recentPrices: [Double]) -> Double {
        guard !recentPrices.isEmpty else { return stock?.price ?? 0.0 }
        
        let count = Double(recentPrices.count)
        let sumX = count * (count - 1) / 2.0
        let sumY = recentPrices.reduce(0, +)
        let sumXY = recentPrices.enumerated().reduce(0) { $0 + Double($1.offset) * $1.element }
        let sumX2 = (count * (count - 1) * (2 * count - 1)) / 6.0
        
        let slope = (count * sumXY - sumX * sumY) / (count * sumX2 - sumX * sumX)
        let intercept = (sumY - slope * sumX) / count
        
        // Predict the next price (extrapolate one step forward)
        return slope * count + intercept
    }
    
    private func displayPredictedPrice(_ price: Double?) {
        guard let price = price else {
            predictedPriceLabel.text = "Prediction Unavailable"
            return
        }
        predictedPriceLabel.text = String(format: "Predicted Price: $%.2f", price)
    }
}
