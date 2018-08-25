//
//  UIViewExtension.swift
//  mensa-tu-dresden
//
//  Created by Philipp Matthes on 25.08.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit
import Material

fileprivate var indicatorViewAssociativeKey = "ActivityIndicatorViewAssociativeKey"

extension NSObject {
    func setAssociatedObject(_ value: AnyObject?, associativeKey: UnsafeRawPointer, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        guard let value = value else {return}
        objc_setAssociatedObject(self, associativeKey, value, policy)
    }
    
    func getAssociatedObject(_ associativeKey: UnsafeRawPointer) -> Any? {
        return objc_getAssociatedObject(self, associativeKey)
    }
}

extension UIView {
    var activityIndicatorView: UIActivityIndicatorView {
        get {
            if let activityIndicatorView = getAssociatedObject(&indicatorViewAssociativeKey) as? UIActivityIndicatorView {
                return activityIndicatorView
            }
            let activityIndicatorView = UIActivityIndicatorView()
            activityIndicatorView.style = .gray
            activityIndicatorView.color = Colors.backgroundColor
            activityIndicatorView.center = center
            activityIndicatorView.hidesWhenStopped = true
            layout(activityIndicatorView).center()
            setAssociatedObject(activityIndicatorView, associativeKey: &indicatorViewAssociativeKey)
            return activityIndicatorView
        }
        set {
            addSubview(newValue)
            setAssociatedObject(newValue, associativeKey: &indicatorViewAssociativeKey)
        }
    }
    
}
