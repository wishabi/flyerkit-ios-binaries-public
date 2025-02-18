import Foundation

let couponBadgeSize : CGFloat = 200.0

class ItemAnnotation: NSObject, WFKFlyerViewBadgeAnnotation, WFKFlyerViewTapAnnotation {
  var frame = CGRect.zero
  var flyerItem: AnyObject? = nil
  var image: UIImage? = nil
}

class FlyerViewController: UIViewController, WFKFlyerViewDelegate {
  // MARK: Properties
  fileprivate var flyerItems: [AnyObject] = []
  fileprivate var flyerPages: [AnyObject] = []
  fileprivate let flyerView = WFKFlyerView()
  fileprivate let discountSlider = UISlider()
  fileprivate var clippings = NSMutableSet()
  fileprivate var flyerId: Int?
  fileprivate var clippedCouponIds: [Int]?
  
  // MARK: Init and View Lifecycle Methods
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  init(flyerId: Int, postalCode: String) {
    super.init(nibName: nil, bundle: nil)
    self.flyerId = flyerId
    loadClippedCoupons {
      self.loadFlyer()
    }
  }
  
  private func loadClippedCoupons(completion: (()->Void)?) {
    flippApiManager.fetchClippedCoupons { (coupons: [Coupon]) in
      self.clippedCouponIds = (coupons + loyaltyCardManager.getClippedCoupons()).map({ (coupon: Coupon) in
        return coupon.id
      })
      
      if let completion = completion {
        completion()
      }
    }
  }
  
  private func loadFlyer() {
    guard let flyerId = flyerId else {
      return
    }
    
    flyerView.setFlyerId(flyerId, usingRootUrl: ROOT_URL, usingVersion: API_VERSION, usingAccessToken: ACCESS_TOKEN)
    
    // Get the flyer item information for the flyer
    // Note: you must add the display types that you support to the API call
    let itemsUrl = "\(ROOT_URL)flyerkit/\(API_VERSION)/publication/\(flyerId)/products?access_token=\(ACCESS_TOKEN)&display_type=1,5,3,25,7,15&postal_code=\(POSTAL_CODE)"
    print("Flyer Items URL: " + itemsUrl)
    guard let itemsNSURL = URL(string: itemsUrl) else { return }
    
    urlSession.dataTask(with: itemsNSURL, completionHandler: {
      data, response, error in
      
      if (response as! HTTPURLResponse).statusCode != 200 {
        return
      }
      
      guard let data = data else { return }
      
      self.flyerItems =
        try! JSONSerialization.jsonObject(with: data, options: []) as! [AnyObject]
      
      self.flyerView.tapAnnotations = self.flyerItems.map { item in
        let left = CGFloat((item["left"] as? NSNumber)?.doubleValue ?? 0)
        let top = CGFloat((item["top"] as? NSNumber)?.doubleValue ?? 0)
        let width = CGFloat((item["width"] as? NSNumber)?.doubleValue ?? 0)
        let height = CGFloat((item["height"] as? NSNumber)?.doubleValue ?? 0)
        let rect = CGRect(x: left, y: top, width: width, height: height)
        let annotation = ItemAnnotation()
        annotation.frame = rect
        annotation.flyerItem = item
        annotation.image = UIImage(named: "badge")
        return annotation
      }
      
      self.updateBadages()
    }) .resume()
    
    // Get the page information for the flyer
    let pagesUrl = "\(ROOT_URL)flyerkit/\(API_VERSION)/publication/\(flyerId)/pages?access_token=\(ACCESS_TOKEN)&postal_code=\(POSTAL_CODE)"
    print("Flyer Pages URL: " + pagesUrl)
    guard let pagesNSURL = URL(string: pagesUrl) else { return }
    
    urlSession.dataTask(with: pagesNSURL, completionHandler: {
      data, response, error in
      
      if (response as! HTTPURLResponse).statusCode != 200 {
        return
      }
      
      guard let data = data else { return }
      
      self.flyerPages =
        try! JSONSerialization.jsonObject(with: data, options: []) as! [AnyObject]
    }) .resume()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Flyer"
    edgesForExtendedLayout = []
    
    clippings = NSMutableSet()
    
    flyerView.translatesAutoresizingMaskIntoConstraints = false
    flyerView.delegate = self
    view.addSubview(flyerView)
    
    let toolbar = UIToolbar()
    toolbar.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(toolbar)
    
    discountSlider.minimumValue = 0
    discountSlider.maximumValue = 100
    discountSlider.translatesAutoresizingMaskIntoConstraints = false
    discountSlider.addTarget(self, action: #selector(FlyerViewController.discountChanged),
                             for: UIControlEvents.valueChanged)
    toolbar.addSubview(discountSlider)
    
    view.addConstraints(
      NSLayoutConstraint.constraints(withVisualFormat: "V:|[flyerView][toolbar(==44)]|",
                                     options: [NSLayoutFormatOptions.alignAllLeading, NSLayoutFormatOptions.alignAllTrailing],
                                     metrics: nil, views: ["flyerView": flyerView, "toolbar": toolbar]))
    view.addConstraints(
      NSLayoutConstraint.constraints(withVisualFormat: "|[flyerView]|",
                                     options: [], metrics: nil, views: ["flyerView": flyerView]))
    view.addConstraints(
      NSLayoutConstraint.constraints(withVisualFormat: "|-[slider]-|",
                                     options: [], metrics: nil, views: ["slider": discountSlider]))
    view.addConstraints(
      NSLayoutConstraint.constraints(withVisualFormat: "V:|[slider]|",
                                     options: [], metrics: nil, views: ["slider": discountSlider]))
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    discountSlider.value = 0
    flyerView.highlightAnnotations = nil
    self.loadClippedCoupons {
      self.updateBadages()
    }
  }
  
