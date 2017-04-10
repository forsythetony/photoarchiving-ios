//
//  PAIncrementView.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 11/8/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import UIKit

enum PAIncrementViewType {
    case EndpointStart
    case EndpointEnd
    case Ten
    case Five
    case Regular
    case Unknown
}

class PAIncrementView: UIView {

    var viewType = PAIncrementViewType.Unknown
    var year : Int!
    
    private let yearLabel = UILabel()
    private let incLine = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLabel()
        setupLine()
        
        
    }
    
    convenience init(frame: CGRect, year : Int, type : PAIncrementViewType) {
        self.init(frame : frame)
        
        self.viewType = type
        self.year = year
        
        self.reconfigure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLabel() {
        
        var labelFrame = self.frame
        
        labelFrame.origin.x = labelFrame.size.width * 0.2
        labelFrame.origin.y = 0.0
        labelFrame.size.width *= 0.8
        yearLabel.frame = labelFrame
        
        yearLabel.textColor = Color.white
        yearLabel.textAlignment = .right
        
       
        
        self.addSubview(yearLabel)
        
        
    }
    
    private func setupLine() {
        
        let lineHeight = 1.0
        let lineWidth = 20.0
        
        let lineFrame = CGRect(x: 0.0, y: Double(self.frame.height / 2.0), width: lineWidth, height: lineHeight)
        
        self.incLine.frame = lineFrame
        self.incLine.backgroundColor = Color.TimelineIncrementLineColor
        
        self.addSubview(incLine)
    }
    
    private func reconfigure() {
        
        yearLabel.text = String(self.year)
        
        var lineWidthMod = Constants.Timeline.IncrementLine.OriginalWidthModifer
        
        switch self.viewType {
        case .EndpointStart:
            convertLineToEndpoint()
            self.yearLabel.alpha = 1.0
            self.yearLabel.textAlignment = .left
            
        case .EndpointEnd:
            convertLineToEndpoint()
            self.yearLabel.alpha = 1.0
            self.yearLabel.textAlignment = .left
            
        case .Five:
            self.incLine.alpha = 1.0
            self.yearLabel.alpha = 0.0
            lineWidthMod = Constants.Timeline.IncrementLine.FiveYearWidthModifier
            updateIncrementLineWidth(withModifier: lineWidthMod)
            
        case .Ten:
            self.incLine.alpha = 1.0
            self.yearLabel.alpha = 1.0
            self.yearLabel.textAlignment = .center
            updateIncrementLineWidth(withModifier: lineWidthMod)
            
        case .Regular:
            self.incLine.alpha = 1.0
            self.yearLabel.alpha = 0.0
            lineWidthMod = Constants.Timeline.IncrementLine.RegularWidthModifier
            updateIncrementLineWidth(withModifier: lineWidthMod)
            
        default:
            print("Unknown")
            
        }
        
        
    }
    
    private func convertLineToEndpoint() {
        
        let height : CGFloat = 6.0
        let width = height
        let xPos = 0 - (width / 2.0)
        let yPos = self.frame.height / 2.0
        
        let newFrame = CGRect(x: xPos, y: yPos, width: width, height: height)
        
        self.incLine.frame = newFrame
        self.incLine.alpha = 1.0
        
        self.incLine.backgroundColor = Color.TimelineEndpointColor
        self.incLine.layer.cornerRadius = height / 2.0
        
    }
    private func updateIncrementLineWidth(withModifier mod : CGFloat) {
        
        var lineFrame = self.incLine.frame
        lineFrame.size.width = self.frame.size.width
        
        lineFrame.size.width *= mod
        
        self.incLine.frame = lineFrame
    }
}
