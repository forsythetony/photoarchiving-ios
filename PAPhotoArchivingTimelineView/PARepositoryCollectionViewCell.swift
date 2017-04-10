//
//  PARepositoryCollectionViewCell.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 12/9/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import UIKit
import Spring

class PARepositoryCollectionViewCell: UICollectionViewCell {
    
    static let ReuseID = "PARepositoryCollectionViewCellReuseIdentifier"
    static let Height : CGFloat = 200.0
    static let Width : CGFloat = 200.0
    
    
    let ImageView   = SpringImageView()
    let TitleLabel  = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupViews()
    }
    
    private func setupViews() {
        
        
        self.contentView.clipsToBounds = true
        
        
        //  Setup label
        var frm = self.frame
    
        frm.PASetOriginToZero()
        
        let titleLabelHeight : CGFloat = 25.0
        
        
        frm.size.height = titleLabelHeight
        
        TitleLabel.frame = frm
        TitleLabel.font = Font.PARegularFontWithSize(size: 10.0)
        
        //  Hide the title label for now
        TitleLabel.alpha = 1.0
        
        
        self.contentView.addSubview(TitleLabel)
        
        frm.size.height = self.frame.height - titleLabelHeight
        frm.origin.y = titleLabelHeight
        
        ImageView.frame = frm
        ImageView.contentMode = .scaleAspectFill
        ImageView.alpha = 0.8
        
        self.contentView.addSubview(ImageView)
        
        self.contentView.sendSubview(toBack: ImageView)
       
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