  // MARK: Flyer View Events
  
  func flyerViewDidScroll(_ flyerView: WFKFlyerView) {
    NSLog("FlyerView scrolled %@", NSStringFromCGRect(flyerView.visibleContent()))
    let scale = self.flyerView.visibleContent().height / self.flyerView.contentSize().height
    print("scale: \(scale)")
    updateBadages()
  }
  
  func flyerViewWillBeginLoading(_ flyerView: WFKFlyerView) {
    NSLog("FlyerView will begin loading")
  }
  
  func flyerViewDidFinishLoading(_ flyerView: WFKFlyerView) {
    NSLog("FlyerView did finish loading")
  }
  
  func flyerViewDidFailLoading(_ flyerView: WFKFlyerView, withError error: Error?) {
    NSLog("FlyerView failed loading: %@", (error as NSError?)?.description ?? "")
  }
  
  // MARK: Touch Event Handlers
  
  // Single tap event handler
  func flyerView(_ flyerView: WFKFlyerView, gotSingleTap annotation: WFKFlyerViewTapAnnotation?,
                 at point: CGPoint) {
    NSLog("FlyerView single tapped %@ at %@", annotation?.description ?? "",
          NSStringFromCGPoint(point))
    
    guard let flyerItem = (annotation as? ItemAnnotation)?.flyerItem else { return }
    
    // switch based on item display type
    guard let itemDisplayType = flyerItem["item_type"] as? Int else { return }
    
    switch itemDisplayType {
    // video
    case FlyerItemType.video.rawValue:
      guard let flyerItemId = flyerItem["id"] as? Int else { return }
      openVideoItemView(flyerItemId)
    // external link
    case FlyerItemType.link.rawValue:
      let itemUrl = flyerItem["web_url"] as! String
      UIApplication.shared.openURL(URL(string:itemUrl)!)
    // page anchor
    case FlyerItemType.anchor.rawValue:
      let itemAnchorPageNumber = flyerItem["page_destination"] as! Int
      let itemAnchorPage = self.flyerPages[itemAnchorPageNumber - 1]
      let left = itemAnchorPage["left"] as! CGFloat
      let top = itemAnchorPage["top"] as! CGFloat
      let width = itemAnchorPage["width"] as! CGFloat
      let height = itemAnchorPage["height"] as! CGFloat
      let rect = CGRect(x: left, y: top, width: width, height: height)
      flyerView.zoom(to: rect, animated: true)
    // Iframe
    case FlyerItemType.iframe.rawValue:
      guard let flyerItemId = flyerItem["id"] as? Int else { return }
      openIframeItemView(flyerItemId)
    // coupon
    case FlyerItemType.coupon.rawValue:
      guard let flyerItemId = flyerItem["id"] as? Int else { return }
      openCouponItemView(flyerItemId)
    default:
      guard let flyerItemId = flyerItem["id"] as? Int else { return }
      openFlyerItemView(flyerItemId)
    }
  }
  
  // Double Tap event handler
  func flyerView(_ flyerView: WFKFlyerView, gotDoubleTap annotation: WFKFlyerViewTapAnnotation?,
                 at point: CGPoint) {
    NSLog("FlyerView double tapped %@ at %@", annotation?.description ?? "",
          NSStringFromCGPoint(point))
    let visibleContent = flyerView.visibleContent()
    
    // zoom flyer in or out
    if (fabs(visibleContent.size.height - flyerView.contentSize().height) > 0.001) {
      let zoomScale = flyerView.frame.size.height / flyerView.contentSize().height
      let zoomSize = CGSize(width: flyerView.frame.size.width / zoomScale,
                            height: flyerView.contentSize().height)
      let rect = CGRect(
        x: visibleContent.origin.x + visibleContent.size.width / 2.0 - zoomSize.width / 2.0,
        y: visibleContent.origin.y + visibleContent.size.height / 2.0 - zoomSize.height / 2.0,
        width: zoomSize.width, height: zoomSize.height)
      flyerView.zoom(to: rect, animated: true)
    } else {
      let zoomSize = CGSize(width: 700, height: 700)
      let rect = CGRect(x: point.x - zoomSize.width / 2.0, y: point.y - zoomSize.height / 2.0,
                        width: zoomSize.width, height: zoomSize.height)
      flyerView.zoom(to: rect, animated: true)
    }
  }
  
