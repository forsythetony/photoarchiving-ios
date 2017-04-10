//
//  PAPhotoInfoRegularTableViewCell.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 11/9/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import UIKit

class PAPhotoInfoRegularTableViewCell: UITableViewCell {

    var titleLabel = UILabel()
    var supplementaryLabel = UILabel()
    var mainLabel = UILabel()
    
    
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
        
        
        //Color.assignDebugBackgroundColorsToViews(views: [titleLabel, supplementaryLabel, mainLabel])
        //self.contentView.backgroundColor = Color.black
        
        titleLabel.PAAutoLayoutSetup()
        supplementaryLabel.PAAutoLayoutSetup()
        mainLabel.PAAutoLayoutSetup()
        self.contentView.PAAutoLayoutSetup()
        
        
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(supplementaryLabel)
        self.contentView.addSubview(mainLabel)
        
        self.updateConstraints()
        
        
    }
    
    override func updateConstraints() {
        
        super.updateConstraints()
        
        let totalHeight = Constants.PhotoInformationVC.TableViewCells.TFInfoCellRegularHeight
        
        let titleLabelHeight = totalHeight * 0.3
        
        self.contentView.autoresizingMask = UIViewAutoresizing.flexibleWidth
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: Constants.PhotoInformationVC.TableViewCells.InfoCell.TitleLabelLeftMargin),
            titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0.0),
            titleLabel.heightAnchor.constraint(equalToConstant: titleLabelHeight),
            titleLabel.rightAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            supplementaryLabel.leftAnchor.constraint(equalTo: self.contentView.centerXAnchor, constant: 0.0),
            supplementaryLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: 0.0),
            supplementaryLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0.0),
            supplementaryLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0.0),
            mainLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: Constants.PhotoInformationVC.TableViewCells.InfoCell.MainLabelLeftMargin),
            mainLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5.0),
            mainLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 5.0),
            mainLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: 0.0)
            ])
    }
}
