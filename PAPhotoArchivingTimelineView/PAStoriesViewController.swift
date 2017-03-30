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
    }
    
    private func _setupTableView() {
        
        mainTableView = UITableView(frame: self.view.bounds, style: .plain)
        mainTableView.delegate = self
        mainTableView.dataSource = self
        
        mainTableView.register(UITableViewCell.self, forCellReuseIdentifier: CELL_ID)
        
        self.view.addSubview(mainTableView)
        
        mainTableView.snp.makeConstraints { (maker) in
            maker.left.equalTo(self.view)
            maker.right.equalTo(self.view)
            maker.top.equalTo(self.view).offset(20.0)
            maker.bottom.equalTo(self.view).offset(-30.0)
        }
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
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID) else {
            print("Couldn't dequeue")
            return UITableViewCell()
        }
        
        guard let story_info = self.currentPhotograph?.stories[indexPath.row] else {
            print("Couldn't get story")
            return cell
        }
        
        cell.textLabel?.text = story_info.uid
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let story_info = self.currentPhotograph?.stories[indexPath.row] else {
            print("Couldn't get story")
            return
        }
        
        self.audioMan.playStory(story: story_info)
    }
}

extension PAStoriesViewController : PAPhotographDelegate {
    func PAPhotographDidFetchNewStory(story: PAStory) {
        
        mainTableView.reloadData()
    }
}
