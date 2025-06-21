class PortfolioData {
    static let shared = PortfolioData()

    let samplePositions: [Position] = [
        Position(symbol: "H2O Vivace FCP R", currency: "EUR", assetClass: "1. Hedge Fund", quantity: 18, costPrice: 63378.95, date: "13-Jun-2025", price: 81971.19, evol: -0.89, gain: 29.38),
        Position(symbol: "H2O Vivace HUSD-R", currency: "USD", assetClass: "1. Hedge Fund", quantity: 56, costPrice: 30330.59, date: "13-Jun-2025", price: 45303.32, evol: -0.54, gain: 49.37),
        Position(symbol: "Airbus SE", currency: "EUR", assetClass: "2. Equities", quantity: 1200, costPrice: 83.54, date: "17-Jun-2025", price: 160.74, evol: -0.79, gain: 3.85),
        Position(symbol: "Alibaba Group", currency: "USD", assetClass: "2. Equities", quantity: 2950, costPrice: 182.70, date: "17-Jun-2025", price: 115.38, evol: -0.50, gain: 36.08),
        Position(symbol: "Align Technology", currency: "USD", assetClass: "2. Equities", quantity: 1000, costPrice: 319.78, date: "17-Jun-2025", price: 174.66, evol: -4.31, gain: -45.38),
        Position(symbol: "Amazon Inc", currency: "USD", assetClass: "2. Equities", quantity: 3600, costPrice: 79.42, date: "17-Jun-2025", price: 215.39, evol: -0.33, gain: -1.82),
        Position(symbol: "ING Groep NV", currency: "EUR", assetClass: "2. Equities", quantity: 20600, costPrice: 8.59, date: "13-Jun-2025", price: 17.916, evol: -1.38, gain: 18.41),
        Position(symbol: "JD.com Inc", currency: "USD", assetClass: "2. Equities", quantity: 4000, costPrice: 45.08, date: "17-Jun-2025", price: 33.295, evol: -0.55, gain: -3.97),
        Position(symbol: "Micron Technology", currency: "USD", assetClass: "2. Equities", quantity: 7000, costPrice: 57.20, date: "17-Jun-2025", price: 202.4444, evol: 0.50, gain: 22.20),
        Position(symbol: "MongoDB Inc", currency: "USD", assetClass: "2. Equities", quantity: 300, costPrice: 413.28, date: "17-Jun-2025", price: 206.67, evol: 2.06, gain: -11.23),
        Position(symbol: "Palo Alto Networks", currency: "USD", assetClass: "2. Equities", quantity: 5400, costPrice: 41.40, date: "17-Jun-2025", price: 201.515, evol: 1.72, gain: 10.75),
        Position(symbol: "STMicroelectronics", currency: "EUR", assetClass: "2. Equities", quantity: 4500, costPrice: 33.42, date: "17-Jun-2025", price: 25.245, evol: -1.33, gain: 4.00),
        Position(symbol: "Starbucks Corp", currency: "USD", assetClass: "2. Equities", quantity: 961, costPrice: 88.62, date: "17-Jun-2025", price: 91.24, evol: -2.40, gain: -0.01),
        Position(symbol: "TSMC", currency: "USD", assetClass: "2. Equities", quantity: 1450, costPrice: 139.74, date: "17-Jun-2025", price: 214.16, evol: -0.70, gain: 8.44),
        Position(symbol: "UBS Group AG", currency: "CHF", assetClass: "2. Equities", quantity: 3000, costPrice: 16.67, date: "17-Jun-2025", price: 25.84, evol: -1.07, gain: -6.82),
        Position(symbol: "Gold Bullion", currency: "USD", assetClass: "3. Gold", quantity: 1378, costPrice: 125.65, date: "17-Jun-2025", price: 310.08, evol: -0.71, gain: 29.26),
        Position(symbol: "CHF", currency: "CHF", assetClass: "4. Cash", quantity: 1578, costPrice: 1.0, date: "-", price: 1.0, evol: 0.00, gain: 0.00),
        Position(symbol: "EURO", currency: "EUR", assetClass: "4. Cash", quantity: 292683, costPrice: 1.0, date: "-", price: 1.0, evol: 0.00, gain: 0.00),
        Position(symbol: "GBP", currency: "GBP", assetClass: "4. Cash", quantity: 39, costPrice: 1.0, date: "-", price: 1.0, evol: 0.00, gain: 0.00),
        Position(symbol: "JPY", currency: "JPY", assetClass: "4. Cash", quantity: 2220427, costPrice: 1.0, date: "-", price: 1.0, evol: 0.00, gain: 0.00),
        Position(symbol: "USD Dollar", currency: "USD", assetClass: "4. Cash", quantity: 609318, costPrice: 1.0, date: "-", price: 1.0, evol: 0.00, gain: 0.00)
    ]

    private init() { }
}

