//
//  AppDelegate.swift
//  GridComponent
//
//  Created by patrick zagiel on 17/06/2025.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!

    func applicationDidFinishLaunching(_ notification: Notification) {
        let viewController = ViewController()
        window = NSWindow(contentViewController: viewController)
        window.makeKeyAndOrderFront(nil)
    }
  

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

