//
//  PARepositoriesContainer.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 12/9/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import Foundation

class PARepositoryContainer {
    
    private var currRepositories = [String : PARepository]()
    private var repositories = [PARepository]()
    
    private func doesRepositoryExistInArray(_ uuid : String) -> Bool {
        if self.currRepositories[uuid] != nil {
            return true
        }
        
        return false
    }
    
    var Count : Int {
        get {
            return self.repositories.count
        }
    }
    
    func insertRepository(_ newRepo : PARepository) {
        
        if !self.doesRepositoryExistInArray(newRepo.uid) {
            self.currRepositories[newRepo.uid] = newRepo
            self.repositories.append(newRepo)
        }
    }
    
    func repositoryAtIndex(_ index : Int) -> PARepository? {
        
        if index >= 0 && index < repositories.count {
            return repositories[index]
        }
        
        return nil
    }
}
