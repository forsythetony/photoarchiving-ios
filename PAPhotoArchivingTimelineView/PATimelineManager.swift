//
//  PATimelineManager.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 11/8/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import Foundation
import UIKit

enum PATimelineStyle {
    case year, month
}

class PATimelineManager {
    
    private var startDate   = Date()
    private var endDate     = Date()
    
    private var fixedStartDate : Date!
    private var fixedEndDate : Date!
    
    var fixedStartDateInt : Int!
    var fixedEndDateInt : Int!
    
    var fixedStartDateRef : TimeInterval!
    
    private var secondsPerPoint : Double!
    
    private var startY              : CGFloat = 0.0
    private var endY                : CGFloat = 0.0
    private var contentViewWidth   : CGFloat = 0.0
    
    private var distanceSpan : CGFloat = 0.0
    
    private var dateSpanSeconds : TimeInterval = 0
    
    var recommendedIncViewWidth : CGFloat = 0.0
    
    var timelineStyle = PATimelineStyle.year
    
    init( _startDate : Date, _endDate : Date, _startY : CGFloat, _endY : CGFloat, _contentViewWidth : CGFloat) {
        
        self.startDate  = _startDate
        self.endDate    = _endDate
        
        self.setTimelineStyle()
        
        self.fixedStartDate = PADateManager.sharedInstance.getLowerYearBound(year: self.startDate, style: self.timelineStyle)
        self.fixedEndDate = PADateManager.sharedInstance.getUpperYearBound(year: self.endDate, style: self.timelineStyle)
        
        self.fixedStartDateInt = PADateManager.sharedInstance.getYearIntValue(date: self.fixedStartDate)
        self.fixedEndDateInt = PADateManager.sharedInstance.getYearIntValue(date: self.fixedEndDate)
        
        self.startY     = _startY
        self.endY       = _endY
        
        self.contentViewWidth = _contentViewWidth
        
        self.fixedStartDateRef = PADateManager.sharedInstance.getSecondsFromDistantPast(date: self.fixedStartDate)
        
        self.updateValues()
    }
    
    private func setTimelineStyle() {
        
        let dateDifference = PADateManager.sharedInstance.getDateSpanSeconds(startDate: self.startDate, endDate: self.endDate)
        
        let yearSpan = dateDifference / ( 60.0 * 60.0 * 24.0 * 365.0 )
        
        let threshold = 20.0
        
        if yearSpan > threshold {
            self.timelineStyle = .year
        }
        else {
            self.timelineStyle = .month
        }
        
    }
    private func updateValues() {
        
        dateSpanSeconds = PADateManager.sharedInstance.getDateSpanSeconds(startDate: self.fixedStartDate, endDate: self.fixedEndDate)
        distanceSpan = endY - startY
        
        if self.timelineStyle == .year {
        recommendedIncViewWidth = distanceSpan / CGFloat((self.fixedEndDateInt - self.fixedStartDateInt))
        }
        else {
            recommendedIncViewWidth = distanceSpan / CGFloat((self.fixedEndDateInt - self.fixedStartDateInt) * 12)
        }
        
        self.secondsPerPoint = Double(dateSpanSeconds) / Double(distanceSpan)
    }
    
    func getPointForDate( date : Date ) -> CGPoint {
        
        var mainPoint = CGPoint()
        
        //  First get the Y value
        
        let dateRef = PADateManager.sharedInstance.getSecondsFromDistantPast(date: date)
        
        let dateDiff = dateRef - self.fixedStartDateRef
        
        let pointsDiff = dateDiff / self.secondsPerPoint
        
        let yPos = self.startY + CGFloat(pointsDiff)
        
        let xPosStart = Constants.Timeline.HorizontalInset + 30.0 + (self.contentViewWidth / 2.0)
        
        let xPosDouble = PARandom.randomDoubleInSpan(start: Double(xPosStart), end: Double(self.contentViewWidth))
        
        TFLogger.log(logString: "For the image with span start (%@) and span end (%@) I got the following random x value %@", arguments: xPosStart.PAStringValue, self.contentViewWidth.PAStringValue, CGFloat(xPosDouble).PAStringValue)
        
        
        mainPoint.y = yPos
        mainPoint.x = CGFloat(xPosDouble)
        
        return mainPoint
    }
    
    func setupPhotographBuckets() {
        
    }
}
