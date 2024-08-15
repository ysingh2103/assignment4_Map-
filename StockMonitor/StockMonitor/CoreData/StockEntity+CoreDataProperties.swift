//
//  StockEntity+CoreDataProperties.swift
//  StockMonitor
//
//  Created by Yuvraj Singh on 14/08/24.
//
//

import Foundation
import CoreData


extension StockEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StockEntity> {
        return NSFetchRequest<StockEntity>(entityName: "StockEntity")
    }

    @NSManaged public var symbol: String?
    @NSManaged public var name: String?
    @NSManaged public var price: Double
    @NSManaged public var isActive: Bool
    @NSManaged public var isInWatchlist: Bool
    @NSManaged public var rank: String?

}


extension StockEntity : Identifiable {

}

