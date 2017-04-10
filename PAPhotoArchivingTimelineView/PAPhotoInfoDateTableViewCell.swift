//
//  PAPhotoInfoDateTableViewCell.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 11/26/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import UIKit

class PAPhotoInfoDateTableViewCell: UITableViewCell {
    
    var titleLabel = UILabel()
    var supplementaryLabel = UILabel()
    var mainLabel = UILabel()
    var mainDate : Date? {
        didSet {
            if let dte = self.mainDate {
                let date_str = PADateManager.sharedInstance.getDateString(date: dte, formatType: .Pretty)
                
                self.mainLabel.text = date_str
            }
        }
    }
    var dateConfidence : Float? {
        didSet {
            if let conf = self.dateConfidence {
                let date_conf_str = conf.PAStringValue
                
                supplementaryLabel.text = "Confidence: \(date_conf_str)"
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLabels()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func setupLabels() {
        
        
        
        
        titleLabel.font = Font.PABoldFontWithSize(size: Constants.PhotoInformationVC.TableViewCells.TFInfoCellTitleFontSize)
        mainLabel.font = Font.PARegularFontWithSize(size: Constants.PhotoInformationVC.TableViewCells.TFInfoCellMainLabelFontSize)
        supplementaryLabel.font = Font.PAItalicsFontWithSize(size: Constants.PhotoInformationVC.TableViewCells.TFInfoCellSupplementaryLabelFontSize)
        supplementaryLabel.textAlignment = .left
        
        
        //Color.assignDebugBackgroundColorsToViews(views: [titleLabel, supplementaryLabel, mainLabel])
        //self.contentView.backgroundColor = Color.black
        
//        titleLabel.PAAutoLayoutSetup()
//        supplementaryLabel.PAAutoLayoutSetup()
//        mainLabel.PAAutoLayoutSetup()
//        self.contentView.PAAutoLayoutSetup()
        
        
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(supplementaryLabel)
        self.contentView.addSubview(mainLabel)
        
        //self.updateConstraints()
        
        self.setupFramesManually()
    }
    
    private func setupFramesManually() {
        
        let totalWidth = UIApplication.shared.keyWindow?.frame.size.width ?? 320.0
        let labelHeight = Constants.PhotoInformationVC.TableViewCells.InfoDateCell.TitleLabelHeight
        
        var frm = CGRect()
        
        //  Title Label
        frm.origin.x = Constants.PhotoInformationVC.TableViewCells.InfoDateCell.TitleLabelLeftMargin
        frm.size.height = labelHeight
        frm.size.width = totalWidth / 2.0 - frm.origin.x
        
        titleLabel.frame = frm
        
        //  Supplementary Label
        frm.origin.x = totalWidth / 2.0
        frm.size.width = totalWidth / 2.0
        
        supplementaryLabel.frame = frm
        
        //  Main Label
        
        frm.origin.x = Constants.PhotoInformationVC.TableViewCells.InfoDateCell.MainLabelLeftMargin
        frm.origin.y = labelHeight
        frm.size.width = totalWidth
        frm.size.height = Constants.PhotoInformationVC.TableViewCells.InfoDateCell.CellHeight - labelHeight
        
        mainLabel.frame = frm
        
        
        
        
        
    }
    
//    override func updateConstraints() {
//        
//        super.updateConstraints()
//        
//        let totalHeight = Constants.PhotoInformationVC.TableViewCells.TFInfoCellRegularHeight
//        
//        let titleLabelHeight = totalHeight * 0.3
//        
//        self.contentView.autoresizingMask = UIViewAutoresizing.flexibleWidth
//        
//        NSLayoutConstraint.activate([
//            titleLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: Constants.PhotoInformationVC.TableViewCells.InfoCell.TitleLabelLeftMargin),
//            titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0.0),
//            titleLabel.heightAnchor.constraint(equalToConstant: titleLabelHeight),
//            titleLabel.rightAnchor.constraint(equalTo: self.contentView.centerXAnchor),
//            supplementaryLabel.leftAnchor.constraint(equalTo: self.contentView.centerXAnchor, constant: 0.0),
//            supplementaryLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: 0.0),
//            supplementaryLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0.0),
//            supplementaryLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0.0),
//            mainLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: Constants.PhotoInformationVC.TableViewCells.InfoCell.MainLabelLeftMargin),
//            mainLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5.0),
//            mainLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 5.0),
//            mainLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: 0.0)
//            ])
//    }
}
