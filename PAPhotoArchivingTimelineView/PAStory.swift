//
//  PAStory.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 11/9/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import Foundation
import Firebase

class PAStory {
    var uid = ""
    var title = ""
    var interviewee : PAPerson?
    var interviewer : PAUser?
    var shortDescription = ""
    var transcription = ""
    var audioFormat = ""
    var recordingLength : Double = 0.0
    var recordingURL = ""
    var dateRecorded = Date()
    var tempRecordingURL : URL?
    
}

extension PAStory {
    
    static func getNewStory() -> PAStory {
        
        let story = PAStory()
        story.title = "Some new story"
        
        story.uid = PARandom.string(length: 30)
        
        return story
    }
    
    
    static func storyFromSnapshot( snapshot : FIRDataSnapshot) -> PAStory? {
        if let snap_val = snapshot.value as? Dictionary<String, Any> {
            
            let new_story = PAStory()
            
            
            new_story.uid = snap_val[Keys.Story.uid] as? String ?? ""
            new_story.title = snap_val[Keys.Story.title] as? String ?? ""
            
            if let date_rec = snap_val[Keys.Story.date_recorded] as? String {
                new_story.dateRecorded = PADateManager.sharedInstance.getDateFromString(str: date_rec, formatType: .FirebaseFull)
            }
            
            new_story.recordingURL = snap_val[Keys.Story.recordingURL] as? String ?? ""
            new_story.recordingLength = snap_val[Keys.Story.recordingLength] as? Double ?? Double(0.0)
            
            
            return new_story
        }
        else {
            return nil
        }
    }
}


extension PAStory {
    
    func getFirebaseFriendlyArray() -> [ String : Any ] {
        
        var arr = [ String : Any ]()
        
        arr[Keys.Story.uid] = self.uid
        
        arr[Keys.Story.title] = self.title
        
        arr[Keys.Story.date_recorded] = PADateManager.sharedInstance.getDateString(date: self.dateRecorded, formatType: .FirebaseFull)
        
        arr[Keys.Story.recordingLength] = self.recordingLength
        
        arr[Keys.Story.recordingURL] = self.recordingURL
        
        return arr
    }
}
