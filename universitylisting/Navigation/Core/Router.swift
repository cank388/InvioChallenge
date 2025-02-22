//
//  Router.swift
//  universitylisting
//
//  Created by Can Kalender on 20.02.2025.
//

import UIKit

public protocol Router: AnyObject {
    
    var navigationController: UINavigationController { get set }
    
    func route(to viewController: UIViewController, animated: Bool, onDismissed: (() -> Void)?)
    func unroute(animated: Bool)
}
