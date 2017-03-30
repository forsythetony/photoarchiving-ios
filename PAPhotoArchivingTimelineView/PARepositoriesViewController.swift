//
//  PARepositoriesViewController.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 12/9/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import UIKit
import Kingfisher

fileprivate struct Action {
    static let didTapAddButton = #selector(PARepositoriesViewController.didTapAddButton(sender:))
}

class PARepositoriesViewController: UIViewController {

    @IBOutlet weak var RepositoriesCollectionView: UICollectionView!

    
    let dataMan = PADataManager.sharedInstance
    
    lazy var Repositories = PARepositoryContainer()
    
    let ItemsPerRow : Int                       = 3
    let HorizontalSectionPadding : CGFloat      = 10.0
    let HorizontalSpacingBetweenItems : CGFloat = 10.0
    
    let backgroundImageView = UIImageView()
    let blurredBackgroundImageView = UIImageView()
    
    var selectedRepository : PARepository?
    
    var ViewWidth : CGFloat {
        get {
            let defaultWidth : CGFloat = 320.0
            
            let width = self.view.frame.size.width
            
            if width != 0.0 {
                return width
            }
            
            return defaultWidth
        }
        
    }
    
    var SectionInsets : UIEdgeInsets {
        get {
            
            var insets = UIEdgeInsets()
            
            let horizontalPadding : CGFloat     = HorizontalSectionPadding
            let topPadding : CGFloat            = 5.0
            let bottomPadding : CGFloat         = 5.0
            
            insets.left     = horizontalPadding
            insets.right    = horizontalPadding
            insets.top      = topPadding
            insets.bottom   = bottomPadding
            
            return insets
        }
    }


    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        self.title = "Repositories"
        
        _dataSetup()
        _setupCollectionView()
        _setupImageView()
        _setupAddButton()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    
    /*
        SETUP FUNCTIONS
    */
    private func _dataSetup() {
        self.dataMan.delegate = self
        
        if !self.dataMan.isConfigured {
            self.dataMan.configure()
        }
        else {
            self.dataMan.pullRepositories()
        }
        
    }
    
    private func _setupAddButton() {
        
        let add_button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: Action.didTapAddButton)
        
        self.navigationItem.rightBarButtonItem = add_button
    }
    
    private func _setupImageView() {
        
        let blur = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blur)
        
        guard let v = self.view else { return }
        
        
        
        var frm = v.frame
        frm.PASetOriginToZero()
        
        backgroundImageView.frame = frm
        backgroundImageView.contentMode = .center
        backgroundImageView.image = UIImage(named: "main_background")
        
        v.addSubview(backgroundImageView)
        v.sendSubview(toBack: backgroundImageView)
        
        blurView.frame = backgroundImageView.bounds
        
        backgroundImageView.addSubview(blurView)
        
    }
    
    private func _setupCollectionView() {
//        
//        self.RepositoriesCollectionView.register(PARepositoryCollectionViewCell.self, forCellWithReuseIdentifier: PARepositoryCollectionViewCell.ReuseID)
//        
        self.RepositoriesCollectionView.register(UINib.init(nibName: "PARepositoryCell", bundle: Bundle.main), forCellWithReuseIdentifier: PARepositoryCell.REUSE_ID)
        
        self.RepositoriesCollectionView.delegate = self
        self.RepositoriesCollectionView.dataSource = self
        
        self.RepositoriesCollectionView.backgroundColor = Color.clear
        
    }
    
    /*
        BUTTON ACTION HANDLERS
    */
    func didTapAddButton( sender : UIBarButtonItem ) {
        
        let message = "Looks like you tapped the add button there kiddo!"
        
        print(String.init(format: "\n%@\n", message))
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let add_repository_vc = storyboard.instantiateViewController(withIdentifier: PAAddRepositoryViewController.STORYBOARD_ID) as! PAAddRepositoryViewController
        
        self.present(add_repository_vc, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let segueID = segue.identifier else {
            TFLogger.log(logString: "The segue has no identifer... %@", arguments: segue.debugDescription)
            return
        }
        
        
        switch segueID {
        case Constants.SegueIDs.SegueFromRepositoriesToTimelineView:
            
            guard let selectedRepository = self.selectedRepository else {
                TFLogger.log(logString: "There was no selected repository...")
                return
            }
            
            
            let dest = segue.destination as! PATimelineViewController
            
            dest.currentRepository = selectedRepository
            
            
        default:
            
            break
        }
    }
    
    
    func updateBlur() {
        
        self.RepositoriesCollectionView.alpha = 0.0
        self.blurredBackgroundImageView.alpha = 0.0
        self.backgroundImageView.alpha = 1.0
        
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, true, 1)
        // 3
        self.view.drawHierarchy(in: self.view.bounds, afterScreenUpdates: true)
        // 4
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let blur = screenshot?.applyLightEffect() {
            self.blurredBackgroundImageView.image = blur
            self.blurredBackgroundImageView.alpha = 1.0
            self.backgroundImageView.alpha = 0.0
        }
        
        self.RepositoriesCollectionView.alpha = 1.0
    }
}

