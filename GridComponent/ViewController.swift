//
//  ViewController.swift
//  PortfolioGridApp
//

import Cocoa

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    var tableView: NSTableView!
    var scrollView: NSScrollView!
    var groupByPopup: NSPopUpButton!

    enum Row {
        case groupHeader(String)
        case position(Position)
        case subtotal(String, SubtotalData)
        case grandTotal(SubtotalData)
    }

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

        var value: Double {
            return quantity * price
        }
    }

    struct SubtotalData {
        let totalValue: Double
        let gain: Double
    }

    let sampleData = [
        Position(symbol: "H2O Vivace FCP R", currency: "EUR", assetClass: "Hedge Fund", quantity: 18, costPrice: 63378.95, date: "13-Jun-2025", price: 81971.19, evol: -0.89, gain: 29.38),
        Position(symbol: "H2O Vivace HUSD-R", currency: "USD", assetClass: "Hedge Fund", quantity: 56, costPrice: 30330.59, date: "13-Jun-2025", price: 45303.32, evol: -0.54, gain: 49.37),
        Position(symbol: "Airbus SE", currency: "EUR", assetClass: "Action", quantity: 1200, costPrice: 83.54, date: "17-Jun-2025", price: 160.74, evol: -0.79, gain: 3.85),
        Position(symbol: "Alibaba Group", currency: "USD", assetClass: "Action", quantity: 2950, costPrice: 182.70, date: "17-Jun-2025", price: 115.38, evol: -0.50, gain: 36.08),
        Position(symbol: "Align Technology", currency: "USD", assetClass: "Action", quantity: 1000, costPrice: 319.78, date: "17-Jun-2025", price: 174.66, evol: -4.31, gain: -45.38),
        Position(symbol: "Amazon Inc", currency: "USD", assetClass: "Action", quantity: 3600, costPrice: 79.42, date: "17-Jun-2025", price: 215.3899, evol: -0.33, gain: -1.82),
        Position(symbol: "ING Groep NV", currency: "EUR", assetClass: "Action", quantity: 20600, costPrice: 8.59, date: "13-Jun-2025", price: 17.916, evol: -1.38, gain: 18.41),
        Position(symbol: "JD.com Inc", currency: "USD", assetClass: "Action", quantity: 4000, costPrice: 45.08, date: "17-Jun-2025", price: 33.295, evol: -0.55, gain: -3.97),
        Position(symbol: "Micron Technology", currency: "USD", assetClass: "Action", quantity: 7000, costPrice: 57.20, date: "17-Jun-2025", price: 202.4444, evol: 0.50, gain: 22.20),
        Position(symbol: "MongoDB Inc", currency: "USD", assetClass: "Action", quantity: 300, costPrice: 413.28, date: "17-Jun-2025", price: 206.67, evol: 2.06, gain: -11.23),
        Position(symbol: "Palo Alto Networks", currency: "USD", assetClass: "Action", quantity: 5400, costPrice: 41.40, date: "17-Jun-2025", price: 201.515, evol: 1.72, gain: 10.75),
        Position(symbol: "STMicroelectronics", currency: "EUR", assetClass: "Action", quantity: 4500, costPrice: 33.42, date: "17-Jun-2025", price: 25.245, evol: -1.33, gain: 4.00),
        Position(symbol: "Starbucks Corp", currency: "USD", assetClass: "Action", quantity: 961, costPrice: 88.62, date: "17-Jun-2025", price: 91.24, evol: -2.40, gain: -0.01),
        Position(symbol: "TSMC", currency: "USD", assetClass: "Action", quantity: 1450, costPrice: 139.74, date: "17-Jun-2025", price: 214.16, evol: -0.70, gain: 8.44),
        Position(symbol: "UBS Group AG", currency: "CHF", assetClass: "Action", quantity: 3000, costPrice: 16.67, date: "17-Jun-2025", price: 25.84, evol: -1.07, gain: -6.82),
        Position(symbol: "Gold Bullion", currency: "USD", assetClass: "Gold", quantity: 1378, costPrice: 125.65, date: "17-Jun-2025", price: 310.085, evol: -0.71, gain: 29.26),
        Position(symbol: "CHF", currency: "CHF", assetClass: "Cash", quantity: 1578, costPrice: 1.0, date: "-", price: 1.0, evol: 0.00, gain: 0.00),
        Position(symbol: "EURO", currency: "EUR", assetClass: "Cash", quantity: 292683, costPrice: 1.0, date: "-", price: 1.0, evol: 0.00, gain: 0.00),
        Position(symbol: "GBP", currency: "GBP", assetClass: "Cash", quantity: 39, costPrice: 1.0, date: "-", price: 1.0, evol: 0.00, gain: 0.00),
        Position(symbol: "JPY Cash", currency: "JPY", assetClass: "Cash", quantity: 2220427, costPrice: 1.0, date: "-", price: 1.0, evol: 0.00, gain: 0.00),
        Position(symbol: "USD Dollar", currency: "USD", assetClass: "Cash", quantity: 609318, costPrice: 1.0, date: "-", price: 1.0, evol: 0.00, gain: 0.00)
    ]

    var rows: [Row] = []

    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 800, height: 600))

        groupByPopup = NSPopUpButton(frame: NSRect(x: 20, y: self.view.bounds.height - 40, width: 200, height: 24))
        groupByPopup.autoresizingMask = [.maxYMargin]
        groupByPopup.addItems(withTitles: ["Asset Class", "Currency"])
        groupByPopup.target = self
        groupByPopup.action = #selector(groupingChanged(_:))
        self.view.addSubview(groupByPopup)

        scrollView = NSScrollView(frame: NSRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height - 50))
        scrollView.autoresizingMask = [.width, .height]

        tableView = NSTableView(frame: scrollView.bounds)

        let columns = [
            ("Symbol", "symbol"),
            ("Currency", "currency"),
            ("Asset Class", "assetClass"),
            ("Quantity", "quantity"),
            ("Cost Price", "costPrice"),
            ("Date", "date"),
            ("Price", "price"),
            ("Evol", "evol"),
            ("Gain %", "gain")
        ]

        for (title, identifier) in columns {
            let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(identifier))
            column.title = title
            column.width = 120
            tableView.addTableColumn(column)
        }

        tableView.headerView = NSTableHeaderView()
        tableView.delegate = self
        tableView.dataSource = self

        scrollView.documentView = tableView
        self.view.addSubview(scrollView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        rows = buildRows(from: sampleData) { $0.assetClass }
        tableView.reloadData()
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return rows.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let text = NSTextField()
        text.isBordered = false
        text.isEditable = false
        text.backgroundColor = .clear

        guard let columnIdentifier = tableColumn?.identifier.rawValue else { return text }

        switch rows[row] {
        case .groupHeader(let title):
            if columnIdentifier == "symbol" {
                text.stringValue = title
                text.font = NSFont.boldSystemFont(ofSize: 13)
            } else {
                text.stringValue = ""
            }
        case .position(let p):
            switch columnIdentifier {
            case "symbol": text.stringValue = p.symbol
            case "currency": text.stringValue = p.currency
            case "assetClass": text.stringValue = p.assetClass
            case "quantity": text.stringValue = String(format: "%.0f", p.quantity)
            case "costPrice": text.stringValue = String(format: "%.2f", p.costPrice)
            case "date": text.stringValue = p.date
            case "price": text.stringValue = String(format: "%.2f", p.price)
            case "evol": text.stringValue = String(format: "%.2f%%", p.evol)
            case "gain":
                text.stringValue = String(format: "%.2f%%", p.gain)
                text.textColor = p.gain >= 0 ? NSColor.systemGreen : NSColor.systemRed
            default: text.stringValue = ""
            }
        case .subtotal(let label, let subtotal):
            if columnIdentifier == "symbol" {
                text.stringValue = label
                text.font = NSFont.boldSystemFont(ofSize: 12)
            } else if columnIdentifier == "value" {
                text.stringValue = String(format: "%.2f", subtotal.totalValue)
            } else if columnIdentifier == "gain" {
                text.stringValue = String(format: "%.2f%%", subtotal.gain)
                text.textColor = subtotal.gain >= 0 ? NSColor.systemGreen : NSColor.systemRed
            } else {
                text.stringValue = ""
            }
        case .grandTotal(let data):
            if columnIdentifier == "symbol" {
                text.stringValue = "Total Portfolio"
                text.font = NSFont.boldSystemFont(ofSize: 13)
            } else if columnIdentifier == "value" {
                text.stringValue = String(format: "%.2f", data.totalValue)
            } else if columnIdentifier == "gain" {
                text.stringValue = String(format: "%.2f%%", data.gain)
                text.textColor = data.gain >= 0 ? NSColor.systemGreen : NSColor.systemRed
            } else {
                text.stringValue = ""
            }
        }
        return text
    }

    @objc func groupingChanged(_ sender: NSPopUpButton) {
        switch sender.titleOfSelectedItem {
        case "Currency":
            rows = buildRows(from: sampleData) { $0.currency }
        default:
            rows = buildRows(from: sampleData) { $0.assetClass }
        }
        tableView.reloadData()
    }

    func buildRows(from positions: [Position], groupedBy: (Position) -> String) -> [Row] {
        let grouped = Dictionary(grouping: positions, by: groupedBy)
        var result: [Row] = []

        var grandTotalValue: Double = 0
        var grandTotalGain: Double = 0

        for (key, group) in grouped.sorted(by: { $0.key < $1.key }) {
            result.append(.groupHeader(key))
            result.append(contentsOf: group.map { .position($0) })

            let totalValue = group.reduce(0) { $0 + $1.value }
            let totalGain = group.reduce(0) { $0 + $1.gain }
            result.append(.subtotal("Total \(key)", SubtotalData(totalValue: totalValue, gain: totalGain)))

            grandTotalValue += totalValue
            grandTotalGain += totalGain
        }

        result.append(.grandTotal(SubtotalData(totalValue: grandTotalValue, gain: grandTotalGain)))

        return result
    }
}

