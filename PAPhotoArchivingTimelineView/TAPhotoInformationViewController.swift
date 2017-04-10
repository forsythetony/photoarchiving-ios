//
//  TAPhotoInformationViewController.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 11/9/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import UIKit

class TAPhotoInformationViewController: UIViewController {

    @IBOutlet weak var headerBarView: UIView!
    @IBOutlet weak var mainTableView: UITableView!
    
    let photoImageView : UIImageView = UIImageView()
    let caster = PAChromecaster.sharedInstance
    
    let audioMan : PAAudioManager = PAAudioManager.sharedInstance
    let audioPlayerControls : PAAudioPlayerControlBar = PAAudioPlayerControlBar(frame: CGRect.zero)
    var isShowingAudioControls = false
    
    private struct constants {
        private struct AudioControls {
            static let hidden_y_position : CGFloat = 900.0
        }
    }
    var photoInfo : PAPhotograph? {
        didSet {
            photoImageView.downloadedFrom(link: (photoInfo?.mainImageURL)!)
            if let photoInfo = photoInfo {
                photoInfo.delegate = self
                photoInfo.fetchStories()
            }
        }
    }
    
    var storyCount : Int {
        get {
            if self.photoInfo == nil {
                return 0
            }
            else {
                
                return self.photoInfo!.stories.count
            }
        }
    }
    var photoStories = [String]()
    var parsedPhotoInfo = [AnyObject]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setup() {
        
        setupHiddenViews()
        setupTableView()
        getPhotoInfoData()
    }
    private func getPhotoInfoData() {
        
        if let pInfo = self.photoInfo {
            self.parsedPhotoInfo = pInfo.getPhotoInfoData()
            self.mainTableView.reloadData()
        }
    }
    private func setupHiddenViews() {
        
        var audio_controls_center = CGPoint.zero
        audio_controls_center.x = self.view.center.x
        audio_controls_center.y = 600.0
        
        audioPlayerControls.center = audio_controls_center
        audioPlayerControls.alpha = 0.0
        audioPlayerControls.delegate = self
        self.view.addSubview(audioPlayerControls)
        isShowingAudioControls = false
        
    }
    private func setupTableView() {
        
        self.mainTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.mainTableView.register(PAPhotoInfoRegularTableViewCell.self, forCellReuseIdentifier: Constants.PhotoInformationVC.TableViewCells.InfoCell.ReuseIdentifier)
        self.mainTableView.register(PAPhotoInfoDateTableViewCell.self, forCellReuseIdentifier: Constants.PhotoInformationVC.TableViewCells.InfoDateCell.ReuseIdentifier)
        self.mainTableView.register(PAPhotoInfoLocationTableViewCell.self, forCellReuseIdentifier: Constants.PhotoInformationVC.TableViewCells.InfoLocationCell.ReuseIdentifier)
        
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        
    }
    @IBAction func ExitDidTap(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func AddDidTap(_ sender: Any) {
    }

}


extension TAPhotoInformationViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            
            //  Get the type for this cell
            if let currData = self.parsedPhotoInfo[indexPath.row] as? PAPhotoInfo {
                
                switch currData.type {
                case .Text:
                    return Constants.PhotoInformationVC.TableViewCells.InfoCell.CellHeight
                    
                case .Date:
                    return Constants.PhotoInformationVC.TableViewCells.InfoDateCell.CellHeight
                    
                case .Location:
                    return Constants.PhotoInformationVC.TableViewCells.InfoLocationCell.CellHeight
                default:
                    return 40.0
                }
                
                
            }
            
            
            return 50.0
            
            
        }
        
        return 50.0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return self.parsedPhotoInfo.count
            
        case 1:
            return self.storyCount
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if (section == 0) {
            let height = Constants.PhotoInformationVC.ImageHeaderHeight
            let width = tableView.frame.size.width
            
            let frm = CGRect(x: 0.0, y: 0.0, width: width, height: height)
            
            let ve = UIVisualEffectView(frame: frm)
            ve.effect = UIBlurEffect(style: .light)
            
            ve.clipsToBounds = true
            
            self.photoImageView.frame = frm
            self.photoImageView.contentMode = .scaleAspectFit
            ve.addSubview(self.photoImageView)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.DidTapMainImageView(sender:)))
            tap.numberOfTapsRequired = 2
            
            ve.addGestureRecognizer(tap)
            
            return ve
        }
        else {
            return nil
        }
        
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 1) {
            return "Stories"
        }
        
        return nil
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if (section == 0) {
            return Constants.PhotoInformationVC.ImageHeaderHeight
        }
        else {
            return 50.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            //  Get the type for this cell
            if let currData = self.parsedPhotoInfo[indexPath.row] as? PAPhotoInfo {
                
                switch currData.type {
                case .Text:
                    let data = currData as! PAPhotoInfoText
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constants.PhotoInformationVC.TableViewCells.InfoCell.ReuseIdentifier, for: indexPath) as! PAPhotoInfoRegularTableViewCell
                    
                    cell.titleLabel.text = data.title
                    cell.mainLabel.text = data.mainText
                    cell.supplementaryLabel.text = data.supplementaryText
                    
                    return cell
                    
                case .Date:
                    
                    let data = currData as! PAPhotoInfoDate
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constants.PhotoInformationVC.TableViewCells.InfoDateCell.ReuseIdentifier, for: indexPath) as! PAPhotoInfoDateTableViewCell
                    
                    cell.titleLabel.text = data.title
                    cell.mainDate = data.dateTaken
                    cell.dateConfidence = data.dateTakenConf
                    
                    return cell
                    
                case .Location:
                    
                    let data = currData as! PAPhotoInfoLocation
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: Constants.PhotoInformationVC.TableViewCells.InfoLocationCell.ReuseIdentifier, for: indexPath) as! PAPhotoInfoLocationTableViewCell
                    
                    cell.locationCoord = data.coordinates
                    cell.locationString = "\(data.cityName) , \(data.stateName)"
                    cell.titleLabel.text = "Location"
                    
                    return cell
                    
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                    
                    
                    
                    
                    return cell
                }
                
                
            }
            
            
            
        }
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            if let curr_stories = self.photoInfo?.stories {
                
                let curr_story = curr_stories[indexPath.row]
                
                cell.textLabel?.text = curr_story.title
                cell.detailTextLabel?.text = curr_story.recordingURL
            }
            
            return cell
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        
        
        
        return cell
    }
    
    func DidTapMainImageView( sender : UITapGestureRecognizer ) {
        
        self.performSegue(withIdentifier: Constants.SegueIDs.FromPhotoInfoToMainImageViewer, sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let seg_id = segue.identifier {
            
            if seg_id == Constants.SegueIDs.FromPhotoInfoToMainImageViewer {
                
                if let dest = segue.destination as? PAMainImageViewController {
                    
                    dest.mainImage = self.photoImageView.image
                }
            }
            else if seg_id == Constants.SegueIDs.FromPhotoInfoToAddRecording {
                
                if let dest = segue.destination as? PAAddRecordingViewController {
                    
                    dest.photograph = self.photoInfo
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
            case 0:
                if let curr_info = self.parsedPhotoInfo[indexPath.row] as? PAPhotoInfo {
                    
                    switch curr_info.type {
                    case .Text:
                        let photo_info = curr_info as! PAPhotoInfoText
                        
                        self.showTextEditView(title: curr_info.title, value: photo_info.mainText)
                    default:
                        print("no")
                    }
            }
            case 1:
            //  If a user clicks on a story then you should begin playing
            //  playing the story audio
            if let curr_story = self.photoInfo?.stories[indexPath.row] {
                tableView.deselectRow(at: indexPath, animated: true)
                beginPlayingAudioForStory(story: curr_story)
            }
            default:
                print("Default")
        }
    }

    private func beginPlayingAudioForStory( story : PAStory ) {
        
        if caster.isOnline {
            caster.sendStory(story: story, photo: self.photoInfo)
        }
        else {
            showAudioControls()
            audioMan.delegate = self
            audioMan.playStory(story: story)
        }
        
        
        
    }
    
    private func showAudioControls() {
        
        if !isShowingAudioControls {
            
            var new_center = audioPlayerControls.center
            new_center.y = self.view.frame.size.height - (audioPlayerControls.frame.height / 2.0)
            
            let new_alpha : CGFloat = 1.0
            
            let animation_dur : TimeInterval = 0.3
            
            UIView.animate(withDuration: animation_dur, animations: {
                
                self.audioPlayerControls.center = new_center
                self.audioPlayerControls.alpha = new_alpha
                
            }, completion: { (boo) in
                self.isShowingAudioControls = true
            })
        }
    }
    
    func hideAudioControls() {
        
        if isShowingAudioControls {
            
            var new_center = audioPlayerControls.center
            new_center.y = 900.0
            let new_alpha : CGFloat = 0.0
            
            let animation_dur : TimeInterval = 0.4
            
            UIView.animate(withDuration: animation_dur, animations: {
                
                self.audioPlayerControls.center = new_center
                self.audioPlayerControls.alpha = new_alpha
                
            }, completion: { (boo) in
                self.isShowingAudioControls = false
            })
        }
    }
    
    
}

extension TAPhotoInformationViewController : PAPhotographDelegate {
 
    func PAPhotographDidFetchNewStory(story: PAStory) {
        
        self.mainTableView.reloadData()
    }
}

extension TAPhotoInformationViewController : PATextEditViewDelegate {
    
    func showTextEditView( title : String, value : String ) {
        
        let v = PATextEditView(title: title, value: value)
        
        v.alpha = 1.0
        v.backgroundColor = Color.orange
        
        self.view.isUserInteractionEnabled = true
        self.view.addSubview(v)
        
        v.center = self.view.center
        
        v.delegate = self
        
        
    }
    
    func PATextEditViewDidTapCancel(editView: PATextEditView) {
        self.view.isUserInteractionEnabled = true
        
        UIView.animate(withDuration: 0.4, animations: {
            
            editView.alpha = 0.0
            self.view.alpha = 1.0
        }, completion: { boo in
            editView.removeFromSuperview()
        })
    }
    
    func PATextEditViewDidTapOK(editView: PATextEditView) {
        
    }
}

extension TAPhotoInformationViewController : PAAudioManagerDelegate {
    
    func PAAudioManagerDidBeginPlayingStory(story: PAStory) {
        self.audioPlayerControls.currentState = .Playing
        self.audioPlayerControls.mediaTitleLabel.text = story.title
    }
    
    func PAAudioManagerDidFinishPlayingStory(story: PAStory) {
        DispatchQueue.main.async {
            self.hideAudioControls()
        }
        
    }
    
    func PAAudioManagerDidUpdateRecordingTime(time: TimeInterval, story: PAStory) {
        
    }
    
    func PAAudioManagerDidFinishRecording(total_time: TimeInterval, story: PAStory) {
        
    }
    
    func PAAudioManagerDidUpdateStoryPlayTime(running_time: TimeInterval, total_time: TimeInterval, story: PAStory) {
        
        DispatchQueue.main.async {
            self.audioPlayerControls.totalTime = total_time
            self.audioPlayerControls.currentTime = running_time
        }
        
        
    }
    
    
}

extension TAPhotoInformationViewController : PAAudioPlayerControlBarDelegate {
    
    func PAAudioPlayerControlBarDidTapPlayPauseButton(_ bar: PAAudioPlayerControlBar) {
        
        switch bar.currentState {
        case .Paused:
            self.audioMan.beginPlaying()
            bar.currentState = .Playing
            
        case .Playing:
            self.audioMan.pausePlaying()
            bar.currentState = .Paused
            
        case .Stopped:
            self.audioMan.beginPlaying()
            bar.currentState = .Playing
            
        default:
            break
        }
        
        
    }
    
    func PAAudioPayerControlBarDidTapStopButton(_ bar: PAAudioPlayerControlBar) {
        
        if bar.currentState == .Playing {
            self.audioMan.stopPlaying()
        }
        
        self.hideAudioControls()
    }
}
