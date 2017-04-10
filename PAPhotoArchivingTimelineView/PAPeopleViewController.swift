//
//  PAPeopleViewController.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 4/10/17.
//  Copyright © 2017 Tony Forsythe. All rights reserved.
//

import UIKit

class PAPeopleViewController: UIViewController {

    @IBOutlet weak var searchScopeControl: UISegmentedControl!

    @IBOutlet weak var resultsTableView: UITableView!
    
    @IBOutlet weak var peopleSearchBar: UISearchBar!
    
    fileprivate let userContainer = PAUserContainer()
    fileprivate let dataMan = PADataManager.sharedInstance
    fileprivate let REUSE_ID = "cellreuseidpeople"
    
    fileprivate var selectedUser : PAUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationManager.updateCurrentIndex(page: .people)
        
        
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    private func _setup() {
        
        _setupData()
        _setupViews()
    }
    
    private func _setupData() {
        
        dataMan.pullAllUsers { (new_user) in
            
            if new_user.uid != PAGlobalUser.sharedInstace.userID {
                self.userContainer.insertUser(user: new_user)
                self.updateTable()
            }
        }
    }
    
    private func _setupViews() {
        
        self.title = "People"
        
        _setupScopeControl()
        _setupSearchBar()
        _setupTableView()
        _setupNavigationBar()
        _setupPanelButton()
    }
    
    private func _setupNavigationBar() {
        
        self.setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.navigationBar.barStyle = .black
        
        //self.navigationController!.navigationBar.barTintColor = Color.MainApplicationColor
        self.navigationController!.navigationBar.barTintColor = Color.init(hex: "263F6A")
    }
    
    private func _setupPanelButton() {
        
        let panel_button = UIBarButtonItem(image: #imageLiteral(resourceName: "panel_button_white"), landscapeImagePhone: nil, style: .plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
        panel_button.tintColor = Color.white
        
        navigationItem.leftBarButtonItem = panel_button
    }
    
    private func _setupScopeControl() {
        
        searchScopeControl.removeAllSegments()
        
        searchScopeControl.insertSegment(withTitle: "All", at: 0, animated: false)
        searchScopeControl.insertSegment(withTitle: "People", at: 1, animated: false)
        
        searchScopeControl.addTarget(self, action: #selector(PAPeopleViewController.segmentedControlDidUpdate(sender:)), for: .valueChanged)
        searchScopeControl.selectedSegmentIndex = 0
    }
    
    private func _setupSearchBar() {
        
        peopleSearchBar.delegate      = self
        peopleSearchBar.placeholder 	= "Search People"
        
        peopleSearchBar.searchBarStyle = .minimal
        peopleSearchBar.tintColor = Color.white
        peopleSearchBar.barTintColor = Color.yellow
        
        let attributed_placeholder = NSAttributedString(    string: "Search People",
                                                            attributes: [ NSForegroundColorAttributeName : PAColors.PAWhiteOne.colorVal])
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).attributedPlaceholder = attributed_placeholder
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = Color.white
        
        peopleSearchBar.setImage(#imageLiteral(resourceName: "search_bar_icon_white"), for: .search, state: .normal)
        peopleSearchBar.setImage(#imageLiteral(resourceName: "search_bar_cancel_icon"), for: .clear, state: .normal)
        peopleSearchBar.setImage(#imageLiteral(resourceName: "search_bar_cancel_icon"), for: .clear, state: .highlighted)
    }
    
    private func _setupTableView() {
        
        resultsTableView.register(UITableViewCell.self, forCellReuseIdentifier: REUSE_ID)
        
        resultsTableView.dataSource = self
        resultsTableView.delegate = self
    }
    
    private func updateTable() {
        
        self.resultsTableView.reloadData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let segue_id = segue.identifier else { return }
        
        
        switch segue_id {
        case Constants.SegueIDs.SegueFromPeopleToUserProfile:
            
            let dest = segue.destination as! PAUserProfileViewController
            
            dest.setUser = selectedUser
            
        default:
            break
        }
    }
}

extension PAPeopleViewController {
    
    func segmentedControlDidUpdate( sender : UISegmentedControl ) {
        
        let debug_message = String.init(format: "Segmented control did switch to %d", sender.selectedSegmentIndex)
        
        let index = sender.selectedSegmentIndex
        
        if index == 0 {
            userContainer.friendsOnly = false
        }
        else {
            userContainer.friendsOnly = true
        }
        
        resultsTableView.reloadData()
        
        print( debug_message.PAPadWithNewlines() )
    }
}

extension PAPeopleViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return userContainer.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: REUSE_ID) else {
            return UITableViewCell()
        }
        
        
        guard let user_info = userContainer.userAtIndex(index: indexPath.row) else {
            return UITableViewCell()
        }
        
        cell.textLabel?.text = user_info.email
        
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let user_info = userContainer.userAtIndex(index: indexPath.row) else {
            return
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        selectedUser = user_info
        
        self.performSegue(withIdentifier: Constants.SegueIDs.SegueFromPeopleToUserProfile, sender: nil)
    }
}

extension PAPeopleViewController : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        userContainer.updateSearchedUsers(searchString: searchText)
        resultsTableView.reloadData()
    }
}
