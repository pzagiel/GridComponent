import Foundation

struct Position {
    let symbol: String
    let currency: String
    let assetClass: String
    let quantity: Double
    let costPrice: Double
    let date: String
    let price: Double
    let evol: Double
    let gain: Double
    var weight: Double = 0

    var value: Double {
        return quantity * price
    }

    var plAbsolute: Double {
        return value - (quantity * costPrice)
    }
}
