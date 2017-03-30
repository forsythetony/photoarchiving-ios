//
//  PARepositoryCell.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 3/29/17.
//  Copyright © 2017 Tony Forsythe. All rights reserved.
//

import UIKit

class PARepositoryCell: UICollectionViewCell {
    
    static let CELL_HEIGHT : CGFloat = 150.0
    static let CELL_WITDTH : CGFloat = 150.0
    
    static let REUSE_ID = "parepositorycellreuseid"
    
    
    @IBOutlet weak var mainTitleLabel: UILabel!
    
    
    @IBOutlet weak var timeframeLabel: UILabel!
    
    @IBOutlet weak var imageCountLabel: UILabel!
    
    
    
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
