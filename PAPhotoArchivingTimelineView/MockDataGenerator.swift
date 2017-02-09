//
//  MockDataGenerator.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 11/23/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import UIKit
import Firebase

class MockDataGenerator {
    static let sharedInstance = MockDataGenerator()
    
    
    var ref : FIRDatabaseReference!
    var repositories : [FIRDataSnapshot] = [FIRDataSnapshot]()
    var storageRef: FIRStorageReference!
    fileprivate var _refHandle: FIRDatabaseHandle!
    var repos : [PARepository] = [PARepository]()
    var can_use : Bool = false
    
    init() {
    
    }
    
    func configureDatabase() {
       
    }
    func addRepoWithSnapshot( snap : FIRDataSnapshot ) {
        
        if let newRepo = PARepository.CreateWithFirebaseSnapshot(snap: snap) {
            self.repos.append(newRepo)
        }
    }
    
    func getARepository() -> PARepository? {
        if self.repos.count > 0 {
            return self.repos.first
        }
        return nil
    }
}
