//
//  PAAddRecordingViewController.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 11/26/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import UIKit

class PAAddRecordingViewController: UIViewController {

    @IBOutlet weak var runningTimeLabel: PATimeLabel!
    @IBOutlet weak var totalTimeLabel: PATimeLabel!
    
    @IBOutlet weak var filePathLabel: UILabel!
    private let playerMan = PAAudioManager.sharedInstance
    private let new_story = PAStory.getNewStory()
    
    var photograph : PAPhotograph?
    
    let audio_play_bar : PAAudioPlayerControlBar = {
        let bar = PAAudioPlayerControlBar(frame: CGRect())
        var frm = bar.frame
        frm.origin.y = UIApplication.shared.keyWindow?.frame.height ?? 500.0
        frm.origin.y += 200.0
        
        bar.frame = frm
        
        return bar
    }()
    
    private var isShowingPlayBar = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerMan.delegate = self
        
        self.view.addSubview(audio_play_bar)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    @IBAction func DidTapPlayAudio(_ sender: Any) {
        
        playerMan.playStory(story: self.new_story)
        
    }
    @IBAction func DidTapStopRecording(_ sender: Any) {
        playerMan.stopRecording()
    }
    @IBAction func DidTapBeginRecording(_ sender: Any) {
        playerMan.beginRecordingNewStory(story: self.new_story)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func bringBarToFrame() {
        
        if isShowingPlayBar { return }
        
        UIView.animate(withDuration: 0.3, animations: {
            
            var newFrame = self.audio_play_bar.frame
            
            newFrame.origin.y = self.view.frame.size.height - newFrame.height
            
            self.audio_play_bar.frame = newFrame
            
            self.isShowingPlayBar = true
        })
        
        
    }
}

extension PAAddRecordingViewController : PAAudioManagerDelegate {
    func PAAudioManagerDidUpdateRecordingTime(time: TimeInterval, story: PAStory) {
        self.runningTimeLabel.secondsValue = time
        self.totalTimeLabel.secondsValue = time
    }
    
    func PAAudioManagerDidFinishRecording(total_time: TimeInterval, story: PAStory) {
        TFLogger.log(logString: "Recording path -> ", arguments: (story.tempRecordingURL?.absoluteString)!)
        
        self.filePathLabel.text = story.tempRecordingURL?.absoluteString ?? "No URL"
    }
    
    func PAAudioManagerDidBeginPlayingStory(story: PAStory) {
        if let curr_photo = self.photograph {
            PADataManager.sharedInstance.addStoryToPhotograph(story: story, photograph: curr_photo)
        }
        
        
        self.bringBarToFrame()
        
    }
    
    func PAAudioManagerDidFinishPlayingStory(story: PAStory) {
        
    }
    
    func PAAudioManagerDidUpdateStoryPlayTime(running_time: TimeInterval, total_time: TimeInterval, story: PAStory) {
        self.audio_play_bar.totalTime = total_time
        self.audio_play_bar.currentTime = running_time
        self.audio_play_bar.mediaTitleLabel.text = story.title
    }
}
