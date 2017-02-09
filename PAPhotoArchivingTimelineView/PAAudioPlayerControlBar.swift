//
//  PAAudioPlayerControlBar.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 11/26/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import UIKit

enum PAAudioPlayerControlBarState {
    case Playing, Paused, Stopped, Unknown
}
protocol PAAudioPlayerControlBarDelegate {
    func PAAudioPlayerControlBarDidTapPlayPauseButton(_ bar : PAAudioPlayerControlBar)
    func PAAudioPayerControlBarDidTapStopButton(_ bar : PAAudioPlayerControlBar)
}
class PAAudioPlayerControlBar: UIView {

    let totalTimeLabel = PATimeLabel()
    let runningTimeLabel = PATimeLabel()
    let progressBar = UIProgressView()
    let mediaTitleLabel = UILabel()
    let playPauseButton = UIButton()
    let stopButton = UIButton()
    var isSetup = false
    var delegate : PAAudioPlayerControlBarDelegate?
    
    let buttonFontSize : CGFloat = 14.0
    let titleFontSize : CGFloat = 17.0
    
    let buttonColor : Color = Color.PAWhiteOne
    
    var currentState : PAAudioPlayerControlBarState = .Unknown {
        didSet {
            if self.isSetup {
                
                let buttonFont = Font.PABoldFontWithSize(size: self.buttonFontSize)
                
                switch self.currentState {
                case .Playing:
                    self.playPauseButton.PASetTitleString("Pause", font: buttonFont, color: self.buttonColor, state: .normal)
                    
                case .Paused:
                    
                    self.playPauseButton.PASetTitleString("Play", font: buttonFont, color: self.buttonColor, state: .normal)
                    
                    
                case .Stopped:
                    self.playPauseButton.PASetTitleString("Play", font: buttonFont, color: self.buttonColor, state: .normal)
                    
                default:
                    break
                }
            }
        }
    }
    var currentTime : TimeInterval = 0.0 {
        didSet {
            
            runningTimeLabel.secondsValue = currentTime
            
            if let totalTime = totalTime {
                let progress = Float(currentTime / totalTime)
                self.totalProgress = progress
            }
            else {
                self.totalProgress = 0.0
            }
        }
    }
    
    var totalTime : TimeInterval? {
        didSet {
            if let totalTime = totalTime {
                self.totalTimeLabel.secondsValue = totalTime
            }
        }
    }
    
    var totalProgress : Float = 0.0 {
        didSet {
            
            UIView.animate(withDuration: 0.9, animations: {
                self.progressBar.progress = self.totalProgress
            })
            
        }
    }
    
    override init(frame: CGRect) {
        var new_frame = frame
        new_frame.size.height = Constants.AudioPlayerControlBar.mainHeight
        new_frame.size.width = UIApplication.shared.keyWindow?.frame.width ?? 320.0
        super.init(frame: new_frame)
        self.frame = new_frame
        
        setup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        
        var frm = self.frame
        
        
        //  Time Label Constants
        let timeLabelFontSize : CGFloat = 10.0
        let timeLabelTextColor = Color.PAWhiteOne
        
        //  Running Time
        frm.origin.x = Constants.AudioPlayerControlBar.timeLabelHorizontalOffset
        frm.origin.y = 0.0
        frm.size.width = Constants.AudioPlayerControlBar.timeLabelWidth
        
        runningTimeLabel.frame = frm
        
        runningTimeLabel.font = Font.PARegularFontWithSize(size: timeLabelFontSize)
        runningTimeLabel.textAlignment = .center
        runningTimeLabel.textColor = timeLabelTextColor
        
        self.addSubview(runningTimeLabel)
        
        //  Total Time
        frm.origin.x = self.frame.size.width - (Constants.AudioPlayerControlBar.timeLabelHorizontalOffset + frm.size.width)
        
        totalTimeLabel.frame = frm
        
        totalTimeLabel.font = Font.PARegularFontWithSize(size: timeLabelFontSize)
        totalTimeLabel.textAlignment = .center
        totalTimeLabel.textColor = timeLabelTextColor
        
        self.addSubview(totalTimeLabel)
        
        
        //  Play Button
        
        frm.origin.x = Constants.AudioPlayerControlBar.timeLabelHorizontalOffset + Constants.AudioPlayerControlBar.timeLabelWidth + Constants.AudioPlayerControlBar.titleLabelInset
        frm.size.width = Constants.AudioPlayerControlBar.buttonWidth
        
        
        self.playPauseButton.frame = frm
        
        self.addSubview(playPauseButton)
        
        
        self.playPauseButton.addTarget(self, action: #selector(self.DidTapPlayPauseButton(sender:)), for: .touchUpInside)
        
        
        
        //  Title Label
        frm.origin.x = self.playPauseButton.frame.origin.x + self.playPauseButton.frame.width + Constants.AudioPlayerControlBar.titleLabelInset
        
        frm.size.width = self.frame.width - (frm.origin.x) - ((Constants.AudioPlayerControlBar.timeLabelWidth * 2.0) + Constants.AudioPlayerControlBar.timeLabelHorizontalOffset + Constants.AudioPlayerControlBar.titleLabelInset)
        
        
        
        self.mediaTitleLabel.frame = frm
        self.mediaTitleLabel.textAlignment = .center
        self.mediaTitleLabel.font = Font.PARegularFontWithSize(size: self.titleFontSize)
        self.mediaTitleLabel.textColor = Color.PAWhiteOne
        
        self.addSubview(mediaTitleLabel)
        
        //  Stop Button
        frm.origin.x += frm.size.width
        frm.size.width = Constants.AudioPlayerControlBar.buttonWidth
        
        
        self.stopButton.frame = frm
        
        let bFont = Font.boldSystemFont(ofSize: self.buttonFontSize)
        
        self.stopButton.PASetTitleString("Exit", font: bFont, color: self.buttonColor, state: .normal)
        
        self.stopButton.addTarget(self, action: #selector(self.DidTapStopButton(sender:)), for: .touchUpInside)
        
        self.addSubview(stopButton)
        
        //  Progress View
        
        frm.origin.x = 0.0
        frm.origin.y = self.frame.size.height - Constants.AudioPlayerControlBar.progressViewHeight
        frm.size.width = self.frame.width
        frm.size.height = Constants.AudioPlayerControlBar.progressViewHeight
        
        self.progressBar.frame = frm
        self.progressBar.progressTintColor = Color.PAWhiteOne
        self.progressBar.trackTintColor = Color.black
        
        self.addSubview(self.progressBar)
    
        self.backgroundColor = Color.PADarkBlue
     
        
        isSetup = true
        
    }
    
    
    func DidTapPlayPauseButton( sender : UIButton ) {
        self.delegate?.PAAudioPlayerControlBarDidTapPlayPauseButton(self)
    }
    
    func DidTapStopButton( sender : UIButton ) {
        self.delegate?.PAAudioPayerControlBarDidTapStopButton(self)
    }
}
