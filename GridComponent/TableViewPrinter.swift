import Cocoa

class TableViewPrinter {
    
    static func print(tableView: NSTableView) {
        let viewToPrint = generatePrintableView(from: tableView)
        
        //let printInfo = NSPrintInfo.shared
        // Force landscape
        let printInfo = NSPrintInfo.shared.copy() as! NSPrintInfo
        printInfo.orientation = .landscape
        printInfo.topMargin = 20
        printInfo.bottomMargin = 20
        printInfo.leftMargin = 20
        printInfo.rightMargin = 20
        // magical instruction to scale horizontaly the content of the tableview
        printInfo.horizontalPagination = .fit
        printInfo.verticalPagination = .automatic
        printInfo.isHorizontallyCentered = true
        printInfo.isVerticallyCentered = false

        let printOperation = NSPrintOperation(view: viewToPrint, printInfo: printInfo)
        printOperation.showsPrintPanel = true
        printOperation.showsProgressPanel = true
        printOperation.run()
    }

    static func generatePrintableView(from originalTableView: NSTableView) -> NSView {
        guard let headerView = originalTableView.headerView else {
            return NSView()
        }

        guard let scrollView = originalTableView.enclosingScrollView,
              let originalDocumentView = scrollView.documentView else {
            return NSView()
        }

        let totalWidth = originalTableView.frame.width
        let headerHeight = headerView.frame.height
        let contentHeight = originalDocumentView.frame.height
        let totalHeight = headerHeight + contentHeight

        let container = NSView(frame: NSRect(x: 0, y: 0, width: totalWidth, height: totalHeight))

        // Copier la NSTableView
        let tableCopy = NSTableView(frame: originalTableView.frame)
        tableCopy.rowHeight = originalTableView.rowHeight
        tableCopy.gridStyleMask = originalTableView.gridStyleMask
        tableCopy.usesAlternatingRowBackgroundColors = originalTableView.usesAlternatingRowBackgroundColors
        tableCopy.intercellSpacing = originalTableView.intercellSpacing

        // Copier les colonnes
        for col in originalTableView.tableColumns {
            let newCol = NSTableColumn(identifier: col.identifier)
            newCol.title = col.title
            newCol.width = col.width
            // 👉 Modifier la font de l'en-tête
            // Copier et modifier le headerCell
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center // C'est le code qui parait fonctionner pour le centrage des titres

            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.boldSystemFont(ofSize: 14),
                .foregroundColor: NSColor.darkGray,
                .paragraphStyle: paragraphStyle
            ]

            let attributedTitle = NSAttributedString(string: col.title, attributes: attributes)

            let headerCell = col.headerCell.copy() as! NSTableHeaderCell
            headerCell.attributedStringValue = attributedTitle
            headerCell.alignment = col.headerCell.alignment // 👈 important not sure if it work maybe paragraphStyle the solution
            newCol.headerCell = headerCell

            
            tableCopy.addTableColumn(newCol)
        }

        // Copier la police si possible
        if let sampleCell = originalTableView.view(atColumn: 0, row: 0, makeIfNecessary: false) as? NSTextField {
            tableCopy.rowHeight = sampleCell.font?.pointSize ?? originalTableView.rowHeight
        }

        // Réutiliser dataSource et delegate
        tableCopy.delegate = originalTableView.delegate
        tableCopy.dataSource = originalTableView.dataSource
        tableCopy.headerView = nil // important : évite l'en-tête en double
        tableCopy.reloadData()

        // ScrollView contenant la copie de la table
        let scroll = NSScrollView(frame: NSRect(
            x: 0,
            y: 0,
            width: totalWidth,
            height: contentHeight
        ))
        scroll.documentView = tableCopy
        scroll.hasVerticalScroller = false
        scroll.hasHorizontalScroller = false
        scroll.borderType = .noBorder
        container.addSubview(scroll)

        // Ajouter une copie de l'en-tête au-dessus de la table
        let headerCopy = NSTableHeaderView(frame: NSRect(
            x: 0,
            y: contentHeight,
            width: totalWidth,
            height: headerHeight
        ))
        headerCopy.tableView = tableCopy
        container.addSubview(headerCopy)

        return container
    }
}

