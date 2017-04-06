import Foundation
import UIKit

extension UIViewController {
    
    var navigationManager : PANavigationManager {
        get {
            return PANavigationManager.sharedInstance
        }
    }
}
