//
//  PAPhotoInfoLocationTableViewCell.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 11/26/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class PAPhotoInfoLocationTableViewCell: UITableViewCell {
    var titleLabel = UILabel()
    var mainLabel = UILabel()
    var locationString : String? {
        didSet {
            mainLabel.text = locationString!
        }
    }
    var locationCoord : CLLocationCoordinate2D? {
        didSet {
            
            let region = MKCoordinateRegion(center: self.locationCoord!, span: MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.055), longitudeDelta: CLLocationDegrees(0.055)))
                
            mapView.setRegion(region, animated: false)
         
            let annot = MKPointAnnotation()
            
            annot.coordinate = locationCoord!
            annot.title = "Taken"
            
            mapView.addAnnotation(annot)
        }
    }
    
    var didSetupConstraints = false
    
    
    let mapView = MKMapView()
    
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
        
        mainLabel.textAlignment = .center
        
        
//        titleLabel.PAAutoLayoutSetup()
//        mainLabel.PAAutoLayoutSetup()
//        mapView.PAAutoLayoutSetup()
        
        self.contentView.PAAutoLayoutSetup()
        
        
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(mainLabel)
        self.contentView.addSubview(mapView)
        
        let titleLabelHeight : CGFloat = 40.0
        let totalWidth : CGFloat = UIApplication.shared.keyWindow?.frame.width ?? 320.0
        
        var frm = CGRect()
        
        //  Title Label Frame
        
        frm.origin.x = Constants.PhotoInformationVC.TableViewCells.InfoLocationCell.TitleLabelLeftMargin
        frm.origin.y = 0.0
        frm.size.width = totalWidth / 2.0 - frm.origin.x
        frm.size.height = titleLabelHeight
        
        titleLabel.frame = frm
        
        //  Main Label Frame
        
        frm.origin.x = 0.0
        frm.size.width = totalWidth
        frm.size.height = titleLabelHeight
        frm.origin.y = titleLabelHeight
        
        mainLabel.frame = frm
        
        //  Map View Frame
        
        frm.origin.y += titleLabelHeight
        frm.size.height = Constants.PhotoInformationVC.TableViewCells.InfoLocationCell.CellHeight - (titleLabelHeight * 2.0)
        frm.size.width = totalWidth
        
        mapView.frame = frm
        
        mapView.isUserInteractionEnabled = false
        
    }
    
    override func updateConstraints() {
        
        super.updateConstraints()
        

    }
}
