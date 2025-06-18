import Cocoa

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    var tableView: NSTableView!
    var scrollView: NSScrollView!
    var groupByPopup: NSPopUpButton!
    var fontSizePopup: NSPopUpButton!
    var gridFontSize: CGFloat = 16
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
        var weight: Double = 0

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

    var totalPortfolioValue: Double = 0

    let sampleData: [Position] = [
        Position(symbol: "H2O Vivace FCP R", currency: "EUR", assetClass: "Hedge Fund", quantity: 18, costPrice: 63378.95, date: "13-Jun-2025", price: 81971.19, evol: -0.89, gain: 29.38),
        Position(symbol: "H2O Vivace HUSD-R", currency: "USD", assetClass: "Hedge Fund", quantity: 56, costPrice: 30330.59, date: "13-Jun-2025", price: 45303.32, evol: -0.54, gain: 49.37),
        Position(symbol: "Airbus SE", currency: "EUR", assetClass: "Action", quantity: 1200, costPrice: 83.54, date: "17-Jun-2025", price: 160.74, evol: -0.79, gain: 3.85),
        Position(symbol: "Alibaba Group", currency: "USD", assetClass: "Action", quantity: 2950, costPrice: 182.70, date: "17-Jun-2025", price: 115.38, evol: -0.50, gain: 36.08),
        Position(symbol: "Align Technology", currency: "USD", assetClass: "Action", quantity: 1000, costPrice: 319.78, date: "17-Jun-2025", price: 174.66, evol: -4.31, gain: -45.38),
        Position(symbol: "Amazon Inc", currency: "USD", assetClass: "Action", quantity: 3600, costPrice: 79.42, date: "17-Jun-2025", price: 215.39, evol: -0.33, gain: -1.82),
        Position(symbol: "ING Groep NV", currency: "EUR", assetClass: "Action", quantity: 20600, costPrice: 8.59, date: "13-Jun-2025", price: 17.916, evol: -1.38, gain: 18.41),
        Position(symbol: "JD.com Inc", currency: "USD", assetClass: "Action", quantity: 4000, costPrice: 45.08, date: "17-Jun-2025", price: 33.295, evol: -0.55, gain: -3.97),
        Position(symbol: "Micron Technology", currency: "USD", assetClass: "Action", quantity: 7000, costPrice: 57.20, date: "17-Jun-2025", price: 202.4444, evol: 0.50, gain: 22.20),
        Position(symbol: "MongoDB Inc", currency: "USD", assetClass: "Action", quantity: 300, costPrice: 413.28, date: "17-Jun-2025", price: 206.67, evol: 2.06, gain: -11.23),
        Position(symbol: "Palo Alto Networks", currency: "USD", assetClass: "Action", quantity: 5400, costPrice: 41.40, date: "17-Jun-2025", price: 201.515, evol: 1.72, gain: 10.75),
        Position(symbol: "STMicroelectronics", currency: "EUR", assetClass: "Action", quantity: 4500, costPrice: 33.42, date: "17-Jun-2025", price: 25.245, evol: -1.33, gain: 4.00),
        Position(symbol: "Starbucks Corp", currency: "USD", assetClass: "Action", quantity: 961, costPrice: 88.62, date: "17-Jun-2025", price: 91.24, evol: -2.40, gain: -0.01),
        Position(symbol: "TSMC", currency: "USD", assetClass: "Action", quantity: 1450, costPrice: 139.74, date: "17-Jun-2025", price: 214.16, evol: -0.70, gain: 8.44),
        Position(symbol: "UBS Group AG", currency: "CHF", assetClass: "Action", quantity: 3000, costPrice: 16.67, date: "17-Jun-2025", price: 25.84, evol: -1.07, gain: -6.82),
        Position(symbol: "Gold Bullion", currency: "USD", assetClass: "Gold", quantity: 1378, costPrice: 125.65, date: "17-Jun-2025", price: 310.08, evol: -0.71, gain: 29.26),
        Position(symbol: "CHF", currency: "CHF", assetClass: "Cash", quantity: 1578, costPrice: 1.0, date: "-", price: 1.0, evol: 0.00, gain: 0.00),
        Position(symbol: "EURO", currency: "EUR", assetClass: "Cash", quantity: 292683, costPrice: 1.0, date: "-", price: 1.0, evol: 0.00, gain: 0.00),
        Position(symbol: "GBP", currency: "GBP", assetClass: "Cash", quantity: 39, costPrice: 1.0, date: "-", price: 1.0, evol: 0.00, gain: 0.00),
        Position(symbol: "JPY Cash", currency: "JPY", assetClass: "Cash", quantity: 2220427, costPrice: 1.0, date: "-", price: 1.0, evol: 0.00, gain: 0.00),
        Position(symbol: "USD Dollar", currency: "USD", assetClass: "Cash", quantity: 609318, costPrice: 1.0, date: "-", price: 1.0, evol: 0.00, gain: 0.00)
    ]

    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 1200, height: 800))
        //self.view.appearance = NSAppearance(named: .aqua)

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
        
        // FontSize PopupUp menu
        fontSizePopup = NSPopUpButton()
        fontSizePopup.translatesAutoresizingMaskIntoConstraints = false
        fontSizePopup.addItems(withTitles: ["12","13","14","15","16","17","18","20","22","24"])
        fontSizePopup.selectItem(withTitle: "\(Int(gridFontSize))")
        fontSizePopup.target = self
        fontSizePopup.action = #selector(fontSizeChanged(_:))
        self.view.addSubview(fontSizePopup)

        NSLayoutConstraint.activate([
            fontSizePopup.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10),
            fontSizePopup.leadingAnchor.constraint(equalTo: groupByPopup.trailingAnchor, constant: 20),
            fontSizePopup.widthAnchor.constraint(equalToConstant: 100),
            fontSizePopup.heightAnchor.constraint(equalToConstant: 24)
        ])

        
        scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.autoresizingMask = [.width, .height]
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = false
        scrollView.automaticallyAdjustsContentInsets = false
        scrollView.documentView = tableView



        tableView = NSTableView(frame: scrollView.bounds)
        tableView.rowHeight = 20
        tableView.gridStyleMask = [.solidVerticalGridLineMask, .solidHorizontalGridLineMask]
        tableView.usesAlternatingRowBackgroundColors = false
        //tableView.gridColor = .lightGray

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
            ("Mkt Val", "value"),
            ("Weight", "weight")
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

    func euroFormat(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "€"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "fr_BE")
        return formatter.string(from: NSNumber(value: amount)) ?? String(format: "%.2f", amount)
    }

    func percentFormat(_ value: Double) -> String {
        return String(format: "%.2f%%", value)
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return rows.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let text = NSTextField()
        text.isBordered = false
        text.isEditable = false
        text.backgroundColor = .clear
        text.font = NSFont(name: "Times-Roman", size: gridFontSize)

        guard let columnIdentifier = tableColumn?.identifier.rawValue else { return text }

        if ["quantity", "costPrice", "price", "evol", "gain", "pl", "value", "weight"].contains(columnIdentifier) {
            text.alignment = .right
        }

        switch rows[row] {
        case .groupHeader(let title):
            text.stringValue = columnIdentifier == "symbol" ? title : ""
            if columnIdentifier == "symbol" {
                text.font = NSFont.boldSystemFont(ofSize: gridFontSize)
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
                text.stringValue = percentFormat(p.evol)
                text.textColor = p.evol >= 0 ? .systemGreen : .systemRed
            case "gain":
                text.stringValue = percentFormat(p.gain)
                text.textColor = p.gain >= 0 ? .systemGreen : .systemRed
            case "pl": text.stringValue = euroFormat(p.plAbsolute)
            case "value": text.stringValue = euroFormat(p.value)
            case "weight": text.stringValue = percentFormat(p.weight * 100)
            default: text.stringValue = ""
            }

        case .subtotal(let label, let subtotal):
            switch columnIdentifier {
            case "symbol":
                text.stringValue = label
                text.font = NSFont.boldSystemFont(ofSize: gridFontSize)
                text.textColor = .systemBlue
            case "value": text.stringValue = euroFormat(subtotal.totalValue)
            case "gain":
                text.stringValue = percentFormat(subtotal.gain)
                text.textColor = subtotal.gain >= 0 ? .systemGreen : .systemRed
            case "pl": text.stringValue = euroFormat(subtotal.pl)
            default: text.stringValue = ""
            }

        case .grandTotal(let total):
            switch columnIdentifier {
            case "symbol":
                text.stringValue = "Total Portfolio"
                text.font = NSFont.boldSystemFont(ofSize: gridFontSize)
                text.textColor = .systemBlue
            case "value": text.stringValue = euroFormat(total.totalValue)
            case "gain":
                text.stringValue = percentFormat(total.gain)
                text.textColor = total.gain >= 0 ? .systemGreen : .systemRed
            case "pl": text.stringValue = euroFormat(total.pl)
            default: text.stringValue = ""
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
    
    @objc func fontSizeChanged(_ sender: NSPopUpButton) {
        if let selected = sender.titleOfSelectedItem,
           let selectedInt = Int(selected) {
            gridFontSize = CGFloat(selectedInt)
            tableView.reloadData()
        }
    }
    
    // adjust height of rows dynamicaly
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return gridFontSize + 6 // ajustement souple (padding vertical)
    }

    
    func buildRows(from positions: [Position], groupedBy: (Position) -> String) -> [Row] {
        var enrichedPositions = positions
        let total = enrichedPositions.reduce(0) { $0 + $1.value }
        totalPortfolioValue = total

        for i in 0..<enrichedPositions.count {
            enrichedPositions[i].weight = enrichedPositions[i].value / total
        }

        let grouped = Dictionary(grouping: enrichedPositions, by: groupedBy)
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

