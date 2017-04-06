//
//  PARepositoriesContainer.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 12/9/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import Foundation



struct PASearchPackage : PADescriptor {
    var filterMode = PARepositoriesFilterMode.title
    var filterOperator = PAOperator.equals
    var searchString = ""
    
    func JSONStringDescriptor() -> String {
        
        let format_string = "\nFilter Mode:\t%@\nOperator:\t\nSearch String:\t%@\n".PAPadWithNewlines(padCount: 3)
        
        return String.init(format: format_string, filterMode.rawValue, filterOperator.rawValue, searchString)
    }
}

enum PARepositoriesFilterMode : String
{
    case title = "title"
    case startYear = "startYear"
    case endYear = "endYear"
    case photoCount = "photoCount"
    case creatorID = "creator"
    
    static func descriptorForSearchString( str : String ) -> PARepositoriesFilterMode {
        
        let search_str = str.lowercased()
        
        let startYearLowercased = self.startYear.rawValue.lowercased()
        
        
        if search_str.hasPrefix(self.photoCount.rawValue.lowercased()) {
            return self.photoCount
        }
        else if search_str.hasPrefix(self.startYear.rawValue.lowercased()) {
            return self.startYear
        }
        else if search_str.hasPrefix(self.endYear.rawValue.lowercased()) {
            return self.endYear
        }
        else if search_str.hasPrefix(self.creatorID.rawValue.lowercased()) {
            return self.creatorID
        }
        else {
            return self.title
        }
    }
}
enum PAOperator : String {
    case equals = "="
    case greaterThan = ">"
    case lessThan = "<"
    case greaterThanOrEquals = ">="
    case lessThanOrEquals = "<="
    
    
    static func getOperatorTypeForString( str : String) -> PAOperator {
        
        switch str {
        case self.equals.rawValue:
            return self.equals
            
        case self.greaterThan.rawValue:
            return self.greaterThan
            
        case self.lessThan.rawValue:
            return self.lessThan
            
        case self.greaterThanOrEquals.rawValue:
            return self.greaterThanOrEquals
            
        case self.lessThanOrEquals.rawValue:
            return self.lessThanOrEquals
            
        default:
            return self.equals
        }
    }
}

class PARepositoryContainer {
    
    private var currRepositories = [String : PARepository]()
    private var repositories = [PARepository]()
    private var isSearching = false
    private var searchedRepositories = [PARepository]()
    
    var filterMode = PARepositoriesFilterMode.title
    var filterOperator = PAOperator.equals
    
    private func doesRepositoryExistInArray(_ uuid : String) -> Bool {
        if self.currRepositories[uuid] != nil {
            return true
        }
        
        return false
    }
    
    var Count : Int {
        get {
            if isSearching {
                return self.searchedRepositories.count
            }
            else {
                return self.repositories.count
            }
            
        }
    }
    
    func insertRepository(_ newRepo : PARepository) {
        
        guard !isSearching else {
            
            print( "You can't insert a repository while searching".PAPadWithNewlines() )
            return
        }
        
        if !self.doesRepositoryExistInArray(newRepo.uid) {
            self.currRepositories[newRepo.uid] = newRepo
            self.repositories.append(newRepo)
        }
    }
    
    func repositoryAtIndex(_ index : Int) -> PARepository? {
        
        if isSearching {
            if index >= 0 && index < searchedRepositories.count {
                return searchedRepositories[index]
            }
        }
        else {
            if index >= 0 && index < repositories.count {
                return repositories[index]
            }
        }
        
        return nil
    }
    
    func upadateSearchedRepositories( searchPackage : PASearchPackage ) {
        
        let searchString = searchPackage.searchString
        
        if searchString == "" {
            isSearching = false
            searchedRepositories.removeAll()
            return
        }
        
        isSearching = true
        
        searchedRepositories = repositories.filter({ (repo) -> Bool in
            
            
            switch searchPackage.filterMode {
            case .title:
                let searchable_title = repo.title.lowercased()
                let search_string = searchString.lowercased()
                
                if searchable_title.range(of: search_string) != nil {
                    return true
                }
                else {
                    return false
                }
                
            case .endYear:
                if let repoYearDate = repo.endDate {
                    let endYearInt = PADateManager.sharedInstance.getYearIntValue(date: repoYearDate)
                    if let searchInt = Int(searchPackage.searchString) {
                        return getBool(searchInt: searchInt, valueInt: endYearInt, op: searchPackage.filterOperator)
                    }
                }
                return false
                
            case .startYear:
                if let repoYearDate = repo.startDate {
                    let startYearInt = PADateManager.sharedInstance.getYearIntValue(date: repoYearDate)
                    if let searchInt = Int(searchPackage.searchString) {
                        return getBool(searchInt: searchInt, valueInt: startYearInt, op: searchPackage.filterOperator)
                    }
                }
                return false
                
                
            case .photoCount:
                if let searchInt = Int(searchPackage.searchString) {
                    return getBool(searchInt: searchInt, valueInt: repo.totalPhotographs, op: searchPackage.filterOperator)
                }
                
                return false
                
            case .creatorID:
                if searchPackage.searchString == repo.creatorID {
                    return true
                }
                else {
                    return false
                }
            }
            
            
            
            
        })
    }
    
    
    func getBool( searchInt : Int, valueInt : Int, op : PAOperator ) -> Bool {
        
        
        switch op {
        case .equals:
            return searchInt == valueInt
            
        case .greaterThanOrEquals:
            return valueInt >= searchInt
            
        case .greaterThan:
            return valueInt > searchInt
            
        case .lessThanOrEquals:
            return valueInt <= searchInt
            
        case .lessThan:
            return valueInt < searchInt
            
            
        default:
            return false
        }
    }
}
