//
//  PARepositoriesViewController.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 12/9/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import UIKit
import Kingfisher
import SCLAlertView
import Spring

class PARepositoriesViewController: UIViewController {

    @IBOutlet weak var RepositoriesCollectionView: UICollectionView!

    @IBOutlet weak var repositoriesSearchBar: UISearchBar!
    
    let dataMan = PADataManager.sharedInstance
    
    lazy var Repositories = PARepositoryContainer()
    
    let ItemsPerRow : Int                       = 3
    let HorizontalSectionPadding : CGFloat      = 10.0
    let HorizontalSpacingBetweenItems : CGFloat = 10.0
    
    let backgroundImageView = UIImageView()
    let blurredBackgroundImageView = UIImageView()
    
    var selectedRepository : PARepository?
    var editingRepository : PARepository?
    
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

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationManager.updateCurrentIndex(page: .repositories)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _resetSearch()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        self.title = "Browse"
        
        _dataSetup()
        _setupCollectionView()
        _setupImageView()
        _setupAddButton()
        _setupPanelButton()
        _setupSearchBar()
        _setupNavigationBar()
        
        //_searchAfterTimer()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    
    /*
        SETUP FUNCTIONS
    */
    private func _resetSearch() {
        
        
        
        Repositories.upadateSearchedRepositories(searchPackage: PASearchPackage())
        RepositoriesCollectionView.reloadData()
        repositoriesSearchBar.resignFirstResponder()
    }
    private func _searchAfterTimer() {
        
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { (timer) in
            let start_package = PASearchPackage(filterMode: .creatorID, filterOperator: .equals, searchString: PAGlobalUser.sharedInstace.userID)
            
            self.Repositories.upadateSearchedRepositories(searchPackage: start_package)
            
            self.RepositoriesCollectionView.reloadData()
        }
    }
    private func _dataSetup() {
        self.dataMan.delegate = self
        
        if !self.dataMan.isConfigured {
            self.dataMan.configure()
        }
        else {
            self.dataMan.pullRepositories()
        }
        
    }
    
    private func _setupSearchBar() {
        
        repositoriesSearchBar.delegate      = self
        repositoriesSearchBar.placeholder 	= "Search Repositories"
        
        repositoriesSearchBar.searchBarStyle = .minimal
        repositoriesSearchBar.tintColor = Color.white
        repositoriesSearchBar.barTintColor = Color.yellow
        
        let attributed_placeholder = NSAttributedString(    string: "Search Repositories",
                                                            attributes: [ NSForegroundColorAttributeName : PAColors.PAWhiteOne.colorVal])
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).attributedPlaceholder = attributed_placeholder
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = Color.white
        
