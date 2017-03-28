//
//  PAPhotographCell.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 11/8/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import UIKit
import Kingfisher
import Spring

protocol PAPhotographCellDelegate {
    func PAPhotographCellWasTapped( sender : PAPhotographCell )
}

class PAPhotographCell: UIView {

    var photographInfo : PAPhotograph?
    var delegate : PAPhotographCellDelegate?
    
    
    let photoImageView = SpringImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupImageView()
        
    }
    
    convenience init(frame : CGRect, info : PAPhotograph) {
        
        var newFrame = CGRect()
        newFrame.size.width = Constants.Timeline.PhotographCell.Width
        newFrame.size.height = Constants.Timeline.PhotographCell.Height
        
        self.init(frame : newFrame)
        
        self.photographInfo = info
        
        updateInformation()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupImageView() {
        
        var imgViewFrame = self.frame
        
        imgViewFrame.origin.x = 0.0
        imgViewFrame.origin.y = 0.0
        
        imgViewFrame.size.width = min(imgViewFrame.size.height, imgViewFrame.size.width)
        imgViewFrame.size.height = imgViewFrame.size.width
        
        photoImageView.frame = imgViewFrame
        photoImageView.contentMode = .scaleAspectFit
        photoImageView.image = UIImage.PAImageWithSizeAndColor(size: imgViewFrame.size, color: .orange)
        
        self.addSubview(photoImageView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(PAPhotographCell.didTapPhotograph(sender:)))
        
        tap.numberOfTapsRequired = 1
        
        self.addGestureRecognizer(tap)
    }
    
    private func updateInformation() {
        
        if let info = self.photographInfo {
            
            if let img_url = URL(string: info.mainImageURL) {
                
                self.photoImageView.kf.setImage(    with: img_url,
                                                    placeholder: nil,
                                                    options: nil,
                                                    progressBlock: nil,
                                                    completionHandler: { image, error, cacheType, imageURL in
                    
                                                        self.photoImageView.animation = Constants.Spring.Animations.zoomIn
                                                        self.photoImageView.duration = 0.6
                                                        self.photoImageView.animate()
                                                        
                })
            }
            else {
                self.photoImageView.image = #imageLiteral(resourceName: "timeline_thumbnail_placeholder")
            }
            
        }
        
    }
    
    func didTapPhotograph( sender : UITapGestureRecognizer ) {
    
        self.delegate?.PAPhotographCellWasTapped(sender: self)
    }
}
