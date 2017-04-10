//
//  PANotificationTableViewCell.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 4/9/17.
//  Copyright © 2017 Tony Forsythe. All rights reserved.
//

import UIKit

class PANotificationTableViewCell: UITableViewCell {

    static let REUSE_IDENTIFIER         = "PANotificationTableViewCellReuseIdentifier"
    static let CELL_HEIGHT : CGFloat    = 110.0
    
    
    @IBOutlet weak var topBarContainerView: UIView!
    @IBOutlet weak var notificationTypeImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var datePostedLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        _setup()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    private func _setup() {
     
        //  Top Container View
        topBarContainerView.backgroundColor = Color.white
        
        //  Date Posted Label
        datePostedLabel.text = "DP Here!"
        
        //  Profile Image View
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2.0
        
        //  Text View
        
        textView.text = "Hey there!"
        
        
    }
}
