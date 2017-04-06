//
//  PACustomEurekaRows.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 4/2/17.
//  Copyright © 2017 Tony Forsythe. All rights reserved.
//

import UIKit
import Eureka
import MapKit
import CoreLocation


extension CLLocationCoordinate2D {
    var PAValueString : String {
        get {
            return String.init(format: "%3.5f,%3.5f", self.latitude, self.longitude)
        }
    }
}
//func ==<T : CLLocationCoordinate2D>(lhs: T, rhs: T) -> Bool {
//    if lhs.latitude == rhs.latitude && rhs.latitude == rhs.latitude {
//        return true
//    }
//    return false
//}
public final class PAImageViewCell : Cell<UIImage>, CellType {
    
    private let CELL_HEIGHT : CGFloat = 230.0
    
    @IBOutlet weak var mainImageView : UIImageView!
    
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override public func setup() {
        super.setup()
        
        height = { self.CELL_HEIGHT }
        mainImageView.contentMode = .scaleAspectFill
        
        
    }
    
    override public func update() {
        super.update()
        
        if let img = row.value  {
            
            height = { self.CELL_HEIGHT }
            mainImageView.image = img
            
        }
        else {
            height = { self.CELL_HEIGHT }
        }
    }
}

public final class PAImageRow : Row<PAImageViewCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<PAImageViewCell>(nibName: "PAImageViewCell")
    }
    
}

protocol PALocationCellDelegate {
    var degreesDelta : CLLocationDegrees { get }
    func didUpdateDegreesDelta( delta : CLLocationDegrees )
}
public final class PALocationCell : Cell<CLLocation>, CellType, MKMapViewDelegate {
    
    private let CELL_HEIGHT : CGFloat = 435.0
    
    @IBOutlet weak var mapView : MKMapView!
    @IBOutlet weak var mainValueLabel : UILabel!
    
    var isSettingLocation = false
    var isFirstSetting = true
    
    var delegate : PALocationCellDelegate?
    
    
    lazy var pinView: UIImageView = { [unowned self] in
        let v = UIImageView(frame: CGRect(x: 0, y: 0, width: 30.0, height: 30.0))
        v.image = #imageLiteral(resourceName: "map_pin_dark")
        v.image = v.image?.withRenderingMode(.alwaysTemplate)
        v.tintColor = self.tintColor
        v.backgroundColor = .clear
        v.clipsToBounds = true
        v.contentMode = .scaleAspectFit
        v.isUserInteractionEnabled = false
        return v
        }()
    
    lazy var ellipse: UIBezierPath = { [unowned self] in
        let ellipse = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 10.0, height: 5.0))
        return ellipse
    }()
    
    lazy var ellipsisLayer: CAShapeLayer = { [unowned self] in
        let layer = CAShapeLayer()
        layer.bounds = CGRect(x: 0, y: 0, width: 10.0, height: 5.0)
        layer.path = self.ellipse.cgPath
        layer.fillColor = UIColor.gray.cgColor
        layer.fillRule = kCAFillRuleNonZero
        layer.lineCap = kCALineCapButt
        layer.lineDashPattern = nil
        layer.lineDashPhase = 0.0
        layer.lineJoin = kCALineJoinMiter
        layer.lineWidth = 1.0
        layer.miterLimit = 10.0
        layer.strokeColor = UIColor.gray.cgColor
        return layer
    }()
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    
    override public func setup() {
        super.setup()
        
        height = { self.CELL_HEIGHT }
        
        
        mapView.addSubview(pinView)
        mapView.layer.addSublayer(ellipsisLayer)
        mapView.delegate = self
        
        
        let center = mapView.convert(mapView.centerCoordinate, toPointTo: pinView)
        pinView.center = CGPoint(x: center.x, y: center.y - (pinView.bounds.height / 2.0))
        
        mainValueLabel.font = UIFont.PABoldFontWithSize(size: mainValueLabel.font.pointSize)
    }
    
    
    override public func update() {
        super.update()
        
        guard let current_location = row.value else { return }
        
        mainValueLabel.text = current_location.coordinate.PAValueString
        
        
        
        if isFirstSetting {
            
            var delta = self.delegate?.degreesDelta
            
            let region = MKCoordinateRegion(center: current_location.coordinate, span: MKCoordinateSpan(latitudeDelta: delta ?? 4.0, longitudeDelta: delta ?? 4.0))
            
            self.isSettingLocation = true
            mapView.setRegion(region, animated: false)
        }
        
        
        if self.row.isDisabled {
            self.mapView.isUserInteractionEnabled = false
        }
        else {
            mapView.isUserInteractionEnabled = true
        }
    }
    
    public func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        ellipsisLayer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.pinView.center = CGPoint(x: self!.pinView.center.x, y: self!.pinView.center.y - 10)
        })
    }
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        ellipsisLayer.transform = CATransform3DIdentity
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.pinView.center = CGPoint(x: self!.pinView.center.x, y: self!.pinView.center.y + 10)
        })
        
        let delta = max(mapView.region.span.latitudeDelta, mapView.region.span.longitudeDelta)
        
        self.delegate?.didUpdateDegreesDelta(delta: delta)
        
        row.value = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        if isFirstSetting {
            isFirstSetting = false
        }
        
        if !isSettingLocation {
            update()
        }
        else {
            isSettingLocation = false
        }
        
    }
}

public final class PALocationRow: Row<PALocationCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<PALocationCell>(nibName: "PALocationViewCell")
    }
    
    
}
