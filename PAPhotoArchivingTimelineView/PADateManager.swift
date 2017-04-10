//
//  PADateManager.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 10/26/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import UIKit

enum PADateStyleType : String {
    case Pretty = "EEE, dd MMM yyy"
    case Firebase = "yyyy-MM-dd"
    case TimeOnly = "H:m:S"
    case FirebaseFull = "yyyy-MM-dd H:m:S"
    case YearOnly = "yyyy"
    case StorysTableView = "MMM dd, H:mm a"
    case ShortMonth = "MMM"
    case Pretty2 = "MMMM d, YYYY"
}
class PADateManager {
    
    static let sharedInstance = PADateManager.init()
    
    private let formatter = DateFormatter()
    
    private let currentCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
    
    
    func getDateFromString( str : String, formatType : PADateStyleType ) -> Date {
        
        formatter.dateFormat = formatType.rawValue
        
        if let dt = formatter.date(from: str) {
            return dt
        }
        else {
            return Date()
        }
    }
    func getDateString( date : Date, formatType type : PADateStyleType ) -> String {
        
        formatter.dateFormat = type.rawValue
        
        return formatter.string(from: date)
    }
    
    func getLowerYearBound( year : Date, style : PATimelineStyle) -> Date {
    
        switch style {
        case .year:
            let yearInt = self.getLowerYearBoundInt(year: year)
            
            return self.getDateFromYearInt(year: yearInt)
        default:
            let yearInt = self.getYearIntValue(date: year)
            
            return self.getDateFromYearInt(year: yearInt.decrement())
        }
        
    }
    
    func getLowerYearBoundInt( year : Date ) -> Int {
        
        let incrementValue = Constants.Timeline.YearBoundIncrement
        
        var yearInt = self.getYearIntValue(date: year)
        
        if yearInt % incrementValue == 0 {
            return yearInt - incrementValue
        }
        
        while (yearInt % incrementValue != 0) {
            yearInt = yearInt - 1
        }
        
        return yearInt
    }
    
    
    func getSecondsFromDistantPast( date : Date ) -> TimeInterval {
        
        let interval = date.timeIntervalSince(Date.distantPast)
        
        return interval
    }
    
    func getUpperYearBound( year : Date, style : PATimelineStyle ) -> Date {
        
        switch style {
        case .year:
            let yearInt = self.getUpperYearBoundInt(year: year)
            
            return self.getDateFromYearInt(year: yearInt)
            
            
        case .month:
            let yearInt = self.getYearIntValue(date: year)
            
            return self.getDateFromYearInt(year: yearInt.increment())
            
        default:
            break
        }
        
    }
    func getDateWithSecondsFromDistantPast( seconds : TimeInterval ) -> Date {
        
        return Date(timeInterval: seconds, since: Date.distantPast)
    }
    func getMonthValueForCounter( counter : Int ) -> String {
        
        let mod = counter % 12
        
        var dateComp = DateComponents.init()
        dateComp.month = mod
        
        if let date = self.currentCalendar.date(from: dateComp) {
            return self.getDateString(date: date, formatType: .ShortMonth)
        }
        else {
            return "Uh oh"
        }
    }
    func getUpperYearBoundInt( year : Date ) -> Int {
        
        let incrementValue = Constants.Timeline.YearBoundIncrement
        
        var yearInt = self.getYearIntValue(date: year)
        
        let currYearInt = self.getCurrentYearInt()
        
        if (yearInt % incrementValue == 0) {
            let newYearInt = yearInt + incrementValue
            
            return min(currYearInt, newYearInt)
        }
        
        while( yearInt % incrementValue != 0 && yearInt != currYearInt) {
            yearInt = yearInt + 1
        }
        
        return yearInt
    }
    
    func getDateSpanSeconds( startDate : Date, endDate : Date ) -> TimeInterval {
        
        let startRef    = self.getSecondsFromDistantPast(date: startDate)
        let endRef      = self.getSecondsFromDistantPast(date: endDate)

        let diff = endRef - startRef
        
        return abs( diff )
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    func getCurrentYearInt() -> Int {
        
        return self.getYearIntValue(date: Date())
    }
    func getDateFromYearInt( year : Int ) -> Date {
        
        var dateComps = DateComponents()
        dateComps.year = year
        dateComps.month = 1
        dateComps.day = 1
        
        if let newDate = currentCalendar.date(from: dateComps) {
            return newDate
        }
        
        return Date()
    }
    
    func getYearIntValue( date : Date ) -> Int {
        
        let yearVal = currentCalendar.component(.year, from: date)
        
        return yearVal
    }
    
    func randomDateBetweenYears( startYear: Date, endYear : Date ) -> Date {
        
        let startYearRef = self.getSecondsFromDistantPast(date: startYear)
        let endYearRef = self.getSecondsFromDistantPast(date: endYear)
        
        let randomDoubleInSpan = PARandom.randomDoubleInSpan(start: Double(startYearRef), end: Double(endYearRef))
        
        let newDate = Date(timeInterval: TimeInterval(randomDoubleInSpan), since: Date.distantPast)
        
        return newDate
    }
    
    func randomDateBetweenYears( startYear : Int, endYear : Int) -> Date {
        
        let firstDate = self.getDateFromYearInt(year: startYear)
        let lastDate = self.getDateFromYearInt(year: endYear)
        
        return self.randomDateBetweenYears(startYear: firstDate, endYear: lastDate)
    }
    
}

extension PADateManager {
    
    static var defaultBirthdate : Date {
        let default_birthdate_int = 1993
        
        return PADateManager.sharedInstance.getDateFromYearInt(year: default_birthdate_int)
    }
}
class PANumberManager {
    

}