extension PARepositoriesViewController : PADataManagerDelegate {
    internal func PADataManagerDidUpdateProgress(progress: Double) {
        
    }

    internal func PADataManagerDidFinishUploadingStory(storyID: String) {
        
    }

    
    func PADataManagerDidSignInUserWithStatus(_ signInStatus: PAUserSignInStatus) {
        
        //  FIXME:
        //      Need to add some stuff here
        
    }
    func PADataManagerDidGetNewRepository(_ newRepository: PARepository) {
        
        
        self.Repositories.insertRepository(newRepository)
        
        self.RepositoriesCollectionView.reloadData()
    }
    
    func PADataMangerDidConfigure() {
        
        self.dataMan.pullRepositories()
    }
}


extension PARepositoriesViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let selectedRepo = self.Repositories.repositoryAtIndex(indexPath.item) else {
            TFLogger.log(logString: "Couldn't get the repository with the index path %@", arguments: indexPath.description)
            return
        }
        
        self.selectedRepository = selectedRepo
        
        self.performSegue(withIdentifier: Constants.SegueIDs.SegueFromRepositoriesToTimelineView, sender: nil)
    }
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let totalRepos = self.Repositories.Count
        
        return totalRepos
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        /*let cell = collectionView.dequeueReusableCell(  withReuseIdentifier: PARepositoryCollectionViewCell.ReuseID,
                                                        for: indexPath) as! PARepositoryCollectionViewCell
        
        if let cellInfo = self.Repositories.repositoryAtIndex(indexPath.item) {
            
            let imgPath = cellInfo.thumbnailURL
            
            if imgPath == "" {
                cell.TitleLabel.textColor = Color.white
            }
            else {
                
                cell.ImageView.kf.setImage(with: URL(string: imgPath )! )
                cell.TitleLabel.textColor = Color.black
            }
            
            
            let repoTitle = cellInfo.title
            
            cell.TitleLabel.text = repoTitle
            
        }
        
        
        cell.backgroundColor = Color.black
        
        return cell
        
        
        */
        
        
        
        
        
        let cell = collectionView.dequeueReusableCell(  withReuseIdentifier: PARepositoryCell.REUSE_ID,
                                                        for: indexPath) as! PARepositoryCell
        
        if let cellInfo = self.Repositories.repositoryAtIndex(indexPath.item) {
            
            let imgPath = cellInfo.thumbnailURL
            
            if imgPath == "" {
                //cell.TitleLabel.textColor = Color.white
            }
            else {
                
                cell.thumbnailImageView.kf.setImage(with: URL(string: imgPath )! )
                //cell.TitleLabel.textColor = Color.black
            }
            
            let start_year = PADateManager.sharedInstance.getDateString(date: cellInfo.startDate!, formatType: .YearOnly)
            let end_year = PADateManager.sharedInstance.getDateString(date: cellInfo.endDate!, formatType: .YearOnly)
            
            let date_span_string = String.init(format: "%@-%@", start_year, end_year)
            
            cell.timeframeLabel.text = date_span_string
            
            cell.mainTitleLabel.text = cellInfo.title
            
            cell.imageCountLabel.text = String.init(format: "%d", cellInfo.totalPhotographs)
            
        }
        
        
        //cell.backgroundColor = Color.black
        
        return cell
    }
}

extension PARepositoriesViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        /*
        let availableWidth = (self.ViewWidth - (self.HorizontalSectionPadding * 2.0)) - (self.ItemsPerRow.decrement().CGFloatValue * self.HorizontalSpacingBetweenItems)
 
        let cellWidth   = availableWidth / CGFloat(self.ItemsPerRow)
        let cellHeight  = cellWidth
        */
        
        let cellWidth = PARepositoryCell.CELL_WITDTH
        let cellHeight = PARepositoryCell.CELL_HEIGHT
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return self.HorizontalSpacingBetweenItems
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return self.SectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return self.SectionInsets.left
    }
}
