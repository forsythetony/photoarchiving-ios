//
//  PATimelineView.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 10/26/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import UIKit

protocol PATimelineViewDelegate {
    func PATimelineViewPhotographWasTapped( info : PAPhotograph )
    func PATimelineViewLongPress()
}
class PATimelineView: UIView {
    
    private var timelineMan : PATimelineManager?
    
    private var timelineInformation : PATimelineInformation?
    private let mainScrollView = UIScrollView()
    private var repoInfo : PARepository!
    
    private var incViews = [PAIncrementView]()
    private var mainTimeline : UIView?
    
    private var springInfo = PASpringAnimationInformation()
    private var currAnimationIndex = 0
    private var animationTimer : Timer?
    
    private var photographCellViews = [PAPhotographCell]()
    
    
    
    var delegate : PATimelineViewDelegate?
    
    
    init(frame : CGRect, repoInfo : PARepository) {
        
        super.init(frame: frame)
        self.repoInfo = repoInfo
        self.repoInfo.delegate = self
        
        basicSetup()
        
        self.repoInfo.configPhotographs()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    //  MARK: Setup Functions
    private func basicSetup() {
        
        valuesSetup()
        setupSingletons()
        setupScrollView()
        setupMainLine()
        setupIncrementViews()
        animateTimeline()
        animateIncViews()
    }
    
    private func valuesSetup() {
        
        let verticalSpacing = Constants.Timeline.VerticalInset
        let logicalYStart = verticalSpacing
        let timelineLogicalLength = Constants.Timeline.MainTimelineHeight
        let leftMargin = Constants.Timeline.HorizontalInset
        let verticalOutreach = Constants.Timeline.MainLineMargin
        
        self.timelineInformation = PATimelineInformation(   TimelineLogicalStart: logicalYStart,
                                                            TimelineLogicalEnd: (logicalYStart + timelineLogicalLength),
                                                            TimelineLeftMargin: leftMargin,
                                                            TimelineVerticalOutreach: verticalOutreach,
                                                            TimelineVerticalInset: Constants.Timeline.VerticalInset,
                                                            TimelineContentWidth: 320.0,
                                                            TimelineLineWidth : Constants.Timeline.MainLineWidth)
        
        
    }
    
    private func setupScrollView() {
        
        mainScrollView.delegate         = self
        
        mainScrollView.backgroundColor  = Color.TimelineBackgroundColor
        mainScrollView.frame            = self.frame
        
        self.addSubview(mainScrollView)
        
        
        let long_gest = UILongPressGestureRecognizer(target: self, action: #selector(PATimelineView.didLongPress(sender:)))
        long_gest.minimumPressDuration = 1.5
        
        mainScrollView.addGestureRecognizer(long_gest)
        
        if let info = self.timelineInformation {
            
            let scrollViewContentSize = CGSize(width: info.TimelineContentWidth, height: info.ContentViewHeight)
            mainScrollView.contentSize = scrollViewContentSize
        }
    }
    
    private func setupSingletons() {
    
        guard let rInfo = self.repoInfo, let tInfo = self.timelineInformation else {
            return
        }
        
        self.timelineMan = PATimelineManager(   _startDate: rInfo.startDate!,
                                                _endDate: rInfo.endDate!,
                                                _startY: tInfo.TimelineLogicalStart,
                                                _endY: tInfo.TimelineLogicalEnd,
                                                _contentViewWidth: 320.0)
        
        
    }
    
    private func setupMainLine() {
        
        guard let tInfo = self.timelineInformation else {
            return
        }
        
        let startY = tInfo.TimelineStart
        
        let origin = CGPoint(x: tInfo.TimelineLeftMargin, y: startY)
        let height = tInfo.TimelineLength
        let width = tInfo.TimelineLineWidth
        
        let tViewFrame = CGRect(x: origin.x, y: origin.y, width: width!, height: height)
        
        let tView = UIView(frame: tViewFrame)
        
        tView.backgroundColor = Color.TimelineLineColor
        tView.alpha = 0.0
        self.mainTimeline = tView
        mainScrollView.addSubview(tView)
    }
    private func setupIncrementViews() {
        
        guard let tInfo = self.timelineInformation, let tMan = self.timelineMan else {
            return
        }
        
        
        let startYear = tMan.fixedStartDateInt!
        let endYear = tMan.fixedEndDateInt!
        
        let incViewHeight = tMan.recommendedIncViewWidth
        
        let incViewWidth : CGFloat = 100.0
        
        var incViewStartingY = tInfo.TimelineLogicalStart - (incViewHeight / 2.0)
        
        if tMan.timelineStyle == .year {
            for i in startYear...endYear {
                
                var incViewFrame = CGRect(x: -100.0, y: incViewStartingY, width: incViewWidth, height: incViewHeight)
                
                var incViewType : PAIncrementViewType!
                
                if i == startYear  {
                    incViewType = PAIncrementViewType.EndpointStart
                } else if i == endYear {
                    incViewType = PAIncrementViewType.EndpointEnd
                } else if i % 10 == 0 {
                    incViewType = PAIncrementViewType.Ten
                } else if i % 5 == 0 {
                    incViewType = PAIncrementViewType.Five
                } else {
                    incViewType = PAIncrementViewType.Regular
                }
                
                var alpha_val : CGFloat = 0.0
                
                if incViewFrame.origin.y > self.frame.height {
                    var newX : CGFloat = 30.0
                    
                    if let tInfo = self.timelineInformation {
                        newX = tInfo.TimelineLeftMargin + 1
                    }
                    
                    incViewFrame.origin.x = newX
                    alpha_val = 1.0
                }
                
                let incView = PAIncrementView(frame: incViewFrame, year: i, type: incViewType)
                incView.alpha = alpha_val
                
                self.incViews.append(incView)
                
                self.mainScrollView.addSubview(incView)
                
                incViewStartingY += incViewHeight
            }
        }
        else {
            let totalMonths = (endYear - startYear) * 12
            
            var counter = 0
            
            for i in 0...totalMonths {
                
                var incViewFrame = CGRect(x: -100.0, y: incViewStartingY, width: incViewWidth, height: incViewHeight)
                
                var incViewType : PAIncrementViewType!
                
                if counter == 0 && i == 0 {
                    incViewType = PAIncrementViewType.EndpointStart
                
                }
                else if i == totalMonths {
                    incViewType = PAIncrementViewType.EndpointEnd
                }
                else if counter == 12 {
                    incViewType = PAIncrementViewType.Ten
                    counter = 0
                }
                else {
                    incViewType = PAIncrementViewType.Five
                }
                
                var alpha_val : CGFloat = 0.0
                
                
                let incView = PAIncrementView(frame: incViewFrame, year: self.getYearVal(counter: i, startYear: startYear), type: incViewType)
                incView.alpha = alpha_val
                
                self.incViews.append(incView)
                
                self.mainScrollView.addSubview(incView)
                
                incViewStartingY += incViewHeight
                counter += 1
            }
        }
       
    }
    
    private func animateTimeline() {
        
        guard let tInfo = self.timelineInformation, let tLine = self.mainTimeline else {
            return
        }
        
        let finalHeight = tInfo.TimelineLength
        var frm = tLine.frame
        frm.size.height = finalHeight
        
        
        UIView.animate(withDuration: 1.0, animations: {
            
            tLine.frame = frm
            tLine.alpha = 1.0
        })
        
        
    }
    private func animateIncViews() {
        
        self.animationTimer = Timer.scheduledTimer(withTimeInterval: self.springInfo.DelayBetweenAnimations, repeats: true, block: {
            ( timer ) in
            
            let incCount = self.incViews.count
            
            if self.currAnimationIndex >= incCount {
                
                self.animationTimer?.invalidate()
                return
            }
            
            
            let currView = self.incViews[self.currAnimationIndex]
            
            if currView.alpha == 1.0 {
                self.animationTimer?.invalidate()
                return
            }
            
            UIView.animate(withDuration: self.springInfo.Duration, delay: self.springInfo.Delay, usingSpringWithDamping: self.springInfo.SpringDamping, initialSpringVelocity: self.springInfo.SpringVeloctiy, options: [], animations: { 
                
                var newX : CGFloat = 30.0
                
                if let tInfo = self.timelineInformation {
                    newX = tInfo.TimelineLeftMargin + 1
                }
                
                var frm = currView.frame
                frm.origin.x = newX
                
                currView.frame = frm
                currView.alpha = 1.0
                
            }, completion: nil)
            
            self.currAnimationIndex += 1
        })
    }
    
    func addNewPhotograph( new_photo : PAPhotograph ) {
        
        guard let photo_date = new_photo.dateTaken else {
            TFLogger.log(logString: "The photograph with UID -> %@ didn't have a date taken value...", arguments: new_photo.uid)
            return
        }
        
        guard let tMan = self.timelineMan else {
            TFLogger.log(logString: "The timelineManager was not yet configured...")
            
            return
        }
        
        let photo_point = tMan.getPointForDate(date: photo_date)
        
        let new_photo_cell = PAPhotographCell(frame: CGRect(), info: new_photo)
        new_photo_cell.delegate = self
        
        DispatchQueue.main.async {
            
            self.mainScrollView.addSubview(new_photo_cell)
            new_photo_cell.center = photo_point
            self.photographCellViews.append(new_photo_cell)
        }
    }
    
    private func addPhotographCells() {
        
            if let tMan = self.timelineMan {
                
                for photoInfo in self.repoInfo.photographs {
                    
                    if let photoDate = photoInfo.dateTaken {
                        
                        let photoPoint = tMan.getPointForDate(date: photoDate)
                        
                        let newPhotoCell = PAPhotographCell(frame: CGRect(), info: photoInfo)
                        newPhotoCell.delegate = self
                        self.mainScrollView.addSubview(newPhotoCell)
                        newPhotoCell.center = photoPoint
                        
                        self.photographCellViews.append(newPhotoCell)
                    }
                }
            }
    }
    
    @objc func didLongPress( sender : UILongPressGestureRecognizer ) {
        self.delegate?.PATimelineViewLongPress()
    }
    
    func getYearVal( counter : Int, startYear : Int ) -> Int {
        
        return startYear + (counter / 12)
    }
}
extension PATimelineView : UIScrollViewDelegate {
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //  Calculate the view window
        
        let viewWindowYPos = scrollView.frame.origin.y + scrollView.contentOffset.y
        let viewWindowXPos = scrollView.frame.origin.x
        let viewWindowHeight = scrollView.frame.height
        let viewWindowWidth = scrollView.frame.width
        
        let viewWindow = CGRect(x: viewWindowXPos, y: viewWindowYPos, width: viewWindowWidth, height: viewWindowHeight)
        
        let viewWindowString = NSStringFromCGRect(viewWindow)
        
        // print("View window -> \(viewWindowString)")
    }
    
    
    
}

//  MARK: Action Handlers

//  The protocol methods in this extension are used to respond to
//  actions on the individual photograph cells
extension PATimelineView : PAPhotographCellDelegate {
    