  // Long press event handler
  func flyerView(_ flyerView: WFKFlyerView, gotLongPress annotation: WFKFlyerViewTapAnnotation?,
                 at point: CGPoint) {
    NSLog("FlyerView long pressed %@ at %@", annotation?.description ?? "",
          NSStringFromCGPoint(point))
    guard let itemAnnotation = annotation as? ItemAnnotation,
      let flyerItem = itemAnnotation.flyerItem else {return}
    
    // circle item
    if clippings.contains(flyerItem) {
      clippings.remove(flyerItem)
    } else {
      clippings.add(flyerItem)
    }
    updateBadages()
  }
  
  // MARK: Navigation
  
  // Opens the flyer item view (display_type = 1)
  func openFlyerItemView(_ flyerItemId: Int) {
    let flyerItemController = FlyerItemViewController()
    flyerItemController.setFlyerItem(flyerItemId)
    navigationController?.pushViewController(flyerItemController, animated: true)
  }
  
  // Opens the coupon item view (display_type = 25)
  func openCouponItemView(_ flyerItemId: Int) {
    let couponController = CouponViewController()
    couponController.loadCouponWithFlyerItemId(flyerItemId)
    navigationController?.pushViewController(couponController, animated: true)
  }
  
  // Opens the video item view (display_type = 3)
  func openVideoItemView(_ flyerItemId: Int) {
    let videoController = VideoViewController()
    videoController.flyerItemId = flyerItemId
    navigationController?.pushViewController(videoController, animated: true)
  }
  
  // Opens the iframe item view (display_type = 15)
  func openIframeItemView(_ flyerItemId: Int) {
    let iframeController = IframeViewController()
    iframeController.flyerItemId = flyerItemId
    navigationController?.pushViewController(iframeController, animated: true)
  }
  
  // MARK: Other Methods
  
  // update the flyer view based on changes from the discount slider
  func discountChanged(_ slider: UISlider) {
    flyerView.highlightAnnotations = flyerItems.filter { item -> Bool in
      guard let percentOff = item["percent_off"] as? NSNumber else { return false }
      return slider.value > 0 && percentOff.floatValue > slider.value
      }.map { item in
        let left = CGFloat((item["left"] as? NSNumber)?.doubleValue ?? 0)
        let top = CGFloat((item["top"] as? NSNumber)?.doubleValue ?? 0)
        let width = CGFloat((item["width"] as? NSNumber)?.doubleValue ?? 0)
        let height = CGFloat((item["height"] as? NSNumber)?.doubleValue ?? 0)
        
        let annotation = ItemAnnotation()
        annotation.frame = CGRect(x: left, y: top, width: width, height: height)
        return annotation
    }
  }
  
  fileprivate func updateBadages() {
    self.flyerView.badgeAnnotations = getCircleBadges() + getCouponBadges()
  }
  
  // get the annotations for clipped items
  fileprivate func getCircleBadges() -> [ItemAnnotation] {
    return clippings.map { item in
      let anyItem = item as AnyObject
      let left = anyItem["left"] as? CGFloat ?? 0
      let top = anyItem["top"] as? CGFloat ?? 0
      let width = anyItem["width"] as? CGFloat ?? 0
      let height = anyItem["height"] as? CGFloat ?? 0
      let rect = CGRect(x: left, y: top, width: width, height: height)
      
      let annotation = ItemAnnotation()
      annotation.flyerItem = item as AnyObject?
      annotation.image = UIImage(named:"badge")
      annotation.frame = rect
      
      return annotation
    }
  }
  
  // get badges for items which have coupons
  fileprivate func getCouponBadges() -> [ItemAnnotation] {
    return self.flyerItems.filter { (item: AnyObject) -> Bool in
      if let itemArray : [AnyObject] = item["coupons"] as? [AnyObject] {
        return itemArray.count > 0
      }
      
      return false
      }.map { item in
        
        let anyItem = item as AnyObject
        let left = anyItem["left"] as? CGFloat ?? 0
        let top = anyItem["top"] as? CGFloat ?? 0
        let width = anyItem["width"] as? CGFloat ?? 0
        let coupons = anyItem["coupons"] as? [[String: AnyObject]] ?? [[String: AnyObject]]()
        
        let scale = min(max(self.flyerView.visibleContent().height / self.flyerView.contentSize().height, 0), 1)
        let badgeSize = couponBadgeSize * scale
        
        let rect = CGRect(
          x: left + width - badgeSize,
          y: top,
          width: badgeSize,
          height: badgeSize
        )
        
        let annotation = ItemAnnotation()
        
        annotation.image = UIImage(named:"coupon_badge")
        if let clippedCouponIds = self.clippedCouponIds {
          for coupon in coupons {
            if let couponId = coupon["coupon_id"] as? Int {
              if clippedCouponIds.contains(couponId) {
                annotation.image = UIImage(named:"coupon_badge_clipped")
                break
              }
            }
          }
        }
        
        annotation.flyerItem = item as AnyObject?
          
        annotation.frame = rect
        
        return annotation
    }
  }
}
