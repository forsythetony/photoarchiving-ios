//
//  Helpers.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 11/25/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import Foundation
import UIKit

//  Creating placeholder images

extension UIImage {
    
    static func PATimelineIconPlaceholder() -> UIImage {
        
        let return_img = UIImage(named: "timeline_thumbnail_placeholder") ?? UIImage.PABlackImageWithSize(size: CGSize(width: 100.0, height: 100.0))
        
        return return_img
    }
    
    
    
    static func PABlackImageWithSize( size : CGSize ) -> UIImage {
        return UIImage.PAImageWithSizeAndColor(size: size, color: .black)
    }
    
    static func PAImageWithSizeAndColor(size : CGSize, color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
extension UIView {
    
    func PAAutoLayoutSetup() -> Void {
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else {
                    
                    if let error = error {
                        TFLogger.log(str: "There was an error downloading the image", err: error)
                    }
                    return
                    
            }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFill) {
        
        guard let url = URL(string: link) else {
            
            TFLogger.log(logString: "There was an error creating the URL from the string link -> %@", arguments: link)
            
            return
            
        }
        downloadedFrom(url: url, contentMode: mode)
    }
}

func RGBVal( v : CGFloat ) -> CGFloat {
    
    if v < 0.0 { return 0.0}
    
    if v > 255.0 { return 1.0 }
    
    return v / 255.0
    
    
}


extension Date {
    
    static func dateBySubtractingYears( years : Int ) -> Date {
        
        let yearsDouble = Double(years)
        
        let secondsToSubtract = (60.0 * 60.0 * 24.0 * 365.0 * yearsDouble)
        
        return Date().addingTimeInterval(-secondsToSubtract)
    }
    
    static func dateBySubtractingDays( days : Int ) -> Date {
        
        let daysDouble = Double(days)
        
        let secondsToSubtract = (60.0 * 60.0 * 24.0 * daysDouble)
        
        return Date().addingTimeInterval(-secondsToSubtract)
    }
}
extension Float {
    var PAStringValue : String {
        get {
            return String(format: "%.2f", Double(self))
        }
    }
}

extension CGRect {
    
    mutating func PASetOriginToZero() {
        self.origin.x = 0.0
        self.origin.y = 0.0
    }
}
extension CGFloat {
    var PAStringValue : String {
        
        get {
            return String(format: "%.3f", Double(self))
        }
    }

    var RGBValue : CGFloat {
        
        get {
            if self > 255.0 || self < 0.0 {
                return 0.0
            }
            else {
                return self / 255.0
            }
            
        }
    }
    
    static func PAFullRGB() -> CGFloat {
        return 255.0
    }
}

extension Double {
    var CGFloatRGBValue : CGFloat {
        get {
            if self > 255.0 || self < 0.0 {
                return 0.0.CGFloatValue
            }
            else {
                return (self / 255.0).CGFloatValue
            }
        }
    }
    
    var CGFloatValue : CGFloat {
        get {
            return CGFloat(self)
        }
    }
}
extension Int {
    
    var CGFloatValue : CGFloat {
    
        get {
            return CGFloat(self)
        }
    }
    
    var PAStringValue : String {
        
        get {
            return String(self)
        }
    }
    
    func decrement() -> Int {
        if self <= 0 {
            return 0
        }
        else {
            return self - 1
        }
    }
    
    func increment() -> Int {
        return self + 1
    }
}


class PAObjectLogger {
    
    var title = "Untitled"
    var values = Dictionary< String , String>()
    var delimiter = ":"
    
    private let default_unknown = "unavailable"
    
    func getLogString() -> String {
        
        var logString = ""
        
        
        logString += "Title\(self.delimiter)\t\(self.title)"
        
        
        for val in self.values {
            
            logString += "\n"
            logString += "\(val.key)\(self.delimiter)\t\(val.value)"
        }
        
        logString += "\n\n"
        
        return logString
    }
    
    func addStringWithTitle( title : String, value : String ) {
        values[title] = value
    }
    
    func addDateWithTitle( title : String, val : Date? ) {
        
        var date_string = default_unknown
        
        if let val = val {
            date_string = PADateManager.sharedInstance.getDateString(date: val, formatType: .Pretty)
        }
        
        addStringWithTitle(title: title, value: date_string)
    }
    
    func addIntWithTitle( title : String, val : Int) {
        
        let int_str = val.PAStringValue
        
        addStringWithTitle(title: title, value: int_str)
    }
    
    
}

struct PAColorValues {
    var red     : CGFloat = 0.0
    var blue    : CGFloat = 0.0
    var green   : CGFloat = 0.0
    var alpha   : CGFloat = 1.0
}

extension PAColorValues {
    
    static func PAFullRedColorValues() -> PAColorValues {
        var vals = PAColorValues()
        let red_val : CGFloat = 255.0
        
        vals.red = red_val.RGBValue
        
        return vals
    }
    
    static func PAFullGreenColor() -> PAColorValues {
        var vals = PAColorValues()
        
        vals.green = CGFloat.PAFullRGB().RGBValue
        
        return vals
    }
    
    static func PAFullBlueColor() -> PAColorValues {
        
        var vals = PAColorValues()
        
        vals.blue = CGFloat.PAFullRGB().RGBValue
        
        return vals
    }
    
    func createColor() -> Color {
        
        return Color(displayP3Red: self.red, green: self.green, blue: self.blue, alpha: self.alpha)
    }
}
struct PACGFloatSpan {
    var lowerBound : CGFloat = 0.0
    var upperBound : CGFloat = 0.0
}
extension Color {

    static func randomColor() -> Color {
        
        let rand_r = PARandom.randomRGBValue()
        let rand_g = PARandom.randomRGBValue()
        let rand_b = PARandom.randomRGBValue()
        let alpha : CGFloat = 1.0
        
        return Color(displayP3Red: rand_r, green: rand_g, blue: rand_b, alpha: alpha)
        
    }
    
    static func assignDebugBackgroundColorsToViews( views : [UIView] ) {
        
        let views_count = views.count
        
        if views_count <= 0 {
            return
        }
        switch views_count {
        case 1:
            let debug_color_vals = PAColorValues.PAFullGreenColor()
            views.first?.backgroundColor = debug_color_vals.createColor()
            return
        case 2:
            let first_debug_color_val = PAColorValues.PAFullGreenColor()
            let second_debug_color_val = PAColorValues.PAFullBlueColor()
            
            let color_vals = [first_debug_color_val, second_debug_color_val]
            
            
            for i in 0...views_count.decrement() {
                let curr_view = views[i]
                let curr_color_val = color_vals[i]
                
                curr_view.backgroundColor = curr_color_val.createColor()
                
            }
            
            return
            
        case 3:
            let color_vals = [
                PAColorValues.PAFullBlueColor(),
                PAColorValues.PAFullGreenColor(),
                PAColorValues.PAFullRedColorValues()
            ]
            
            
            for i in 0...views_count.decrement() {
                let curr_view = views[i]
                let curr_color_val = color_vals[i]
                
                curr_view.backgroundColor = curr_color_val.createColor()
            }
            
        default:
            //  Split red spans up
            
            let rgb_incrementer = 255.0 / CGFloat(views_count)
            
            //  Create array of RGB spans
            var red_spans = [PACGFloatSpan]()
            var green_spans = [PACGFloatSpan]()
            var blue_spans = [PACGFloatSpan]()
            
            for i in 0...views_count.decrement() {
                var new_red_span = PACGFloatSpan()
                new_red_span.lowerBound = CGFloat(i) * rgb_incrementer
                new_red_span.upperBound = new_red_span.lowerBound + rgb_incrementer
                
                red_spans.append(new_red_span)
            }
            
            for i in 1...views_count {
                let curr_index = i % views_count
                
                var new_green_span = PACGFloatSpan()
                new_green_span.lowerBound = CGFloat(curr_index) * rgb_incrementer
                new_green_span.upperBound = new_green_span.lowerBound + rgb_incrementer
                
                green_spans.append(new_green_span)
            }
            
            for i in 2...views_count.increment() {
                let curr_index = i % views_count
                
                var new_blue_span = PACGFloatSpan()
                new_blue_span.lowerBound = CGFloat(curr_index) * rgb_incrementer
                new_blue_span.upperBound = new_blue_span.upperBound + rgb_incrementer
                
                blue_spans.append(new_blue_span)
            }
            
            for i in 0...views_count.decrement() {
                let curr_view = views[i]
                
                let curr_red_span = red_spans[i]
                let curr_blue_span = blue_spans[i]
                let curr_green_span = green_spans[i]
                
                let curr_red = PARandom.randomCGFloatInSpan(start: curr_red_span.lowerBound, end: curr_red_span.upperBound)
                let curr_blue = PARandom.randomCGFloatInSpan(start: curr_blue_span.lowerBound, end: curr_blue_span.upperBound)
                let curr_green = PARandom.randomCGFloatInSpan(start: curr_green_span.lowerBound, end: curr_green_span.upperBound)
                
                let curr_color_vals = PAColorValues(red: curr_red, blue: curr_blue, green: curr_green, alpha: 1.0)
                
                curr_view.backgroundColor = curr_color_vals.createColor()
            }
            
            
        }
    }
}

extension String {
    
    func appendForwardSlash() -> String {
        
        let lastChar = self[self.index(before: self.endIndex)]
        
        if lastChar == "/" {
            return self
        }
        else {
            return self.appending("/")
        }
        
    }
    
    
    static func PAStringByReplacement( str : String, arguments : [String]) -> String {
        guard arguments.count > 0 else {
            return ""
        }
        
        var newString = str
        
        
        let argCount = arguments.count
        var counter = 0
        
        var currRange = newString.getNextRangeOccurrenceOfString(str: "%@")
        
        while( currRange != nil && counter < argCount) {
            
            
            let currArg = arguments[counter]
            
            newString = newString.replacingCharacters(in: currRange!, with: currArg)
            
            currRange = newString.getNextRangeOccurrenceOfString(str: "%@")
            
            counter += 1
        }
        
        return newString
    }
}

extension UINavigationItem {
    
    func PAClearBackButtonTitle() {
        
        self.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}

extension UIButton {
    
    func PASetTitleString(_ title : String, font : Font, color : Color, state : UIControlState) {
        
        let attributedString = NSAttributedString(string: title, attributes: [NSFontAttributeName : font, NSForegroundColorAttributeName : color])
        
        self.setAttributedTitle(attributedString, for: state)
    }
}

class TFTextViewTextPiece {
    var title = ""
    var value = ""
    
    
    static func Create(with title: String, val : String) -> TFTextViewTextPiece {
        let new = TFTextViewTextPiece()
        
        new.title = title
        new.value = val
        
        return new
    }
    
    static func CreateWithDate(_ title: String, date : Date) -> TFTextViewTextPiece {
        
        let new = TFTextViewTextPiece()
        
        new.title = title
        new.value = PADateManager.sharedInstance.getDateString(date: date, formatType: .Pretty)
        
        return new
    }
}
class TFTextViewTextGenerator {
    
    private lazy var mainText = ""
    
    private lazy var pieces = [TFTextViewTextPiece]()
    
    var MainDelimiter = "-------------"
    var SubDelimiter = ":"
    
    func addPiece(with title: String, value : String) {
        let new = TFTextViewTextPiece.Create(with: title, val: value)
        
        pieces.append(new)
    }
    
    func addPiece(with title: String, and date : Date) {
        let new = TFTextViewTextPiece.CreateWithDate(title, date: date)
        
        pieces.append(new)
    }
    
    
    func getString() -> String {
        var str = ""
        
        str += "\n"
        
        
        for piece in self.pieces {
            
            str += piece.title
            str += self.SubDelimiter
            str += "\n" + piece.value
            str += "\n\n" + self.MainDelimiter + "\n\n"
        }
        
        return str
    }
    
    
    
    
}
