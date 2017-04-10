//
//  PAStoryTableViewCell.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 3/30/17.
//  Copyright © 2017 Tony Forsythe. All rights reserved.
//

import UIKit
import Spring

class PAStoryTableViewCell: UITableViewCell {
    
    static let REUSE_ID = "PAStoryTableViewCell"
    static let CELL_HEIGHT : CGFloat = 99.0
    
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var uploaderIDLabel: UILabel!
    
    @IBOutlet weak var userImageView: SpringImageView!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        userImageView.layer.cornerRadius = userImageView.bounds.height / 2.0
        userImageView.clipsToBounds = true
        userImageView.contentMode = .scaleAspectFill
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
