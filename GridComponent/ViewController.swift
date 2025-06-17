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

        var plAbsolute: Double {
            return value - (quantity * costPrice)
        }
    }

    struct SubtotalData {
        let totalValue: Double
        let gain: Double
        let pl: Double
    }

    var rows: [Row] = []

    let sampleData: [Position] = [
        Position(symbol: "H2O Vivace FCP R", currency: "EUR", assetClass: "Hedge Fund", quantity: 18, costPrice: 63378.95, date: "13-Jun-2025", price: 81971.19, evol: -0.89, gain: 29.38),
        Position(symbol: "H2O Vivace HUSD-R", currency: "USD", assetClass: "Hedge Fund", quantity: 56, costPrice: 30330.59, date: "13-Jun-2025", price: 45303.32, evol: -0.54, gain: 49.37),
        Position(symbol: "Airbus SE", currency: "EUR", assetClass: "Action", quantity: 1200, costPrice: 83.54, date: "17-Jun-2025", price: 160.74, evol: -0.79, gain: 3.85),
        Position(symbol: "Alibaba Group", currency: "USD", assetClass: "Action", quantity: 2950, costPrice: 182.70, date: "17-Jun-2025", price: 115.38, evol: -0.50, gain: 36.08),
        Position(symbol: "Align Technology", currency: "USD", assetClass: "Action", quantity: 1000, costPrice: 319.78, date: "17-Jun-2025", price: 174.66, evol: -4.31, gain: -45.38),
        Position(symbol: "Amazon Inc", currency: "USD", assetClass: "Action", quantity: 3600, costPrice: 79.42, date: "17-Jun-2025", price: 215.39, evol: -0.33, gain: -1.82),
        Position(symbol: "Gold Bullion", currency: "USD", assetClass: "Gold", quantity: 1378, costPrice: 125.65, date: "17-Jun-2025", price: 310.08, evol: -0.71, gain: 29.26),
        Position(symbol: "USD Dollar", currency: "USD", assetClass: "Cash", quantity: 609318, costPrice: 1.0, date: "-", price: 1.0, evol: 0.0, gain: 0.0)
    ]

    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 1200, height: 800))

        groupByPopup = NSPopUpButton()
        groupByPopup.translatesAutoresizingMaskIntoConstraints = false
        groupByPopup.addItems(withTitles: ["Asset Class", "Currency"])
        groupByPopup.target = self
        groupByPopup.action = #selector(groupingChanged(_:))
        self.view.addSubview(groupByPopup)

        NSLayoutConstraint.activate([
            groupByPopup.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10),
            groupByPopup.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            groupByPopup.widthAnchor.constraint(equalToConstant: 200),
            groupByPopup.heightAnchor.constraint(equalToConstant: 24)
        ])

        scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.autoresizingMask = [.width, .height]

        tableView = NSTableView(frame: scrollView.bounds)

        let columns = [
            ("Symbol", "symbol"),
            ("Currency", "currency"),
            ("Quantity", "quantity"),
            ("Cost Price", "costPrice"),
            ("Date", "date"),
            ("Price", "price"),
            ("Evol", "evol"),
            ("YTD", "gain"),
            ("P/L (€)", "pl"),
            ("Mkt Val", "value")
        ]

        for (title, identifier) in columns {
            let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(identifier))
            column.title = title
            column.width = 100
            tableView.addTableColumn(column)
        }

        tableView.delegate = self
        tableView.dataSource = self
        tableView.headerView = NSTableHeaderView()

        scrollView.documentView = tableView
        self.view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: groupByPopup.bottomAnchor, constant: 10),
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
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

        if ["quantity", "costPrice", "price", "evol", "gain", "pl", "value"].contains(columnIdentifier) {
            text.alignment = .right
        }

        switch rows[row] {
        case .groupHeader(let title):
            text.stringValue = columnIdentifier == "symbol" ? title : ""
            if columnIdentifier == "symbol" {
                text.font = NSFont.boldSystemFont(ofSize: 13)
            }
        case .position(let p):
            switch columnIdentifier {
            case "symbol": text.stringValue = p.symbol
            case "currency": text.stringValue = p.currency
            case "quantity": text.stringValue = String(format: "%.0f", p.quantity)
            case "costPrice": text.stringValue = String(format: "%.2f", p.costPrice)
            case "date": text.stringValue = p.date
            case "price": text.stringValue = String(format: "%.2f", p.price)
            case "evol":
                text.stringValue = String(format: "%.2f%%", p.evol)
                text.textColor = p.evol >= 0 ? NSColor.systemGreen : NSColor.systemRed
            case "gain":
                text.stringValue = String(format: "%.2f%%", p.gain)
                text.textColor = p.gain >= 0 ? NSColor.systemGreen : NSColor.systemRed
            case "pl": text.stringValue = String(format: "%.2f", p.plAbsolute)
            case "value": text.stringValue = String(format: "%.2f", p.value)
            default: text.stringValue = ""
            }
        case .subtotal(let label, let subtotal):
            switch columnIdentifier {
            case "symbol":
                text.stringValue = label
                text.font = NSFont.boldSystemFont(ofSize: 12)
            case "value":
                text.stringValue = String(format: "%.2f", subtotal.totalValue)
            case "gain":
                text.stringValue = String(format: "%.2f%%", subtotal.gain)
                text.textColor = subtotal.gain >= 0 ? NSColor.systemGreen : NSColor.systemRed
            case "pl":
                text.stringValue = String(format: "%.2f", subtotal.pl)
            default:
                text.stringValue = ""
            }
        case .grandTotal(let total):
            switch columnIdentifier {
            case "symbol":
                text.stringValue = "Total Portfolio"
                text.font = NSFont.boldSystemFont(ofSize: 13)
            case "value":
                text.stringValue = String(format: "%.2f", total.totalValue)
            case "gain":
                text.stringValue = String(format: "%.2f%%", total.gain)
                text.textColor = total.gain >= 0 ? NSColor.systemGreen : NSColor.systemRed
            case "pl":
                text.stringValue = String(format: "%.2f", total.pl)
            default:
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

        var totalVal: Double = 0
        var totalGain: Double = 0
        var totalPL: Double = 0

        for (key, group) in grouped.sorted(by: { $0.key < $1.key }) {
            result.append(.groupHeader(key))
            result += group.map { .position($0) }

            let value = group.reduce(0) { $0 + $1.value }
            let gain = group.reduce(0) { $0 + $1.gain }
            let pl = group.reduce(0) { $0 + $1.plAbsolute }

            result.append(.subtotal("Total \(key)", SubtotalData(totalValue: value, gain: gain, pl: pl)))

            totalVal += value
            totalGain += gain
            totalPL += pl
        }

        result.append(.grandTotal(SubtotalData(totalValue: totalVal, gain: totalGain, pl: totalPL)))
        return result
    }
}

