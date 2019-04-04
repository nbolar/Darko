//
//  AppDelegate.swift
//  Darko
//
//  Created by Nikhil Bolar on 4/2/19.
//  Copyright © 2019 Nikhil Bolar. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let menu = NSMenu()
    var overlays: [NSWindow] = []


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        menu.addItem(withTitle: "Switch Appearance", action: #selector(darko), keyEquivalent: "")
        menu.addItem(withTitle: "Quit", action: #selector(NSApp.terminate(_:)), keyEquivalent: "q")
        
        let statusButton = statusItem.button
        statusButton?.image = NSImage(named: "darko")
        statusButton?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        statusButton?.action = #selector(menuClicked)
        
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @objc func menuClicked(sender: NSStatusBarButton)
    {

        guard let clickedEvent = NSApp.currentEvent else { return }
        
        if clickedEvent.type == .leftMouseUp
        {
            initialView()
            switchAppearance()
            fadedView()
            
        } else if clickedEvent.type == .rightMouseUp
        {
            statusItem.menu = menu
            statusItem.button?.performClick(sender)
            statusItem.menu = nil
        }
    
    }
    @objc func darko()
    {
        switchAppearance()
    }
    
    func switchAppearance() {
        guard let scriptURL = Bundle.main.url(forResource: "SwitchAppearance", withExtension: "scpt") else { return }
        let script = NSAppleScript(contentsOf: scriptURL, error: nil)
        var error: NSDictionary?
        script?.executeAndReturnError(&error)
        if (error != nil) { print(String(describing: error!)) }
    }
    
    func initialView() {
        overlays = NSScreen.screens.map { screen in
            let imageView = NSImageView(image: screen.snapshot())
            let overlay = NSWindow(contentRect: screen.frame,
                                   styleMask: .borderless,
                                   backing: .buffered,
                                   defer: false,
                                   screen: screen)
            overlay.isReleasedWhenClosed = false
            overlay.level = .screenSaver
            overlay.contentView = imageView
            overlay.makeKeyAndOrderFront(nil)
            return overlay
        }
    }
    
    func fadedView() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.8
                self.overlays.forEach {
                    $0.animator().alphaValue = 0
                }
            }, completionHandler: {
                self.overlays.forEach {
                    $0.resignKey()
                    $0.close()
                }
                self.overlays.removeAll()
            })
        }
    }
    


}



extension NSScreen {
    
    func snapshot() -> NSImage {
        guard let cgImage = CGWindowListCreateImage(frame, .optionOnScreenOnly, kCGNullWindowID, .bestResolution) else {
            fatalError("Unable to capture Screenshot")
        }
        
        let bitmapRepresentation = NSBitmapImageRep(cgImage: cgImage)
        let image = NSImage()
        image.addRepresentation(bitmapRepresentation)
        return image
    }
    
}

