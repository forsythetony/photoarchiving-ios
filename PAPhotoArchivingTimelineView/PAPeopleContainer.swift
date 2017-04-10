//
//  PAPeopleContainer.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 4/10/17.
//  Copyright © 2017 Tony Forsythe. All rights reserved.
//

import Foundation
import UIKit

class PAUserContainer {
    
    private var _allUsers = [PAUser]()
    private var _friendUsers = [PAUser]()
    
    private var allUsers : [PAUser] {
        get {
            if friendsOnly {
                return _friendUsers
            }
            
            return _allUsers
        }
        
    }
    private var searchedUsers = [PAUser]()
    private var allUsersDict = [ String : PAUser ]()
    
    private var isSearching = false
    
    var friendsOnly = false {
        didSet {
            searchedUsers.removeAll()
        }
    }
    
    var count : Int {
        if isSearching {
            return searchedUsers.count
        }
        else {
            return allUsers.count
        }
    }
    
    
    
    
    private func doesUserExistInArray( user : PAUser ) -> Bool {
        
        return (allUsersDict[user.uid] != nil)
    }
    
    func insertUser( user : PAUser ) {
        
        guard !isSearching else {
            
            print( "You can't insert a person while searching!".PAPadWithNewlines() )
            return
        }
        
        if !doesUserExistInArray(user: user) {
            self.allUsersDict[user.uid] = user
            self._allUsers.append(user)
            
            if user.isMyFriend {
                self._friendUsers.append(user)
            }
        }
        
        
    }
    
    func userAtIndex( index : Int ) -> PAUser? {
        
        if index >= 0 && index < count {
            
            if isSearching {
                return searchedUsers[index]
            }
            else {
                return allUsers[index]
            }
        }
        
        return nil
    }
    
    
    func updateSearchedUsers( searchString : String) {
        
        if searchString == "" {
            isSearching = false
            return
        }
        
        isSearching = true
        if friendsOnly {
            
            searchedUsers = _friendUsers.filter({ (user) -> Bool in
                
                if user.email.range(of: searchString) != nil {
                    return true
                }
                
                if user.firstName.range(of: searchString) != nil {
                    return true
                }
                
                if user.lastName.range(of: searchString) != nil {
                    return true
                }
                
                return false
            })
        }
        else {
            searchedUsers = _allUsers.filter({ (user) -> Bool in
                
                if user.email.range(of: searchString) != nil {
                    return true
                }
                
                if user.firstName.range(of: searchString) != nil {
                    return true
                }
                
                if user.lastName.range(of: searchString) != nil {
                    return true
                }
                
                return false
            })
        }
        
        
        
        
    }
}
