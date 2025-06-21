import Cocoa

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    var tableView: NSTableView!
    var scrollView: NSScrollView!
    var groupByPopup: NSPopUpButton!
    var fontSizePopup: NSPopUpButton!
    var showHeaderCheckbox: NSButton!
    var showSubtotalsInHeadersCheckbox: NSButton!
    var gridFontSize: CGFloat = 16
    var gridFont: NSFont = NSFont(name: "Times-Roman", size: 16) ?? NSFont.systemFont(ofSize: 16)
    var showGroupHeaders = false
    var showSubtotalsInHeaders = true

    enum Row {
        case groupHeader(String, SubtotalData?)
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
        let pl: Double
        let weight: Double
    }

    var rows: [Row] = []

    var totalPortfolioValue: Double = 0

    let sampleData: [Position] = [
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

    @objc func changeFont(_ sender: NSFontManager?) {
        guard let manager = sender else { return }

        gridFont = manager.convert(gridFont)
        gridFontSize = gridFont.pointSize
        tableView.reloadData()
        autoResizeAllColumns()
    }
    
    @IBAction func runPageLayout(_ sender: Any?) {
        let pageLayout = NSPageLayout()
        let printInfo = NSPrintInfo.shared
        pageLayout.runModal(with: printInfo)
    }
    
    @IBAction func printDocumentOld(_ sender: Any?) {
        let printInfo = NSPrintInfo.shared
        printInfo.orientation = .landscape
        printInfo.topMargin = 20
        printInfo.leftMargin = 20
        printInfo.rightMargin = 20
        printInfo.bottomMargin = 20

        let printView = PrintDocument(tableView: tableView, printInfo: printInfo)
        let printOperation = NSPrintOperation(view: printView, printInfo: printInfo)
        printOperation.run()
    }
    
    @IBAction func printDocument(_ sender: Any?) {
        TableViewPrinter.print(tableView: self.tableView)
    }

    func viewForPrinting() -> NSView {
        let headerView = tableView.headerView!
        let contentView = tableView.enclosingScrollView!.documentView!

        let totalHeight = headerView.frame.height + contentView.frame.height
        let totalWidth = contentView.frame.width

        let containerView = NSView(frame: NSRect(x: 0, y: 0, width: totalWidth, height: totalHeight))

        let headerCopy = NSTableHeaderView(frame: headerView.frame)
        headerCopy.tableView = tableView
        headerCopy.frame.origin = .zero
        containerView.addSubview(headerCopy)

        let tableCopy = NSTableView(frame: tableView.frame)
        for column in tableView.tableColumns {
            tableCopy.addTableColumn(column)
        }
        tableCopy.delegate = tableView.delegate
        tableCopy.dataSource = tableView.dataSource
        tableCopy.headerView = nil
        tableCopy.reloadData()

        let scroll = NSScrollView(frame: NSRect(x: 0, y: headerView.frame.height, width: totalWidth, height: contentView.frame.height))
        scroll.documentView = tableCopy
        scroll.hasVerticalScroller = false
        scroll.hasHorizontalScroller = false
        scroll.borderType = .noBorder
        containerView.addSubview(scroll)

        return containerView
    }

    func loadViewOld() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 1300, height: 800))

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

        showHeaderCheckbox = NSButton(checkboxWithTitle: "Show Headers", target: self, action: #selector(showHeaderToggled(_:)))
        showHeaderCheckbox.translatesAutoresizingMaskIntoConstraints = false
        showHeaderCheckbox.state = showGroupHeaders ? .on : .off
        self.view.addSubview(showHeaderCheckbox)

        NSLayoutConstraint.activate([
            showHeaderCheckbox.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10),
            showHeaderCheckbox.leadingAnchor.constraint(equalTo: fontSizePopup.trailingAnchor, constant: 20),
            showHeaderCheckbox.widthAnchor.constraint(equalToConstant: 250),
            showHeaderCheckbox.heightAnchor.constraint(equalToConstant: 24)
        ])

        showSubtotalsInHeadersCheckbox = NSButton(checkboxWithTitle: "Show Subtotals in Headers", target: self, action: #selector(showSubtotalsInHeadersToggled(_:)))
        showSubtotalsInHeadersCheckbox.translatesAutoresizingMaskIntoConstraints = false
        showSubtotalsInHeadersCheckbox.state = showSubtotalsInHeaders ? .on : .off
        self.view.addSubview(showSubtotalsInHeadersCheckbox)

        NSLayoutConstraint.activate([
            showSubtotalsInHeadersCheckbox.topAnchor.constraint(equalTo: showHeaderCheckbox.bottomAnchor, constant: 10),
            showSubtotalsInHeadersCheckbox.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            showSubtotalsInHeadersCheckbox.widthAnchor.constraint(equalToConstant: 250),
            showSubtotalsInHeadersCheckbox.heightAnchor.constraint(equalToConstant: 24)
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
        tableView.sizeToFit()

        let columns = [
            ("Name", "name"),
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
            if let headerCell = column.headerCell as? NSTableHeaderCell {
                headerCell.alignment = .center
            }
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
    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 1300, height: 900)) // hauteur suffisante

        groupByPopup = NSPopUpButton()
        groupByPopup.translatesAutoresizingMaskIntoConstraints = false
        groupByPopup.addItems(withTitles: ["Asset Class", "Currency"])
        groupByPopup.target = self
        groupByPopup.action = #selector(groupingChanged(_:))
        self.view.addSubview(groupByPopup)

        fontSizePopup = NSPopUpButton()
        fontSizePopup.translatesAutoresizingMaskIntoConstraints = false
        fontSizePopup.addItems(withTitles: ["12","13","14","15","16","17","18","20","22","24"])
        fontSizePopup.selectItem(withTitle: "\(Int(gridFontSize))")
        fontSizePopup.target = self
        fontSizePopup.action = #selector(fontSizeChanged(_:))
        self.view.addSubview(fontSizePopup)

        showHeaderCheckbox = NSButton(checkboxWithTitle: "Show Headers", target: self, action: #selector(showHeaderToggled(_:)))
        showHeaderCheckbox.translatesAutoresizingMaskIntoConstraints = false
        showHeaderCheckbox.state = showGroupHeaders ? .on : .off
        self.view.addSubview(showHeaderCheckbox)

        showSubtotalsInHeadersCheckbox = NSButton(checkboxWithTitle: "Show Subtotals in Headers", target: self, action: #selector(showSubtotalsInHeadersToggled(_:)))
        showSubtotalsInHeadersCheckbox.translatesAutoresizingMaskIntoConstraints = false
        showSubtotalsInHeadersCheckbox.state = showSubtotalsInHeaders ? .on : .off
        self.view.addSubview(showSubtotalsInHeadersCheckbox)

        // Contraintes :

        NSLayoutConstraint.activate([
            // groupByPopup en haut à gauche
            groupByPopup.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10),
            groupByPopup.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            groupByPopup.widthAnchor.constraint(equalToConstant: 200),
            groupByPopup.heightAnchor.constraint(equalToConstant: 24),

            // fontSizePopup à droite de groupByPopup
            fontSizePopup.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10),
            fontSizePopup.leadingAnchor.constraint(equalTo: groupByPopup.trailingAnchor, constant: 20),
            fontSizePopup.widthAnchor.constraint(equalToConstant: 100),
            fontSizePopup.heightAnchor.constraint(equalToConstant: 24),

            // showHeaderCheckbox à droite de fontSizePopup (marge 20)
            showHeaderCheckbox.centerYAnchor.constraint(equalTo: groupByPopup.centerYAnchor),
            showHeaderCheckbox.leadingAnchor.constraint(equalTo: fontSizePopup.trailingAnchor, constant: 20),

            // showSubtotalsInHeadersCheckbox à droite de showHeaderCheckbox (marge 20)
            showSubtotalsInHeadersCheckbox.centerYAnchor.constraint(equalTo: groupByPopup.centerYAnchor),
            showSubtotalsInHeadersCheckbox.leadingAnchor.constraint(equalTo: showHeaderCheckbox.trailingAnchor, constant: 20),
        ])

        scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.autoresizingMask = [.width, .height]
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = false
        scrollView.automaticallyAdjustsContentInsets = false

        tableView = NSTableView(frame: scrollView.bounds)
        tableView.rowHeight = 20
        tableView.gridStyleMask = [.solidVerticalGridLineMask, .solidHorizontalGridLineMask]
        tableView.usesAlternatingRowBackgroundColors = false
        tableView.sizeToFit()

        let columns = [
            ("Name", "name"),
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
            if let headerCell = column.headerCell as? NSTableHeaderCell {
                headerCell.alignment = .center
            }
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



    func autoResizeAllColumns() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            for column in self.tableView.tableColumns {
                self.autoResizeColumn(column, in: self.tableView)
            }
        }
    }

    func autoResizeColumn(_ column: NSTableColumn, in tableView: NSTableView) {
        let columnIndex = tableView.tableColumns.firstIndex(of: column) ?? 0
        let headerWidth = (column.headerCell.stringValue as NSString).size(withAttributes: [.font: NSFont.systemFont(ofSize: NSFont.systemFontSize)]).width

        var maxWidth: CGFloat = headerWidth

        for row in 0..<tableView.numberOfRows {
            guard let view = tableView.view(atColumn: columnIndex, row: row, makeIfNecessary: true) as? NSTextField else { continue }
            let text = view.stringValue as NSString
            let font = view.font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
            let textWidth = text.size(withAttributes: [.font: font]).width
            maxWidth = max(maxWidth, textWidth)
        }

        column.width = maxWidth + 20
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NSFontManager.shared.target = self
        rows = buildRows(from: sampleData, showHeader: showGroupHeaders) { $0.assetClass }
        tableView.reloadData()
        autoResizeAllColumns()
    }

    func euroFormat(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "€"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "fr_BE")
        formatter.usesGroupingSeparator = true
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
        text.font = gridFont

        guard let columnIdentifier = tableColumn?.identifier.rawValue else { return text }

        if ["quantity", "costPrice", "price", "evol", "gain", "pl", "value", "weight"].contains(columnIdentifier) {
            text.alignment = .right
        }

        switch rows[row] {
        case .groupHeader(let title, let subtotalOpt):
            switch columnIdentifier {
            case "name":
                text.stringValue = title
                text.font = NSFont.boldSystemFont(ofSize: gridFontSize + 2)
                text.textColor = .systemOrange
            case "value":
                text.stringValue = subtotalOpt != nil ? euroFormat(subtotalOpt!.totalValue) : ""
                text.font = NSFont.boldSystemFont(ofSize: gridFontSize)
                text.textColor = .systemOrange
            case "pl":
                text.stringValue = subtotalOpt != nil ? euroFormat(subtotalOpt!.pl) : ""
                text.font = NSFont.boldSystemFont(ofSize: gridFontSize)
                text.textColor = .systemOrange
            case "weight":
                text.stringValue = subtotalOpt != nil ? percentFormat(subtotalOpt!.weight * 100) : ""
                text.font = NSFont.boldSystemFont(ofSize: gridFontSize)
                text.textColor = .systemOrange
            default:
                text.stringValue = ""
            }

        case .position(let p):
            switch columnIdentifier {
            case "name": text.stringValue = p.symbol
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
            case "name":
                text.stringValue = label
                text.font = NSFontManager.shared.convert(gridFont, toHaveTrait: .boldFontMask)
                text.textColor = .systemBlue
            case "value":
                text.stringValue = euroFormat(subtotal.totalValue)
                text.font = NSFontManager.shared.convert(gridFont, toHaveTrait: .boldFontMask)
                text.textColor = .systemBlue
            case "pl":
                text.stringValue = euroFormat(subtotal.pl)
                text.font = NSFontManager.shared.convert(gridFont, toHaveTrait: .boldFontMask)
                text.textColor = .systemBlue
            case "weight":
                text.stringValue = percentFormat(subtotal.weight * 100)
                text.font = NSFontManager.shared.convert(gridFont, toHaveTrait: .boldFontMask)
                text.textColor = .systemBlue
            default:
                text.stringValue = ""
            }

        case .grandTotal(let total):
            switch columnIdentifier {
            case "name":
                text.stringValue = "Total"
                text.font = NSFontManager.shared.convert(gridFont, toHaveTrait: .boldFontMask)
                text.textColor = .systemBlue
            case "value":
                text.stringValue = euroFormat(total.totalValue)
                text.font = NSFontManager.shared.convert(gridFont, toHaveTrait: .boldFontMask)
                text.textColor = .systemBlue
            case "pl":
                text.stringValue = euroFormat(total.pl)
                text.font = NSFontManager.shared.convert(gridFont, toHaveTrait: .boldFontMask)
                text.textColor = .systemBlue
            case "weight":
                text.stringValue = percentFormat(total.weight * 100)
                text.font = NSFontManager.shared.convert(gridFont, toHaveTrait: .boldFontMask)
                text.textColor = .systemBlue
            default:
                text.stringValue = ""
            }
        }

        return text
    }

    @objc func groupingChanged(_ sender: NSPopUpButton) {
        switch sender.titleOfSelectedItem {
        case "Currency":
            rows = buildRows(from: sampleData, showHeader: showGroupHeaders) { $0.currency }
        default:
            rows = buildRows(from: sampleData, showHeader: showGroupHeaders) { $0.assetClass }
        }
        tableView.reloadData()
        autoResizeAllColumns()
    }
    
    @objc func fontSizeChanged(_ sender: NSPopUpButton) {
        if let selected = sender.titleOfSelectedItem,
           let selectedInt = Int(selected) {
            gridFontSize = CGFloat(selectedInt)
            tableView.reloadData()
        }
    }
    
    @objc func showHeaderToggled(_ sender: NSButton) {
        showGroupHeaders = (sender.state == .on)
        groupingChanged(groupByPopup)
    }

    @objc func showSubtotalsInHeadersToggled(_ sender: NSButton) {
        showSubtotalsInHeaders = (sender.state == .on)
        groupingChanged(groupByPopup)
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return gridFontSize + 6
    }

    func buildRows(from positions: [Position], showHeader: Bool, groupedBy: (Position) -> String) -> [Row] {
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
        var totalWeight: Double = 0

        for (key, group) in grouped.sorted(by: { $0.key < $1.key }) {
            let value = group.reduce(0) { $0 + $1.value }
            let gain = group.reduce(0) { $0 + $1.gain }
            let pl = group.reduce(0) { $0 + $1.plAbsolute }
            let weight = group.reduce(0) { $0 + $1.weight }
            let label = key.count > 3 ? String(key.dropFirst(3)) : key
            let subtotalData = SubtotalData(totalValue: value, pl: pl, weight: weight)

            if showHeader {
                result.append(.groupHeader(label, showSubtotalsInHeaders ? subtotalData : nil))
            }

            result += group.map { .position($0) }

            if !showSubtotalsInHeaders {
                result.append(.subtotal("Total \(label)", subtotalData))
            }

            totalVal += value
            totalGain += gain
            totalPL += pl
            totalWeight += weight
        }

        result.append(.grandTotal(SubtotalData(totalValue: totalVal, pl: totalPL, weight: totalWeight)))
        return result
    }
}

