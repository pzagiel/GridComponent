// PrintDocument.swift

import Cocoa

class PrintDocument: NSView {
    let tableView: NSTableView
    let printInfo: NSPrintInfo
    var scale: CGFloat = 1.0

    init(tableView: NSTableView, printInfo: NSPrintInfo) {
        self.tableView = tableView
        self.printInfo = printInfo

        let headerHeight = tableView.headerView?.frame.height ?? 0
        let contentHeight = tableView.bounds.height
        let totalHeight = headerHeight + contentHeight
        let totalSize = NSSize(width: tableView.bounds.width, height: totalHeight)

        super.init(frame: NSRect(origin: .zero, size: totalSize))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func beginDocument() {
        super.beginDocument()

        let paperWidth = printInfo.paperSize.width
        let leftMargin = printInfo.leftMargin
        let rightMargin = printInfo.rightMargin
        let printableWidth = paperWidth - leftMargin - rightMargin

        let contentWidth = tableView.bounds.width

        if contentWidth > 0 {
            scale = min(1.0, printableWidth / contentWidth)
        } else {
            scale = 1.0
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard let context = NSGraphicsContext.current?.cgContext else { return }

        let imageableBounds = printInfo.imageablePageBounds

        context.saveGState()

        // Centrage horizontal
        let paperWidth = printInfo.paperSize.width
        let leftMargin = printInfo.leftMargin
        let rightMargin = printInfo.rightMargin
        let topMargin = printInfo.topMargin
        let printableWidth = paperWidth - leftMargin - rightMargin
        let contentWidth = tableView.bounds.width * scale
        let horizontalOffset = (printableWidth - contentWidth) / 2 + leftMargin

        // Décalage vertical depuis le haut de la page
        let paperHeight = printInfo.paperSize.height
        let contentHeight = tableView.bounds.height * scale
        let verticalOffset = paperHeight - topMargin - contentHeight

        context.translateBy(x: horizontalOffset, y: verticalOffset)
        context.scaleBy(x: scale, y: scale)

        // Dessiner la tableView dans un contexte bitmap temporaire
        let renderBounds = CGRect(origin: .zero, size: tableView.bounds.size)
        if let bitmapRep = tableView.bitmapImageRepForCachingDisplay(in: renderBounds) {
            tableView.cacheDisplay(in: renderBounds, to: bitmapRep)
            bitmapRep.draw(in: renderBounds)
        }

        context.restoreGState()
    }
}

