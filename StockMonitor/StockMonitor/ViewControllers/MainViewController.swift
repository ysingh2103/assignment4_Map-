import UIKit
import CoreData

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupTableView()
        fetchAndReloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAndReloadData()
    }
    
    private func setupNavigationBar() {
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchStock))
        self.navigationItem.rightBarButtonItem = searchButton
    }
    
    private func setupTableView() {
        tableView.register(StockCell.self, forCellReuseIdentifier: "StockCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        refreshControl.addTarget(self, action: #selector(refreshStockData), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    @objc private func refreshStockData() {
        fetchAndReloadData()
        refreshControl.endRefreshing()
    }
    
    private func fetchAndReloadData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            let activeStocks = try fetchStocks(withPredicate: NSPredicate(format: "isActive == true"), context: context)
            let watchlistStocks = try fetchStocks(withPredicate: NSPredicate(format: "isInWatchlist == true"), context: context)
            
            StockList.shared.activeStocks = activeStocks
            StockList.shared.watchlistStocks = watchlistStocks
            
            tableView.reloadData()
        } catch {
            print("Failed to fetch stocks: \(error)")
        }
    }
    
    private func fetchStocks(withPredicate predicate: NSPredicate, context: NSManagedObjectContext) throws -> [Stock] {
        let fetchRequest: NSFetchRequest<StockEntity> = StockEntity.fetchRequest()
        fetchRequest.predicate = predicate
        
        let stockEntities = try context.fetch(fetchRequest)
        return stockEntities.map { Stock(entity: $0) }
    }
    
    @objc private func searchStock() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let searchVC = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController {
            self.navigationController?.pushViewController(searchVC, animated: true)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? StockList.shared.activeStocks.count : StockList.shared.watchlistStocks.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Active" : "Watching"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StockCell", for: indexPath) as! StockCell
        
        let stock = indexPath.section == 0 ? StockList.shared.activeStocks[indexPath.row] : StockList.shared.watchlistStocks[indexPath.row]
        cell.configure(with: stock)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stock = indexPath.section == 0 ? StockList.shared.activeStocks[indexPath.row] : StockList.shared.watchlistStocks[indexPath.row]
        
        let alert = UIAlertController(title: "Manage Stock", message: "Change rank, move between lists, or view details.", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "View Details", style: .default, handler: { [weak self] _ in
            self?.navigateToStockDetail(with: stock)
        }))
        alert.addAction(UIAlertAction(title: "Rank as Cold", style: .default, handler: { [weak self] _ in
            self?.updateStockRank(stock, to: .cold)
        }))
        alert.addAction(UIAlertAction(title: "Rank as Hot", style: .default, handler: { [weak self] _ in
            self?.updateStockRank(stock, to: .hot)
        }))
        alert.addAction(UIAlertAction(title: "Rank as Very Hot", style: .default, handler: { [weak self] _ in
            self?.updateStockRank(stock, to: .veryHot)
        }))
        alert.addAction(UIAlertAction(title: "Move to Watchlist", style: .default, handler: { [weak self] _ in
            self?.moveStock(stock, toActiveList: false)
        }))
        alert.addAction(UIAlertAction(title: "Move to Active List", style: .default, handler: { [weak self] _ in
            self?.moveStock(stock, toActiveList: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func navigateToStockDetail(with stock: Stock) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "StockDetailViewController") as? StockDetailViewController {
            detailVC.stock = stock
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let stock = indexPath.section == 0 ? StockList.shared.activeStocks.remove(at: indexPath.row) : StockList.shared.watchlistStocks.remove(at: indexPath.row)
            
            // Remove from CoreData
            deleteStock(stock)
            
            // Perform the table view update with animation
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }
    
    private func updateStockRank(_ stock: Stock, to rank: StockRank) {
        var updatedStock = stock
        updatedStock.rank = rank
        
        StockList.shared.updateStock(updatedStock, withRank: rank)
        saveOrUpdateStock(updatedStock)
        fetchAndReloadData()
    }
    
    private func moveStock(_ stock: Stock, toActiveList: Bool) {
        var updatedStock = stock
        updatedStock.isActive = toActiveList
        updatedStock.isInWatchlist = !toActiveList
        
        StockList.shared.moveStock(updatedStock, toActiveList: toActiveList)
        saveOrUpdateStock(updatedStock)
        fetchAndReloadData()
    }
    
    private func saveOrUpdateStock(_ stock: Stock) {
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
    
    private func deleteStock(_ stock: Stock) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<StockEntity> = StockEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "symbol == %@", stock.symbol)
        
        do {
            if let stockEntity = try context.fetch(fetchRequest).first {
                context.delete(stockEntity)
                try context.save()
            }
        } catch {
            print("Failed to delete stock: \(error.localizedDescription)")
        }
    }
}
