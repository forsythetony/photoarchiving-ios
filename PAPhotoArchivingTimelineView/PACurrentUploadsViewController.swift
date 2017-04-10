//
//  PACurrentUploadsViewController.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 3/27/17.
//  Copyright © 2017 Tony Forsythe. All rights reserved.
//

import UIKit
import SnapKit

class PACurrentUploadsViewController: UIViewController {

    static let STORYBOARD_ID = "PACurrentUploadsViewControllerID"
    var mainTableView : UITableView!
    let dataMan = PADataManager.sharedInstance
    var listenersSetup = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func _setup() {
        _setupListeners()
        _setupTableView()
    }
    func _setupListeners() {
        
        if listenersSetup { return }
        
        let note_center = NotificationCenter.default
        
        note_center.addObserver(self, selector: #selector(PACurrentUploadsViewController.didGetProgressUpdatedNotification(note:)), name: NSNotification.Name(rawValue: Constants.Notifications.Upload.photoUploadProgressUpdate), object: nil)
        
        note_center.addObserver(self, selector: #selector(PACurrentUploadsViewController.didGetPhotoUploadRemovedNotification(note:)), name: NSNotification.Name(rawValue: Constants.Notifications.Upload.photoUploadDidRemoveUpload), object: nil)
        
        note_center.addObserver(self, selector: #selector(PACurrentUploadsViewController.didGetNewPhotoUploadAddedNotification(note:)), name: NSNotification.Name(rawValue: Constants.Notifications.Upload.photoUploadHasNewUpload), object: nil)
        
        listenersSetup = true
        
    }
    func _setupTableView() {
        
        mainTableView = UITableView(frame: CGRect.zero, style: .plain)
        mainTableView.delegate = self
        mainTableView.dataSource = self
        
        mainTableView.register(PACurrentUploadTableviewCell.self, forCellReuseIdentifier: PACurrentUploadTableviewCell.REUSE_ID)
        mainTableView.backgroundColor = Color.blue
        
        self.view.addSubview(mainTableView)
        
        mainTableView.snp.makeConstraints { (maker) in
            maker.top.equalTo(self.view)
            maker.left.equalTo(self.view)
            maker.right.equalTo(self.view)
            maker.bottom.equalTo(self.view)
        }
    }

    
    
    /*
        LISTENERS
    */
    @objc func didGetNewPhotoUploadAddedNotification( note : Notification ) {
        
        let newIndex = self.dataMan.uploadsMan.currentUploads
        
        let newIndexPath = IndexPath(row: newIndex, section: 0)
        
        self.mainTableView.insertRows(at: [newIndexPath], with: .fade)
    }
    
    @objc func didGetProgressUpdatedNotification( note : Notification ) {
        
        guard let user_info = note.userInfo else { return }
        
        guard user_info[Keys.NotificationUserInfo.PhotoUpload.photoID] != nil else { return }
        
        let photo_id = user_info[Keys.NotificationUserInfo.PhotoUpload.photoID] as! String
        
        guard let photo_index = self.dataMan.uploadsMan.sortedPhotoIDs.index(of: photo_id) else { return }
        
        let index_path = IndexPath(row: photo_index, section: 0)
        
        DispatchQueue.main.async {
            self.mainTableView.reloadRows(at: [index_path], with: .none)
        }
        
        
    }
    
    @objc func didGetPhotoUploadRemovedNotification( note : Notification) {
        
        guard let user_info = note.userInfo else { return }
        
        guard let uploadInformation = user_info[Keys.NotificationUserInfo.PhotoUpload.photoUploadInformation] as? PAPhotoUploadInformation else { return }
        
        guard let photo_index = self.dataMan.uploadsMan.sortedPhotoIDs.index(of: uploadInformation.photographID) else { return }
        
        let index_path = IndexPath(row: photo_index, section: 0)
        
        self.mainTableView.deleteRows(at: [index_path], with: .fade)
    }
    
    
    
    
    
    func teardown() {
        NotificationCenter.default.removeObserver(self)
        self.listenersSetup = false
    }
}

extension PACurrentUploadsViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataMan.uploadsMan.currentUploads
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PACurrentUploadTableviewCell.ROW_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PACurrentUploadTableviewCell.REUSE_ID) as? PACurrentUploadTableviewCell else {
            return UITableViewCell()
        }
        
        
        guard let curr_info = self.dataMan.uploadsMan.getInformationForIndexPath(i: indexPath.row) as PAPhotoUploadInformation? else {
            return UITableViewCell()
        }
        
        cell.mainLabel.text = curr_info.photographID
        
        let new_progress = curr_info.progress
        
        cell.progressView.progress = new_progress
        
        return cell
    }
}

fileprivate struct PAPadding {
    var left : CGFloat = 0.0
    var right : CGFloat = 0.0
    var top : CGFloat = 0.0
    var bottom : CGFloat = 0.0
}
class PACurrentUploadTableviewCell : UITableViewCell {
    
    static let ROW_HEIGHT : CGFloat = 100.0
    static let REUSE_ID = "PACurrentUploadTableviewCell"
    
    var mainLabel : UILabel!
    var progressView : UIProgressView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        _setupViews()
    }
    
    
    func _setupViews() {
        
        let cell_height = PACurrentUploadTableviewCell.ROW_HEIGHT
        
        let main_label_height : CGFloat = cell_height * CGFloat(0.9)
        var main_label_padding = PAPadding()
        main_label_padding.left = 20.0
        main_label_padding.top = 10.0
        main_label_padding.right = 0.0
        
        self.mainLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 320.0, height: main_label_height))
        
        self.mainLabel.backgroundColor = Color.orange
        
        let progress_view_height = cell_height - main_label_height
        var progress_view_padding = PAPadding()
        progress_view_padding.top = 0.0
        
        
        self.progressView = UIProgressView(progressViewStyle: .default)
        //self.progressView.trackTintColor = Color.white
        //self.progressView.progressTintColor = Color.red
        self.progressView.setProgress(0.0, animated: false)
        
        self.contentView.addSubview(self.mainLabel)
        self.contentView.addSubview(self.progressView)
        
        self.contentView.snp.makeConstraints { (maker) in
            maker.edges.equalTo(self)
        }
        
        self.progressView.snp.makeConstraints { (maker) in
            maker.left.equalTo(self.contentView.snp.left).offset(progress_view_padding.left)
            maker.right.equalTo(self.contentView.snp.right).offset(-progress_view_padding.right)
            maker.bottom.equalTo(self.contentView.snp.bottom).offset(-progress_view_padding.bottom)
            maker.height.equalTo(progress_view_height)
        }
        
        self.mainLabel.snp.makeConstraints { (maker) in
            maker.top.equalTo(self.contentView).offset(main_label_padding.top)
            maker.bottom.equalTo(self.progressView.snp.top)
            maker.left.equalTo(self.contentView.snp.left).offset(main_label_padding.left)
            maker.right.equalTo(self.contentView.snp.right).offset(-main_label_padding.right)
        }
        
    }
}
