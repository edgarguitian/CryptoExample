//
//  testApp.swift
//  test
//
//  Created by Edgar Guitian Rey on 10/9/24.
//

import SwiftUI
import SwiftData

@main
struct testApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Borrar portapapeles al entrar en background
        for (index, data) in UIPasteboard.general.items.enumerated() {
            for values in data.keys {
                UIPasteboard.general.items[index][values] = nil
            }
        }
        obfuscateMultitask()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        obfuscateMultitask()
    }
    
    func obfuscateMultitask() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        let blackViewController = UIViewController()
        blackViewController.view.backgroundColor = .black
        window.rootViewController?.present(blackViewController, animated: false, completion: nil)
    }
    
    func backFromMultitask() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        window.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        backFromMultitask()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        backFromMultitask()
    }
    
    
}
