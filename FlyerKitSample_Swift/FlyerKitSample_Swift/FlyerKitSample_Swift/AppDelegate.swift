import Foundation
import UIKit

let urlSession = {
  return URLSession(
    configuration: URLSessionConfiguration.default, delegate: nil,
    delegateQueue: OperationQueue.main)
}()

let flippApiManager = FlippApiManager()
let loyaltyCardManager = LoyaltyCardManager()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  fileprivate lazy var appWindow: UIWindow = {
    let window = UIWindow(frame: UIScreen.main.bounds)
    
    let navController = UINavigationController(rootViewController: PostalCodeViewController())
    window.rootViewController = navController
    
    return window
  }()
  
  func applicationDidFinishLaunching(_ application: UIApplication) {
    appWindow.makeKeyAndVisible()
  }
}
