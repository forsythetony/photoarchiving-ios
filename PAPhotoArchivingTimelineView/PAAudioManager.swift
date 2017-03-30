//
//  PAAudioManager.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 11/26/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import Foundation
import AVFoundation

enum PAAudioSourceType {
    case Local
    case Network
    case Unknown
}

protocol PAAudioManagerDelegate {
    func PAAudioManagerDidUpdateRecordingTime( time : TimeInterval, story : PAStory)
    func PAAudioManagerDidFinishRecording( total_time : TimeInterval , story : PAStory)
    func PAAudioManagerDidBeginPlayingStory( story : PAStory )
    func PAAudioManagerDidUpdateStoryPlayTime( running_time : TimeInterval, total_time : TimeInterval, story : PAStory)
    func PAAudioManagerDidFinishPlayingStory( story : PAStory )
    
}

class PAAudioManager : NSObject {
    
    static let sharedInstance = PAAudioManager()
    
    private var recorder : AVAudioRecorder?
    private var session : AVAudioSession?
    private var player : AVAudioPlayer?
    
    private let fileMan = PAFileManager()
    
    var curr_story : PAStory?
    var curr_story_url : URL?
    
    var curr_recording_length : TimeInterval = 0.0
    var curr_play_time : TimeInterval = 0.0
    
    var recording_timer : Timer?
    var player_timer : Timer?
    
    var delegate : PAAudioManagerDelegate?
    
    var isPlaying : Bool {
        get {
            if let player = player {
                return player.isPlaying
            }
            else {
                return false
            }
        }
    }
    var isRecording : Bool {
        get {
            if let recorder = recorder {
                return recorder.isRecording
            }
            else {
                return false
            }
        }
    }
    
    override init() {
        super.init()
    }
    
    func playStory( story : PAStory ) {
        
        
        let sourceType = determineSourceTypeForStory(story: story)
        self.curr_story = story
        
        switch sourceType {
        case .Local:
            
            guard let story_url = story.tempRecordingURL else { return }
            
            if self.isRecording {
                TFLogger.log(logString: "Can't play, already recording...")
                return
            }
            
            do {
                try player = AVAudioPlayer(contentsOf: story_url)
                player?.play()
                self.delegate?.PAAudioManagerDidBeginPlayingStory(story: story)
                self.beginPlaying()
                
            } catch let err {
                TFLogger.log(str: "Error playing audio from local source", err: err)
            }
            
        case .Network:
            
            guard let network_url = URL(string: story.recordingURL) else
            {
                TFLogger.log(logString: "The string %@ could not be converted into a URL", arguments: story.recordingURL)
                
                return
            }
            
            if self.isRecording {
                TFLogger.log(logString: "Can't play, already recording...")
                return
            }
            
            do {
                let story_data = try Data(contentsOf: network_url)
                
                do {
                    try player = AVAudioPlayer(data: story_data)
                    player?.play()
                    self.delegate?.PAAudioManagerDidBeginPlayingStory(story: story)
                    self.beginPlaying()
                    
                } catch let err {
                    TFLogger.log(str: "Error playing audio from network source", err: err)
                }
            }
            catch let data_err {
                TFLogger.log(str: "There was an error downloading the audio over the network", err: data_err)
            }
            
            
        default:
            TFLogger.log(logString: "Could not determine the audio source type for story -> %@", arguments: story.getFirebaseFriendlyArray().description)
            return
        }
        
        

        
    }
    
    func beginRecordingNewStory( story : PAStory ) {
        self.reset()
        self.curr_story = story
        self.curr_story_url = self.fileMan.getRecordingURLForNewStory(story: story)
        story.tempRecordingURL = self.curr_story_url
        
        if self.isRecording {
            self.stopRecording()
        }
        
        session = AVAudioSession.sharedInstance()
        
        do {
            try session?.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let err {
            TFLogger.log(str: "Error setting the category of the recorder", err: err)
        }
        
        let recorderSettings : [String : Any ] = [
            AVFormatIDKey : kAudioFormatMPEG4AAC,
            AVSampleRateKey : 44100.0,
            AVNumberOfChannelsKey : 2
        ]
        
        do {
            try self.recorder = AVAudioRecorder(url: self.curr_story_url!, settings: recorderSettings)
            self.recorder?.delegate = self
            self.recorder?.isMeteringEnabled = true
            self.recorder?.record()
            self.beginRecording()
        } catch let err {
            TFLogger.log(str: "Error creating the recorder...", err: err)
        }
        
    }
    func reset() {
        if recording_timer != nil {
            recording_timer?.invalidate()
            recording_timer = nil
        }
        
        self.curr_recording_length = 0.0
    }
    func beginPlaying() {
        
        guard let p = self.player else { return }
        
        p.play()
        
        self.player_timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (t) in
            
            self.curr_play_time += 1.0
            
            if let curr_story = self.curr_story {
                self.delegate?.PAAudioManagerDidUpdateStoryPlayTime(running_time: self.curr_play_time, total_time: curr_story.recordingLength, story: curr_story)
            }
            
            
        })
    }
    func stopPlaying() {
        
        if let p = self.player {
            p.stop()
        }
        
        if let player_timer = player_timer {
            player_timer.invalidate()
        }
        player_timer = nil
        curr_play_time = 0.0
        
    }
    func pausePlaying() {
        
        guard let p = self.player else { return }
        
        p.pause()
        
        if let player_timer = player_timer {
            player_timer.invalidate()
        }
        
        player_timer = nil
    }
    func beginRecording() {
        self.recording_timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { t in
         
            self.curr_recording_length += 1
            
            if let curr_story = self.curr_story {
                self.delegate?.PAAudioManagerDidUpdateRecordingTime(time: self.curr_recording_length, story: curr_story)
            }
            
        })
    }
    func stopRecording() {
        if let recorder = recorder {
            recorder.stop()
        }
        if let recording_timer = recording_timer {
            recording_timer.invalidate()
        }
        recorder = nil
    }
}

extension PAAudioManager : AVAudioRecorderDelegate {
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        
    }
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        if let curr_story = curr_story {
            curr_story.recordingLength = Double(recorder.currentTime)
            self.delegate?.PAAudioManagerDidFinishRecording(total_time: self.curr_recording_length, story: curr_story)
        }
    }
}

extension PAAudioManager : AVAudioPlayerDelegate {
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        self.stopPlaying()
        if let curr_story = curr_story {
            self.delegate?.PAAudioManagerDidFinishPlayingStory(story: curr_story)
        }
    }
}

//  Helpers

extension PAAudioManager {
    
    func determineSourceTypeForStory( story : PAStory ) -> PAAudioSourceType{
        
        if let local_url = story.tempRecordingURL {
            if local_url.absoluteString != "" {
                return .Local
            }
        }
        
        if story.recordingURL != "" {
            return .Network
        }
        
        return .Unknown
    }
}
