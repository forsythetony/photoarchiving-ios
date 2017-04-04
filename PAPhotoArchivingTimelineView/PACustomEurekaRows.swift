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
public final class PALocationCell : Cell<CLLocation>, CellType, MKMapViewDelegate {
    
    private let CELL_HEIGHT : CGFloat = 435.0
    
    @IBOutlet weak var mapView : MKMapView!
    @IBOutlet weak var mainValueLabel : UILabel!
    
    
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
        
        row.value = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        update()
    }
}

public final class PALocationRow: Row<PALocationCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<PALocationCell>(nibName: "PALocationViewCell")
    }
    
    
}
/*
public final class LocationRow : SelectorRow<PushSelectorCell<CLLocation>, MapViewController>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = .show(controllerProvider: ControllerProvider.callback { return MapViewController(){ _ in } }, onDismiss: { vc in _ = vc.navigationController?.popViewController(animated: true) })
        
        displayValueFor = {
            guard let location = $0 else { return "" }
            let fmt = NumberFormatter()
            fmt.maximumFractionDigits = 4
            fmt.minimumFractionDigits = 4
            let latitude = fmt.string(from: NSNumber(value: location.coordinate.latitude))!
            let longitude = fmt.string(from: NSNumber(value: location.coordinate.longitude))!
            return  "\(latitude), \(longitude)"
        }
    }
}


public class MapViewController : UIViewController, TypedRowControllerType, MKMapViewDelegate, CLLocationManagerDelegate {
    
    public var row: RowOf<CLLocation>!
    public var onDismissCallback: ((UIViewController) -> ())?
    
    private var currentUpdatedLocation : MKCoordinateRegion?
    
    lazy var coreLocationManager : CLLocationManager = { [unowned self] in
       
        let manager = CLLocationManager.init()
        
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        return manager
    }()
    
    lazy var mapView : MKMapView = { [unowned self] in
        let v = MKMapView(frame: self.view.bounds)
        v.autoresizingMask = UIViewAutoresizing.flexibleWidth.union(.flexibleHeight)
        return v
        }()
    
    lazy var pinView: UIImageView = { [unowned self] in
        let v = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        v.image = UIImage(named: "map_pin", in: Bundle(for: MapViewController.self), compatibleWith: nil)
        v.image = v.image?.withRenderingMode(.alwaysTemplate)
        v.tintColor = self.view.tintColor
        v.backgroundColor = .clear
        v.clipsToBounds = true
        v.contentMode = .scaleAspectFit
        v.isUserInteractionEnabled = false
        return v
        }()
    
    lazy var currentLocationButton : UIButton = { [unowned self] in
        
        let frm = CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0)
        let b = UIButton(frame: frm)
        
        let b_img = #imageLiteral(resourceName: "user_icon_dark")
        
        b.setImage(b_img, for: .normal)
        b.isUserInteractionEnabled = true
        
        b.addTarget(self, action: #selector(MapViewController.didTapCurrentLocationButton), for: .touchUpInside)
        
        return b
    }()
    
    let width: CGFloat = 10.0
    let height: CGFloat = 5.0
    
    lazy var ellipse: UIBezierPath = { [unowned self] in
        let ellipse = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: self.width, height: self.height))
        return ellipse
        }()
    
    
    lazy var ellipsisLayer: CAShapeLayer = { [unowned self] in
        let layer = CAShapeLayer()
        layer.bounds = CGRect(x: 0, y: 0, width: self.width, height: self.height)
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
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience public init(_ callback: ((UIViewController) -> ())?){
        self.init(nibName: nil, bundle: nil)
        onDismissCallback = callback
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        
        mapView.delegate = self
        mapView.addSubview(pinView)
        mapView.layer.insertSublayer(ellipsisLayer, below: pinView.layer)
        
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(MapViewController.tappedDone(_:)))
        button.title = "Done"
        navigationItem.rightBarButtonItem = button
        
        if let value = row.value {
            let region = MKCoordinateRegionMakeWithDistance(value.coordinate, 400, 400)
            mapView.setRegion(region, animated: true)
        }
        else{
            mapView.showsUserLocation = true
        }
        
        mapView.addSubview(self.currentLocationButton)
        
        coreLocationManager.delegate = self
        coreLocationManager.startUpdatingLocation()
        
        updateTitle()
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let center = mapView.convert(mapView.centerCoordinate, toPointTo: pinView)
        pinView.center = CGPoint(x: center.x, y: center.y - (pinView.bounds.height/2))
        ellipsisLayer.position = center
    }
    
    
    func tappedDone(_ sender: UIBarButtonItem){
        let target = mapView.convert(ellipsisLayer.position, toCoordinateFrom: mapView)
        row.value = CLLocation(latitude: target.latitude, longitude: target.longitude)
        onDismissCallback?(self)
    }
    
    func updateTitle(){
        let fmt = NumberFormatter()
        fmt.maximumFractionDigits = 4
        fmt.minimumFractionDigits = 4
        let latitude = fmt.string(from: NSNumber(value: mapView.centerCoordinate.latitude))!
        let longitude = fmt.string(from: NSNumber(value: mapView.centerCoordinate.longitude))!
        title = "\(latitude), \(longitude)"
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
        updateTitle()
    }
    
    
    @objc public func didTapCurrentLocationButton() {
        
        if let current_region = self.currentUpdatedLocation {
            mapView.setRegion(current_region, animated: false)
        }
    }
    
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let current_location = locations.last else { return }
        
        let region = MKCoordinateRegionMakeWithDistance(current_location.coordinate, 400, 400)
        
        self.currentUpdatedLocation = region
    }
}
 
*/
