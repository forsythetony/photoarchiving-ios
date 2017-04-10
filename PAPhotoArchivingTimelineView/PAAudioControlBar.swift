//
//  PAAudioControlBar.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 3/30/17.
//  Copyright © 2017 Tony Forsythe. All rights reserved.
//

import UIKit
import SnapKit

enum PAAudioPlayerControlState {
    case isPlaying, isStopped
}

protocol PAAudioControlBarDelegate {
    func PAAudioControlBarDidClickPause()
    func PAAudioControlBarDidClickPlay()
    func PAAudioControlBarDidClickStop()
}
class PAAudioControlBar: UIView {
    
    private enum AudioControlBarActionType {
        case play, pause, stop
    }
    
    static let BAR_HEIGHT : CGFloat = 60.0
    
    var progressBar     : UIProgressView!
    var currTimeLabel   : UILabel!
    var playPauseButton : UIButton!
    var stopButton      : UIButton!
    var totalTimeLabel  : UILabel!
    var titleLabel      : UILabel!
    
    var delegate : PAAudioControlBarDelegate?
    
    var currentState = PAAudioPlayerControlState.isStopped {
        didSet {
            self.didUpdateState()
        }
    }
    var isShowing = false
    
    var progress : Float  = 0.0 {
        didSet {
            progressBar.progress = progress
        }
    }
    var currentTime : String = "" {
        didSet {
            self.currTimeLabel.text = currentTime
        }
    }
    
    var totalTime : String = "" {
        didSet {
            self.totalTimeLabel.text = self.totalTime
        }
    }
    
    
    override init(frame : CGRect) {
        
        super.init(frame: frame)
        
       _setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    private func didUpdateState() {
        switch self.currentState {
        case .isPlaying:
            self.playPauseButton.setImage(#imageLiteral(resourceName: "pause_icon"), for: .normal)
            
        case .isStopped:
            self.playPauseButton.setImage(#imageLiteral(resourceName: "play_icon"), for: .normal)
            
        default:
            break
        }
    }
    private func _setup() {
        
        self.backgroundColor = Color.gray
        
        let progressBarHeight : CGFloat = 5.0
        let labelHeight : CGFloat = 20.0
        let buttonHeight : CGFloat = 30.0
        let timeLabelWidths : CGFloat = 50.0
        
        self.progressBar = UIProgressView(frame: CGRect.zero)
        
        self.currTimeLabel = UILabel(frame: CGRect.zero)
        self.currTimeLabel.text = Double(0.0).PATimeString
        self.currTimeLabel.textColor = Color.white
        self.currTimeLabel.textAlignment = .center
        
        self.totalTimeLabel = UILabel(frame: CGRect.zero)
        self.totalTimeLabel.text = Double(0.0).PATimeString
        self.totalTimeLabel.textColor = Color.white
        self.totalTimeLabel.textAlignment = .center
        
        self.titleLabel = UILabel(frame: CGRect.zero)
        self.titleLabel.textColor = Color.white
        self.titleLabel.textAlignment = .center
        
        self.playPauseButton = UIButton(frame: CGRect.zero)
        self.playPauseButton.setImage(#imageLiteral(resourceName: "play_icon"), for: .normal)
        self.playPauseButton.addTarget(self, action: #selector(PAAudioControlBar.didTapPlayPause(sender:)), for: .touchUpInside)
        
        
        self.stopButton = UIButton(frame: CGRect.zero)
        self.stopButton.setImage(#imageLiteral(resourceName: "stop_icon"), for: .normal)
        self.stopButton.addTarget(self, action: #selector(PAAudioControlBar.didTapStop(sender:)), for: .touchUpInside)
        
        self.addSubview(self.progressBar)
        self.addSubview(self.currTimeLabel)
        
        self.addSubview(self.totalTimeLabel )
        self.addSubview(self.titleLabel)
        
        self.addSubview(self.playPauseButton)
        self.addSubview(self.stopButton)
        
        self.progressBar.snp.makeConstraints { (maker) in
            maker.top.equalTo(self)
            maker.left.equalTo(self)
            maker.right.equalTo(self)
            maker.height.equalTo(progressBarHeight)
        }
        
        self.currTimeLabel.snp.makeConstraints { (maker) in
            maker.top.equalTo(self.progressBar.snp.bottom)
            maker.left.equalTo(self)
            maker.width.equalTo(timeLabelWidths)
            maker.height.equalTo(labelHeight)
        }
        
        self.totalTimeLabel.snp.makeConstraints { (maker) in
            maker.top.equalTo(self.progressBar.snp.bottom)
            maker.right.equalTo(self)
            maker.width.equalTo(timeLabelWidths)
            maker.height.equalTo(labelHeight)
        }
        
        self.playPauseButton.snp.makeConstraints { (maker) in
            maker.bottom.equalTo(self.snp.bottom).offset(-5.0)
            maker.left.equalTo(self).offset(5.0)
            maker.width.equalTo(buttonHeight)
            maker.height.equalTo(buttonHeight)
        }
        
        self.stopButton.snp.makeConstraints { (maker) in
            maker.bottom.equalTo(self.playPauseButton.snp.bottom)
            maker.right.equalTo(self).offset(-5.0)
            maker.width.equalTo(buttonHeight)
            maker.height.equalTo(buttonHeight)
        }
        
        self.titleLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(self.playPauseButton.snp.right)
            maker.right.equalTo(self.stopButton.snp.left)
            maker.height.equalTo(labelHeight)
            maker.centerY.equalTo(self.playPauseButton.snp.centerY)
        }
    }
    
    func reset() {
        self.progress = 0.0
        self.currentTime = Double(0.0).PATimeString
        self.totalTime = Double(0.0).PATimeString
        self.titleLabel.text = ""
        
    }
    @objc func didTapPlayPause( sender : UIButton ) {
        
        if self.currentState == .isPlaying {
            delegate?.PAAudioControlBarDidClickPause()
            _postNotification(actionType: .pause)
        }
        else {
            delegate?.PAAudioControlBarDidClickPlay()
            _postNotification(actionType: .play)
        }
    }
    
    @objc func didTapStop( sender : UIButton ) {
        delegate?.PAAudioControlBarDidClickStop()
        _postNotification(actionType: .stop)
    }
    
    
    // MARK: - Helper Functions
    
    private func _postNotification( actionType : AudioControlBarActionType ) {
        
        var noteName : Notification.Name?
        
        switch actionType {
            
        case .pause:
            noteName = Notifications.audioPlayerBarDidTapPause.name
            
        case .play:
            noteName = Notifications.audioPlayerBarDidTapPlay.name
            
        case .stop:
            noteName = Notifications.audioPlayerBarDidTapStop.name
            
        default:
            break
            
        }
        
        
        
        
        guard let name = noteName else {
            return
        }
        
        let note = Notification(    name: name,
                                    object: nil,
                                    userInfo: nil)
        
        NotificationCenter.default.post(note)
    }


}
