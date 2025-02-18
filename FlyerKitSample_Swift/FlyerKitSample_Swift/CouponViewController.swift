import Foundation

class CouponViewController: UIViewController {
  
  // MARK: Outlets
  @IBOutlet weak var couponImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var clipButton: UIButton!
  
  // MARK: Properties
  private var coupon: Coupon?
  
  // MARK: Lifecycle
  func loadCouponWithFlyerItemId(_ id: Int) {
    flippApiManager.fetchFlyerItem(flyerItemId: id) { (item: FlyerItem) in
      self.coupon = Coupon(title: item.name, promoText: item.desc, id: id, imageUrl: item.imageUrl)
      self.layout()
      self.fetchImage()
    }
  }
  
  private func layout() {
    guard let coupon = self.coupon else { return }
    self.titleLabel.text = coupon.title
    self.descriptionLabel.text = coupon.promoText
    
    if loyaltyCardManager.isClipped(coupon) {
      clipButton.setTitle("Clipped", for: .normal)
      clipButton.backgroundColor = UIColor.darkGray
    } else {
      clipButton.setTitle("Clip", for: .normal)
      clipButton.backgroundColor = UIColor.green
    }
  }
  
  // MARK: Action handlers
  @IBAction func clipButtonPressed(_ sender: Any) {
    guard let coupon = self.coupon else { return }
      loyaltyCardManager.clipCoupon(coupon)
    layout()
  }
  
  
  // MARK: Helpers
  private func fetchImage() {
    FlippApiManager.fetchImage(coupon!.imageUrl) { image in
      self.couponImageView.image = image
    }
  }
}
