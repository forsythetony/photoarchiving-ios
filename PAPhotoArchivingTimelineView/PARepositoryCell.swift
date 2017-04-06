//
//  PARepositoryCell.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 3/29/17.
//  Copyright © 2017 Tony Forsythe. All rights reserved.
//

import UIKit

protocol PARepositoryCellDelegate {
    func didLongPressOnCell( cell : PARepositoryCell)
}

class PARepositoryCell: UICollectionViewCell {
    
    static let CELL_HEIGHT : CGFloat = 150.0
    static let CELL_WITDTH : CGFloat = 150.0
    
    static let REUSE_ID = "parepositorycellreuseid"
    
    
    @IBOutlet weak var mainTitleLabel: UILabel!
    
    
    @IBOutlet weak var timeframeLabel: UILabel!
    
    @IBOutlet weak var imageCountLabel: UILabel!
    
    var longPresser : UILongPressGestureRecognizer?
    
    var delegate : PARepositoryCellDelegate?
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if longPresser == nil {
            longPresser = UILongPressGestureRecognizer(target: self, action: #selector(PARepositoryCell.didLongPress(presser:)))
            
            longPresser!.minimumPressDuration = 1.5
            
            self.contentView.addGestureRecognizer(longPresser!)
            
            self.contentView.isUserInteractionEnabled = true
            self.isUserInteractionEnabled = true
            self.thumbnailImageView.isUserInteractionEnabled = true
        }
        
    }

    func didLongPress( presser : UILongPressGestureRecognizer ) {
        
        delegate?.didLongPressOnCell(cell: self)
    }
}
