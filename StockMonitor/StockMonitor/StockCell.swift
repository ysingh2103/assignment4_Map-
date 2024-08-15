import UIKit

class StockCell: UITableViewCell {
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        return label
    }()
    
    let rankIndicatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        contentView.addSubview(rankIndicatorView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        
        NSLayoutConstraint.activate([
            rankIndicatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            rankIndicatorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rankIndicatorView.widthAnchor.constraint(equalToConstant: 10),
            rankIndicatorView.heightAnchor.constraint(equalToConstant: 10),
            
            nameLabel.leadingAnchor.constraint(equalTo: rankIndicatorView.trailingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            priceLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: priceLabel.leadingAnchor, constant: -8)
        ])
    }
    
    func configure(with stock: Stock) {
        nameLabel.text = stock.name
        priceLabel.text = String(format: "$%.2f", stock.price)
        
        switch stock.rank {
        case .cold:
            rankIndicatorView.backgroundColor = .blue
        case .hot:
            rankIndicatorView.backgroundColor = .orange
        case .veryHot:
            rankIndicatorView.backgroundColor = .red
        }
        
        print("Displaying stock with price: \(stock.price)") // Debugging output
    }
}
