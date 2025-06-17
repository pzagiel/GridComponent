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
    }

    struct Position {
        let symbol: String
        let currency: String
        let assetClass: String
        let quantity: Double
        let value: Double
        let gain: Double
    }

    struct SubtotalData {
        let totalValue: Double
        let gain: Double
    }

    let sampleData = [
        Position(symbol: "AAPL", currency: "USD", assetClass: "Tech", quantity: 10, value: 1000, gain: 50),
        Position(symbol: "MSFT", currency: "USD", assetClass: "Tech", quantity: 20, value: 2000, gain: 100),
        Position(symbol: "AIR", currency: "EUR", assetClass: "Aero", quantity: 30, value: 3000, gain: -200)
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
            ("Value", "value"),
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
            case "value": text.stringValue = String(format: "%.2f", p.value)
            case "gain": text.stringValue = String(format: "%.2f%%", p.gain)
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

        for (key, group) in grouped.sorted(by: { $0.key < $1.key }) {
            result.append(.groupHeader(key))
            result.append(contentsOf: group.map { .position($0) })

            let totalValue = group.reduce(0) { $0 + $1.value }
            let totalGain = group.reduce(0) { $0 + $1.gain }
            result.append(.subtotal("Total \(key)", SubtotalData(totalValue: totalValue, gain: totalGain)))
        }

        return result
    }
}
