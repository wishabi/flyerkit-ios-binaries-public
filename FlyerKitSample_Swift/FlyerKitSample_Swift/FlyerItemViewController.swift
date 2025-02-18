import Foundation

class FlyerItemViewController : UIViewController, UITableViewDataSource, UITableViewDelegate  {
  
  // MARK: Properties
  var flyerItem: FlyerItem?
  
  
  // MARK: Outlets
  @IBOutlet weak var couponTableView: UITableView!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  
  // MARK: Lifecycle
  convenience init() {
    self.init(nibName: nil, bundle: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    self.couponTableView.register(
      UINib(nibName: "CouponClippingCell", bundle: nil),
      forCellReuseIdentifier: "couponCell"
    )
    self.couponTableView.dataSource = self
    self.couponTableView.delegate = self
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.couponTableView.reloadData()
  }
  
  public func setFlyerItem(_ flyerItemId: Int) {
    flippApiManager.fetchFlyerItem(flyerItemId: flyerItemId) { flyerItem in
      self.flyerItem = flyerItem
      self.updateSubviews()
    }
  }
  
  fileprivate func updateSubviews() {
    self.fetchImage()
    self.titleLabel.text = self.flyerItem?.name ?? ""
    self.descriptionLabel.text = self.flyerItem?.desc ?? ""
    self.priceLabel.text = self.flyerItem?.price ?? ""
    self.couponTableView.reloadData()
  }
  
  // MARK: Table datasource
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.flyerItem?.coupons.count ?? 0
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: "couponCell",
      for: indexPath
      ) as! CouponClippingCell
    
    
    let coupon = (self.flyerItem?.coupons[indexPath.row])!
    cell.setCoupon(coupon)
    cell.clipButton.tag = indexPath.row
    cell.clipButton.addTarget(self, action: #selector(self.couponClipButtonTapped), for: .touchUpInside)
    
    return cell
  }
  
  // MARK: Table delegate
  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 70
  }
  
  // MARK: Action handlers
  public func couponClipButtonTapped(_ sender: AnyObject?) {
    guard
      let btn = sender as? UIButton,
      let coupon = self.flyerItem?.coupons[btn.tag] else {
        return
    }
    
    if (!loyaltyCardManager.isClipped(coupon)) {
      loyaltyCardManager.clipCoupon(coupon)
    }
    
    updateSubviews()
  }
  
  
  // MARK: Helpers
  func fetchImage() {
    FlippApiManager.fetchImage(flyerItem!.imageUrl) { image in
      self.imageView.image = image
    }
  }
  
}
