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
        case groupHeader(label: String, key: String, subtotal: SubtotalData?)
        case position(Position)
        case subtotal(String, SubtotalData)
        case grandTotal(SubtotalData)
    }

    struct SubtotalData {
        let totalValue: Double
        let pl: Double
        let weight: Double
    }

    var rows: [Row] = []
    var totalPortfolioValue: Double = 0
    let sampleData: [Position] = PortfolioData.shared.samplePositions
    var groupExpandedState: [String: Bool] = [:]

    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 1300, height: 900))

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

        NSLayoutConstraint.activate([
            groupByPopup.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10),
            groupByPopup.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            groupByPopup.widthAnchor.constraint(equalToConstant: 200),
            groupByPopup.heightAnchor.constraint(equalToConstant: 24),

            fontSizePopup.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10),
            fontSizePopup.leadingAnchor.constraint(equalTo: groupByPopup.trailingAnchor, constant: 20),
            fontSizePopup.widthAnchor.constraint(equalToConstant: 100),
            fontSizePopup.heightAnchor.constraint(equalToConstant: 24),

            showHeaderCheckbox.centerYAnchor.constraint(equalTo: groupByPopup.centerYAnchor),
            showHeaderCheckbox.leadingAnchor.constraint(equalTo: fontSizePopup.trailingAnchor, constant: 20),

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

        tableView.target = self
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))

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
        NSFontManager.shared.target = self
        rows = buildRows(from: sampleData, showHeader: showGroupHeaders) { $0.assetClass }
        tableView.reloadData()
        autoResizeAllColumns()
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

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return gridFontSize + 6
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
        case .groupHeader(let label, _, let subtotalOpt):
            switch columnIdentifier {
            case "name":
                text.stringValue = label
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
    
    @objc func changeFont(_ sender: NSFontManager?) {
          guard let manager = sender else { return }

          gridFont = manager.convert(gridFont)
          gridFontSize = gridFont.pointSize
          tableView.reloadData()
          autoResizeAllColumns()
      }
    @IBAction func printDocument(_ sender: Any?) {
         TableViewPrinter.print(tableView: self.tableView)
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

    @objc func tableViewDoubleClick(_ sender: Any) {
        let row = tableView.clickedRow
        guard row >= 0 else { return }

        switch rows[row] {
        case .groupHeader(_, let key, _):
            let currentState = groupExpandedState[key] ?? true
            groupExpandedState[key] = !currentState

            rows = buildRows(from: sampleData, showHeader: showGroupHeaders) { pos in
                switch groupByPopup.titleOfSelectedItem {
                case "Currency": return pos.currency
                default: return pos.assetClass
                }
            }
            tableView.reloadData()
        default:
            break
        }
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

            if groupExpandedState[key] == nil {
                groupExpandedState[key] = true
            }

            if showHeader {
                result.append(.groupHeader(label: label, key: key, subtotal: showSubtotalsInHeaders ? subtotalData : nil))
            }

            if groupExpandedState[key] == true {
                result += group.map { .position($0) }
            }

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

