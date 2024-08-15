import UIKit
import CoreData

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    var searchResults: [Stock] = []
    var searchTask: DispatchWorkItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(StockCell.self, forCellReuseIdentifier: "StockCell")
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTask?.cancel()

        let task = DispatchWorkItem { [weak self] in
            self?.fetchStock(for: searchText)
        }
        searchTask = task
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: task)
    }

    func fetchStock(for query: String) {
        guard !query.isEmpty else { return }

        let url = URL(string: "https://ms-finance.p.rapidapi.com/market/v2/auto-complete?q=\(query)")!
        var request = URLRequest(url: url)
        request.setValue("d4c2a8d472msha0e601434fe2e25p15f7e2jsn0a90c8b3fdaf", forHTTPHeaderField: "x-rapidapi-key")
        request.setValue("ms-finance.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Error fetching stock data: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received.")
                return
            }

            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw API response: \(rawResponse)")
            }

            self?.handleStockResponse(data)
        }
        task.resume()
    }

    private func handleStockResponse(_ data: Data) {
        do {
            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let results = jsonResponse["results"] as? [[String: Any]] {

                var stocks: [Stock] = []
                
                for dict in results {
                    print("Processing dictionary: \(dict)")

                    guard let symbol = dict["ticker"] as? String, !symbol.isEmpty,
                          let name = dict["name"] as? String, !name.isEmpty else {
                        print("Skipping due to missing or empty symbol or name.")
                        continue
                    }

                    let price = dict["price"] as? Double ?? 0.0
                    print("Parsed price for \(symbol): \(price)")

                    let stock = Stock(
                        symbol: symbol,
                        name: name,
                        price: price,
                        isActive: false,
                        isInWatchlist: false,
                        rank: .cold
                    )

                    stocks.append(stock)
                }

                self.searchResults = stocks

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        } catch {
            print("Error parsing JSON: \(error.localizedDescription)")
        }
    }

    // MARK: - TableView Data Source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StockCell", for: indexPath) as! StockCell
        let stock = searchResults[indexPath.row]
        cell.configure(with: stock)
        return cell
    }

    // MARK: - TableView Delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stock = searchResults[indexPath.row]

        let alert = UIAlertController(title: "Add Stock", message: "Add \(stock.name) to:", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Active List", style: .default, handler: { [weak self] _ in
            self?.addStockToActiveList(stock)
        }))
        alert.addAction(UIAlertAction(title: "Watch List", style: .default, handler: { [weak self] _ in
            self?.addStockToWatchlist(stock)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }

    private func addStockToActiveList(_ stock: Stock) {
        var updatedStock = stock
        updatedStock.isActive = true
        updatedStock.isInWatchlist = false
        StockList.shared.addStock(updatedStock, toActiveList: true)
        saveOrUpdateStock(updatedStock)
    }

    private func addStockToWatchlist(_ stock: Stock) {
        var updatedStock = stock
        updatedStock.isActive = false
        updatedStock.isInWatchlist = true
        StockList.shared.addStock(updatedStock, toActiveList: false)
        saveOrUpdateStock(updatedStock)
    }

    // CoreData Saving or Updating Function
    func saveOrUpdateStock(_ stock: Stock) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<StockEntity> = StockEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "symbol == %@", stock.symbol)

        do {
            if let stockEntity = try context.fetch(fetchRequest).first {
                // Update existing stock
                stockEntity.name = stock.name
                stockEntity.price = stock.price
                stockEntity.isActive = stock.isActive
                stockEntity.isInWatchlist = stock.isInWatchlist
                stockEntity.rank = stock.rank.rawValue
            } else {
                // Save new stock
                let stockEntity = StockEntity(context: context)
                stockEntity.symbol = stock.symbol
                stockEntity.name = stock.name
                stockEntity.price = stock.price
                stockEntity.isActive = stock.isActive
                stockEntity.isInWatchlist = stock.isInWatchlist
                stockEntity.rank = stock.rank.rawValue
            }

            try context.save()
        } catch {
            print("Failed to save or update stock: \(error.localizedDescription)")
        }
    }
}
