//
//  ContentAddSelectorViewController.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 11/8/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import UIKit

class ContentAddSelectorViewController: UIViewController {

    @IBOutlet weak var mainTableView: UITableView!
    
    var paths = [Dictionary<String,String>]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        buildPaths()
        mainTableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.CellIdentifiers.ContentAddScreenChooseCell)
        mainTableView.delegate = self
        mainTableView.dataSource = self
        
        
    }

    func buildPaths() {
        
        let addUser = [ "title" : "Add User", "segueID" : Constants.SegueIDs.ToAddUser]
        let addPhotograph = [ "title" : "Add Photograph", "segueID" : Constants.SegueIDs.ToAddPhotograph]
        let addRecording = [ "title" : "Add Recording", "segueID" : Constants.SegueIDs.ToAddRecording]
        
        paths.append(contentsOf: [addUser, addPhotograph, addRecording])
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let segueID = segue.identifier else {
            return
        }
        
        switch segueID {
            
        case Constants.SegueIDs.ToAddPhotograph:
            print("Moving to Add Photograph")
            
            
        case Constants.SegueIDs.ToAddRecording:
            print("Moving to Add Recording")
            
            
        case Constants.SegueIDs.ToAddUser:
            print("Moving to Add User")
            
            
        default:
            print("Improper selection")
            
        }
    }
    
    

}


extension ContentAddSelectorViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paths.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.ContentAddScreenChooseCell, for: indexPath)
        
        let curr = self.paths[indexPath.row]
        
        cell.textLabel?.text = curr["title"]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let curr = self.paths[indexPath.row]
        
        self.performSegue(withIdentifier: curr["segueID"]!, sender: nil)
    }
    
}