        repositoriesSearchBar.setImage(#imageLiteral(resourceName: "search_bar_icon_white"), for: .search, state: .normal)
        repositoriesSearchBar.setImage(#imageLiteral(resourceName: "search_bar_cancel_icon"), for: .clear, state: .normal)
        repositoriesSearchBar.setImage(#imageLiteral(resourceName: "search_bar_cancel_icon"), for: .clear, state: .highlighted)
        
        
    }
    private func _setupPanelButton() {
        
        let pb = UIBarButtonItem(image: #imageLiteral(resourceName: "panel_button_white"), style: .plain, target: revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
        
        pb.tintColor = Color.PAWhiteOne
        
        navigationItem.leftBarButtonItem = pb
    }
    private func _setupBackButton() {
        
        let bb = UIBarButtonItem(image: #imageLiteral(resourceName: "back_button_white"), style: .plain, target: self, action: #selector(PARepositoriesViewController.didTapBackButton(sender:)))
        
        bb.tintColor = Color.PAWhiteOne
        
        navigationItem.leftBarButtonItem = bb
    }
    
    private func _setupAddButton() {
        
        let add_button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(PARepositoriesViewController.didTapAddButton(sender:)))
        
        add_button.tintColor = Color.PAWhiteOne
        
        self.navigationItem.rightBarButtonItem = add_button
    }
    
    func didTapBackButton( sender : UIBarButtonItem ) {
        self.navigationController?.popViewController(animated: true)
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
        
        
        RepositoriesCollectionView.register(UINib.init(nibName: "PARepositoryCell", bundle: Bundle.main), forCellWithReuseIdentifier: PARepositoryCell.REUSE_ID)
        
        RepositoriesCollectionView.delegate     = self
        RepositoriesCollectionView.dataSource   = self
        
        RepositoriesCollectionView.backgroundColor = Color.clear
        
    }
    
    /*
        BUTTON ACTION HANDLERS
    */
    func didTapAddButton( sender : UIBarButtonItem ) {
        
        let message = "Looks like you tapped the add button there kiddo!"
        
        print(String.init(format: "%@".PAPadWithNewlines(), message))
        
        let storyboard = UIStoryboard.PAMainStoryboard
        
        let add_repository_vc = storyboard.instantiateViewController(withIdentifier: PAAddRepositoryViewController.STORYBOARD_ID) as! PAAddRepositoryViewController
        
        present(    add_repository_vc,
                    animated: true,
                    completion: nil)
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
    
    private func _setupNavigationBar() {
        
        setNeedsStatusBarAppearanceUpdate()
        navigationController?.navigationBar.barStyle = .black
        //navigationController!.navigationBar.barTintColor = Color.MainApplicationColor
        self.navigationController!.navigationBar.barTintColor = Color.init(hex: "263F6A")
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
    func PADataManagerDidCreateUser(new_user: PAUserUploadPackage?, error: Error?) {
        
    }

    internal func PADataManagerDidDeletePhotograph(photograph: PAPhotograph) {
        
    }

    internal func PADataManagerDidDeleteStoryFromPhotograph(story: PAStory, photograph: PAPhotograph) {
        
    }

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
                
                cell.thumbnailImageView.image = #imageLiteral(resourceName: "repository_thumbnail_default")
            }
            else {
                
                cell.thumbnailImageView.kf.setImage(    with: URL(string: imgPath)!,
                                                        placeholder: nil,
                                                        options: nil,
                                                        progressBlock: nil,
                                                        completionHandler: { (image, error, cacheType, url) in
                                                            
                                                            cell.thumbnailImageView.animation = Constants.Spring.Animations.fadeIn
                                                            
                                                            cell.thumbnailImageView.duration = 0.7
                                                            
                                                            cell.thumbnailImageView.animate()
                })
            }
            
            let start_year = PADateManager.sharedInstance.getDateString(date: cellInfo.startDate!, formatType: .YearOnly)
            let end_year = PADateManager.sharedInstance.getDateString(date: cellInfo.endDate!, formatType: .YearOnly)
            
            let date_span_string = String.init(format: "%@-%@", start_year, end_year)
            
            cell.timeframeLabel.text = date_span_string
            
            cell.mainTitleLabel.text = cellInfo.title
            
            cell.imageCountLabel.text = String.init(format: "%d", cellInfo.totalPhotographs)
            
            cell.delegate = self
            
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

extension PARepositoriesViewController : UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        repositoriesSearchBar.resignFirstResponder()
    }
}
extension PARepositoriesViewController : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let newText = searchBar.text {
            
            let filterMode = getFilterModeForString(searchString: newText)
            
            Repositories.upadateSearchedRepositories(searchPackage: filterMode)
            
            RepositoriesCollectionView.reloadData()
        }
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        
    }
    
    private func getFilterModeForString( searchString : String ) -> PASearchPackage {
        
        
        var searchPackage = PASearchPackage()
        searchPackage.searchString = searchString
        
        let splitter = ":"
        
        guard searchString.range(of: splitter) != nil else {
            return searchPackage
        }
        
        
        let search_array = searchString.components(separatedBy: splitter)
        
        if search_array.count == 2 {
            searchPackage.filterMode = PARepositoriesFilterMode.descriptorForSearchString(str: search_array[0])
            searchPackage.searchString = search_array[1]
            
        }
        else if search_array.count == 3 {
            searchPackage.filterMode = PARepositoriesFilterMode.descriptorForSearchString(str: search_array[0])
            searchPackage.searchString = search_array[2]
            searchPackage.filterOperator = PAOperator.getOperatorTypeForString(str: search_array[1])
        }
        
        print( searchPackage.JSONStringDescriptor() )
        
        return searchPackage
        
    }
    
    fileprivate func deleteRepositoryAlert() {
        guard let e = self.editingRepository else { return }
        
        let alert = SCLAlertView()
        
        alert.addButton("Yes") { 
            self.deleteRepository()
        }
        
        
        alert.showWarning("Are you sure?", subTitle: "Are you sure you want to delete this repository?").setDismissBlock {
            self.editingRepository = nil
        }
    }
    
    fileprivate func deleteRepository() {
        guard let e = self.editingRepository else { return }
        
        self.dataMan.deleteRepository(repo: e)
    }
    
    fileprivate func editRepository() {
        guard let e = self.editingRepository else { return }
        
        
        let edit_vc = UIStoryboard.PAMainStoryboard.instantiateViewController(withIdentifier: PAEditRepositoryViewController.STORYBOARD_ID) as! PAEditRepositoryViewController
        
        edit_vc.newRepository = e
        
        present(edit_vc, animated: true, completion: nil)
    }
}

extension PARepositoriesViewController : PARepositoryCellDelegate {

    
    func didLongPressOnCell(cell: PARepositoryCell) {
        
        guard let ip = RepositoriesCollectionView.indexPath(for: cell) else {
            return
        }
        
        guard let repo = Repositories.repositoryAtIndex(ip.item) else {
            return
        }
        
        
        let actionSheet = UIAlertController(title: "Choose", message: "Choose", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.deleteRepositoryAlert()
            actionSheet.dismiss(animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            actionSheet.dismiss(animated: true, completion: nil)
        }
        
        let editAction = UIAlertAction(title: "Edit", style: .default) { (action) in
            self.editRepository()
            actionSheet.dismiss(animated: true, completion: nil)
        }
        
        let unjoinRepository = UIAlertAction(title: "Unsubscribe", style: .destructive) { (action) in
            
            
        }
        
        let joinRepository = UIAlertAction(title: "Subscribe", style: .default) { (action) in
            
            PADataManager.sharedInstance.addUserToRepository(repository_id: repo.uid)
        }
        
        
        actionSheet.addAction(cancelAction)
        
        let global_user = PAGlobalUser.sharedInstace
        
        if global_user.doesUserHaveCreatedRepository(repo_id: repo.uid) {
            actionSheet.addAction(editAction)
            actionSheet.addAction(deleteAction)
        }
        else {
            
            if global_user.doesUserHaveJoinedRepository(repo_id: repo.uid) {
                actionSheet.addAction(unjoinRepository)
            }
            else {
                actionSheet.addAction(joinRepository)
            }
        }

        
        self.editingRepository = repo
        
        self.present(actionSheet, animated: true, completion: nil)
    }
}
