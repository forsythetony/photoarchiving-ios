//
//  PAStoriesViewController.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 3/29/17.
//  Copyright © 2017 Tony Forsythe. All rights reserved.
//

import UIKit
import SnapKit

class PAStoriesViewController: UIViewController {
    
    static let STORYBOARD_ID = "PAStoriesViewControllerStoryboardID"
    
    var isShowingPlayerBar = false
    
    fileprivate let CELL_ID = "cell_id_for_stories"
    
    var currentPhotograph : PAPhotograph? {
        didSet {
            
            currentPhotograph?.delegate = self
            currentPhotograph?.fetchStories()
        }
    }
    
    let dataMan = PADataManager.sharedInstance
    let audioMan = PAAudioManager.sharedInstance
    
    var mainTableView : UITableView!
    var mainTitleLabel : UILabel!
    var exitButton : UIButton!
    var indexPathToDelete : IndexPath?
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        _setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    private func _setup() {
        _setupTableView()
        
        mainTitleLabel = UILabel(frame: CGRect.zero)
        mainTitleLabel.textAlignment = .center
        mainTitleLabel.font = UIFont.PABoldFontWithSize(size: 25.0)
        mainTitleLabel.text = "Stories"
        
        exitButton = UIButton(frame: CGRect.zero)
        exitButton.setTitle("Exit", for: .normal)
        exitButton.setTitleColor(Color.red, for: .normal)
        exitButton.addTarget(self, action: #selector(PAStoriesViewController.didTapExit), for: .touchUpInside)
        
        self.view.addSubview(mainTitleLabel)
        self.view.addSubview(exitButton)
        
        mainTitleLabel.snp.makeConstraints { (maker) in
            maker.top.equalTo(self.view).offset(20.0)
            maker.left.equalTo(self.view)
            maker.right.equalTo(self.view)
            maker.height.equalTo(30.0)
        }
        
        exitButton.snp.makeConstraints { (maker) in
            maker.height.equalTo(30.0)
            maker.width.equalTo(60.0)
            maker.centerX.equalTo(self.view)
            maker.bottom.equalTo(self.view).offset(-80.0)
        }
        
        mainTableView.snp.makeConstraints { (maker) in
            maker.left.equalTo(self.view)
            maker.right.equalTo(self.view)
            maker.top.equalTo(mainTitleLabel.snp.bottom).offset(4.0)
            maker.bottom.equalTo(exitButton.snp.top).offset(-10.0)
        }
        
    }
    @objc func didTapExit() {
        self.presentingViewController?.dismiss(animated: false, completion: nil)
    }
    private func _setupTableView() {
        
        mainTableView = UITableView(frame: self.view.bounds, style: .plain)
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.allowsMultipleSelectionDuringEditing = false
        
        mainTableView.register(UINib.init(nibName: "PAStoryTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: PAStoryTableViewCell.REUSE_ID)
        
        self.view.addSubview(mainTableView)
        
        
    }
    

}

extension PAStoriesViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentPhotograph?.stories.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PAStoryTableViewCell.REUSE_ID) as? PAStoryTableViewCell else {
            print("Couldn't dequeue")
            return UITableViewCell()
        }
        
        guard let story_info = self.currentPhotograph?.stories[indexPath.row] else {
            print("Couldn't get story")
            return cell
        }
        
        
        cell.mainTitleLabel.text = story_info.title
        cell.dateLabel.text = PADateManager.sharedInstance.getDateString(date: story_info.dateUploaded ?? Date(), formatType: .StorysTableView)
        cell.lengthLabel.text = story_info.recordingLength.PATimeString
        cell.uploaderIDLabel.text = story_info.uploaderID
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PAStoryTableViewCell.CELL_HEIGHT
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let story_info = self.currentPhotograph?.stories[indexPath.row] else {
            print("Couldn't get story")
            return
        }
        
        
        self.audioMan.playStory(story: story_info)
        self.showPlayerBar()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            if let story = self.currentPhotograph?.stories[indexPath.row], let photograph = self.currentPhotograph {
                self.dataMan.delegate = self
                self.indexPathToDelete = indexPath
                
                self.dataMan.deleteStoryForPhotograph(story: story, photograph: photograph)
            }
            
            
            
        }
    }
    func showPlayerBar() {
        
        guard !isShowingPlayerBar else { return }
        var oldFrame = self.audioMan.audioControlBar.frame
        
        oldFrame.origin.x = 0.0
        oldFrame.origin.y = self.view.frame.height - PAAudioControlBar.BAR_HEIGHT
        self.audioMan.audioControlBar.frame = oldFrame
        
        self.view.addSubview(self.audioMan.audioControlBar)
        
        self.audioMan.audioControlBar.snp.makeConstraints { (maker) in
            maker.left.equalTo(self.view)
            maker.right.equalTo(self.view)
            maker.bottom.equalTo(self.view)
            maker.height.equalTo(PAAudioControlBar.BAR_HEIGHT)
        }
    }
}

extension PAStoriesViewController : PADataManagerDelegate {
    func PADataMangerDidConfigure() {
        
    }
    func PADataManagerDidUpdateProgress(progress: Double) {
        
    }
    func PADataManagerDidFinishUploadingStory(storyID: String) {
        
    }
    func PADataManagerDidGetNewRepository(_ newRepository: PARepository) {
        
    }
    func PADataManagerDidSignInUserWithStatus(_ signInStatus: PAUserSignInStatus) {
        
    }
    func PADataManagerDidDeleteStoryFromPhotograph(story: PAStory, photograph: PAPhotograph) {
        
        guard indexPathToDelete != nil else { return }
        
        self.currentPhotograph?.stories.remove(at: indexPathToDelete!.row)
        
        mainTableView.beginUpdates()
        self.mainTableView.deleteRows(at: [indexPathToDelete!], with: .fade)
        mainTableView.endUpdates()
        
        indexPathToDelete = nil
    }
}
extension PAStoriesViewController : PAPhotographDelegate {
    func PAPhotographDidFetchNewStory(story: PAStory) {
        
        mainTableView.reloadData()
    }
}
