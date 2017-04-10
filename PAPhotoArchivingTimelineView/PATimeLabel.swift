//
//  PATimeLabel.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 11/26/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import UIKit

extension TimeInterval {
    
    var PAFormattedString : String {
        get {
            //  If negative return zero
            if self <= 0 {
                return "00:00"
            }
            
            //  Get the minutes value
            let minutes = self / 60.0
            let seconds = self.truncatingRemainder(dividingBy: 60.0)
            
            var minutes_str = String(format: "%2.0f", minutes)
            if minutes < 10 {
                minutes_str = "0" + minutes_str
            }
            
            
            var seconds_str = String(format: "%2.0f", seconds)
            
            if seconds < 10 {
                seconds_str = "0" + seconds_str
            }
            
            return "\(minutes_str):\(seconds_str)"
        }
    }
}
class PATimeLabel: UILabel {
    
    private let startingText = "00:00"
    var secondsValue : TimeInterval = 0 {
        didSet {
            self.text = secondsValue.PAFormattedString
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.text = startingText
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.text = startingText
    }

}