    func PAPhotographCellWasTapped(sender: PAPhotographCell) {
        
        self.delegate?.PATimelineViewPhotographWasTapped(info: sender.photographInfo!)
    }
    
}



extension PATimelineView : PARepositoryDelegate {
    
    func PARepositoryDidAddPhotographToRepository(new_photograph: PAPhotograph) {
        
        let time_logged = PADateManager.sharedInstance.getDateString(date: Date(), formatType: .TimeOnly)
        
        TFLogger.log(logString: "Logging photograph -> %@ at time %@", arguments: new_photograph.PADescription, time_logged)
        
        self.addNewPhotograph(new_photo: new_photograph)
        
        
    }
}
//  MARK: Configuration Stuff

struct PATimelineInformation {
    let TimelineLogicalStart : CGFloat!
    let TimelineLogicalEnd : CGFloat!
    let TimelineLeftMargin : CGFloat!
    let TimelineVerticalOutreach : CGFloat!
    let TimelineVerticalInset : CGFloat!
    let TimelineContentWidth : CGFloat!
    let TimelineLineWidth : CGFloat!
    
    var TimelineLogicalLength : CGFloat {
        get {
            return (TimelineLogicalEnd - TimelineLogicalStart)
        }
    }
    
    var TimelineLength : CGFloat {
        get {
            return (TimelineLogicalLength + (TimelineVerticalOutreach * 2))
        }
    }
    
    var TimelineStart : CGFloat {
        get {
            return (TimelineLogicalStart - TimelineVerticalOutreach)
        }
    }
    
    var TimelineEnd : CGFloat {
        get {
            return (TimelineLogicalEnd + TimelineVerticalOutreach)
        }
    }
    
    var ContentViewHeight : CGFloat {
        get {
            return (TimelineLogicalLength + (TimelineVerticalInset * 2))
        }
    }
}
struct PASpringAnimationInformation {
    var Duration : TimeInterval = 0.9
    var Delay : TimeInterval = 0.1
    var SpringDamping : CGFloat = 20.0
    var SpringVeloctiy : CGFloat = 0.9
    var DelayBetweenAnimations : TimeInterval = 0.03
}
