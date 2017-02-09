//
//  PAAutoLayoutExtension.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 11/26/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func alignToTopOfParent(with margin : CGFloat) {
        alignToTop(of: self.superview!, margin: margin, multiplier: 1)
    }
    
    func alignToTop(of view: UIView, margin : CGFloat, multiplier : CGFloat) {
        
        let constraint = NSLayoutConstraint(    item: self,
                                                attribute: .top,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: .top,
                                                multiplier: multiplier,
                                                constant: margin)
        
        self.superview!.addConstraint( constraint )
    }
    
    func alignToBottomOfParent(with margin : CGFloat) {
        alignToBottom(of: self.superview!, margin: margin)
    }
    
    func alignToBottom(of view: UIView, margin : CGFloat) {
        let constraint = NSLayoutConstraint(    item: self,
                                                attribute: .bottom,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: .bottom,
                                                multiplier: 1,
                                                constant: margin)
        
        self.superview!.addConstraint(constraint)
    }
    
    func alignToLeftOfParent(with margin : CGFloat) {
        alignToLeft(of: self.superview!, margin: margin)
    }
    
    func alignToLeft(of view: UIView, margin : CGFloat) {
        let constraint = NSLayoutConstraint(    item: self,
                                                attribute: .left,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: .left,
                                                multiplier: 1,
                                                constant: margin)
        
        self.superview!.addConstraint(constraint)
    }
    
    func alignToRightOfParent(with margin : CGFloat) {
        alignToRight(of: self.superview!, margin: margin)
    }
    
    func alignToRight(of view: UIView, margin : CGFloat) {
        let constraint = NSLayoutConstraint(    item: self,
                                                attribute: .right,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: .right,
                                                multiplier: 1,
                                                constant: margin)
        
        self.superview!.addConstraint(constraint)
    }
    
    func alignToParent(with margin : CGFloat ) {
        translatesAutoresizingMaskIntoConstraints = false
        
        alignToTopOfParent(with: margin)
        alignToBottomOfParent(with: margin)
        alignToLeftOfParent(with: margin)
        alignToRightOfParent(with: margin)
        
    }
    
    func setHeight(_ height : CGFloat) {
        
        let constraint = NSLayoutConstraint(    item: self,
                                                attribute: .height,
                                                relatedBy: .equal,
                                                toItem: nil,
                                                attribute: .notAnAttribute,
                                                multiplier: 1,
                                                constant: height)
        
        self.superview!.addConstraint(constraint)
    }
    
    func setMaxHeight(_ maxHeight : CGFloat) {
        
        let constraint = NSLayoutConstraint(    item: self,
                                                attribute: .height,
                                                relatedBy: .lessThanOrEqual,
                                                toItem: nil,
                                                attribute: .notAnAttribute,
                                                multiplier: 1,
                                                constant: maxHeight)
        
        self.superview!.addConstraint(constraint)
    }
    
    func setWidth(_ width : CGFloat) {
        
        let constraint = NSLayoutConstraint(    item: self,
                                                attribute: .width,
                                                relatedBy: .equal,
                                                toItem: nil,
                                                attribute: .notAnAttribute,
                                                multiplier: 1,
                                                constant: width)
        
        self.superview!.addConstraint(constraint)
    }
    
    func centerHorizontally() {
        
        let constraint = NSLayoutConstraint(    item: self,
                                                attribute: .centerX,
                                                relatedBy: .equal,
                                                toItem: self.superview,
                                                attribute: .centerX,
                                                multiplier: 1,
                                                constant: 0)
        
        self.superview!.addConstraint(constraint)
    }
    
    func centerVertically() {
        let constraint = NSLayoutConstraint(    item: self,
                                                attribute: .centerY,
                                                relatedBy: .equal,
                                                toItem: nil,
                                                attribute: .centerY,
                                                multiplier: 1,
                                                constant: 0)
        
        self.superview!.addConstraint(constraint)
    }
    
    func place(below view : UIView, margin : CGFloat ) {
        let constraint = NSLayoutConstraint(    item: self,
                                                attribute: .top,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: .bottom,
                                                multiplier: 1,
                                                constant: margin)
        
        self.superview!.addConstraint(constraint)
    }
    
    func place(above view : UIView, margin : CGFloat ) {
        let constraint = NSLayoutConstraint(    item: self,
                                                attribute: .bottom,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: .top,
                                                multiplier: 1,
                                                constant: margin)
        
        self.superview!.addConstraint(constraint)
    }
    
}
