//
//  PAPhotoInformationHeaderView.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 3/28/17.
//  Copyright © 2017 Tony Forsythe. All rights reserved.
//

import UIKit
import SnapKit
import Spring

protocol PAPhotoInformationHeaderDelegate {
    func PAPhotoInformationHeaderDidTap()
}
class PAPhotoInformationHeaderView: UIView {

    static let VIEW_HEIGHT  : CGFloat = 300.0
    static let VIEW_TAG     : Int = 8726346
    
    var mainImageView : SpringImageView!
    
    var delegate : PAPhotoInformationHeaderDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        _setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    /*
        SETUP FUNCTIONS
    */
    private func _setup() {
        
        self.mainImageView = SpringImageView(frame: self.bounds)
        self.mainImageView.tag = PAPhotoInformationHeaderView.VIEW_TAG
        self.mainImageView.contentMode = .scaleAspectFit
        self.mainImageView.isUserInteractionEnabled = true
        
        let tap_gest = UITapGestureRecognizer(target: self, action: #selector(PAPhotoInformationHeaderView.didTapImage(sender:)))
        
        self.mainImageView.addGestureRecognizer(tap_gest)
        
        self.addSubview(self.mainImageView)
        
        self.mainImageView.snp.makeConstraints { (maker) in
            
            maker.top.equalTo(self.snp.top)
            maker.bottom.equalTo(self.snp.bottom)
            maker.left.equalTo(self.snp.left)
            maker.right.equalTo(self.snp.right)
        }
    }
    
    
    @objc func didTapImage( sender : UITapGestureRecognizer ) {
        
        self.delegate?.PAPhotoInformationHeaderDidTap()
    }
    
    
    

}
