//
//  PATextEditView.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 11/26/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import UIKit

protocol PATextEditViewDelegate {
    func PATextEditViewDidTapOK( editView : PATextEditView )
    func PATextEditViewDidTapCancel( editView : PATextEditView )
}




class PATextEditView: UIView {

    var title : String?
    var value : String?
    
    
    let titleLabel      = UILabel(frame: CGRect.zero)
    let editTextField   = UITextField(frame: CGRect.zero)
    let cancelButton    = UIButton(frame: CGRect.zero)
    let okButton        = UIButton(frame: CGRect.zero)
    
    private struct constants {
        static let default_view_height  : CGFloat = 300.0
        static let default_view_width   : CGFloat = 300.0
        
        static let default_title_label_height   : CGFloat = 40.0
        static let default_text_field_height    : CGFloat = 40.0
        static let default_button_width         : CGFloat = 100.0
        static let default_button_height        : CGFloat = 40.0
        
        static let title_label_horizontal_inset : CGFloat = 5.0
        static let text_field_horizontal_inset  : CGFloat = 5.0
        static let button_horizontal_inset      : CGFloat = 5.0
        
        static let cancel_button_title = "Cancel"
        static let confirm_button_title = "Ok"
    }
    
    var delegate : PATextEditViewDelegate?
    
    init(title : String, value : String) {
        let frm = CGRect(x: 0.0, y: 0.0, width: constants.default_view_width, height: constants.default_view_height)
        super.init(frame: frm)
        
        setupWithNoAutoLayout()
        
        self.titleLabel.text = title
        self.editTextField.text = value
        self.title = title
        self.value = value
    }
    
    private func setupWithNoAutoLayout() {
        
        let total_width = constants.default_view_width
        
        
        var frm = CGRect.zero
        
        //  Setup Title Label
        titleLabel.textAlignment = .center
        
        frm.size.height = constants.default_title_label_height
        frm.size.width = total_width - (constants.title_label_horizontal_inset * 2.0)
        frm.origin.x = constants.title_label_horizontal_inset
        frm.origin.y = 0.0
        
        self.addSubview(titleLabel)
        titleLabel.frame = frm
        
        
        //  Setup Text Field
        
        editTextField.addTarget(    self,
                                    action: #selector(self.TextFieldDidUpdate(sender:)),
                                    for: .valueChanged)
        
        frm.origin.y = constants.default_title_label_height
        self.addSubview(editTextField)
        editTextField.frame = frm
        
        //  Setup Buttons
        
        cancelButton.addTarget(self, action: #selector(self.DidTapCancel(sender:)), for: .touchUpInside)
        cancelButton.setTitle(constants.cancel_button_title, for: .normal)
        
        frm.origin.y += constants.default_title_label_height
        frm.origin.x = constants.button_horizontal_inset
        frm.size.height = constants.default_button_height
        frm.size.width = constants.default_button_width
        
        self.addSubview(cancelButton)
        cancelButton.frame = frm
        
        okButton.addTarget(self, action: #selector(self.DidTapOK(sender:)), for: .touchUpInside)
        okButton.setTitle(constants.confirm_button_title, for: .normal)
        
        frm.origin.x = total_width - constants.button_horizontal_inset - constants.default_button_width
        
        self.addSubview(okButton)
        okButton.frame = frm
        
    }
    
    private func setupWithAutoLayout() {
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func TextFieldDidUpdate( sender : UITextField ) {
        
    }
    func DidTapCancel( sender : UIButton ) {
        self.delegate?.PATextEditViewDidTapCancel(editView: self)
    }
    
    func DidTapOK( sender : UIButton ) {
        self.delegate?.PATextEditViewDidTapOK(editView: self)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    override var intrinsicContentSize: CGSize {
        get {
            return CGSize(  width: constants.default_view_width,
                            height: constants.default_view_height)
        }
    }
}
