import Foundation

class CouponClippingCell : UITableViewCell {
  let darkGreen = UIColor(red: 0, green: 0.49, blue: 0.05, alpha: 1)
  
  // MARK: Properties
  private var coupon: Coupon?
  
  // MARK: Outlets
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var clipButton: UIButton!
  @IBOutlet weak var couponImageView: UIImageView!
  
  // MARK: Lifecycle
  open func setCoupon(_ coupon: Coupon) {
    self.coupon = coupon
    self.titleLabel.text = coupon.title
    self.descriptionLabel.text = coupon.promoText
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    guard let coupon = self.coupon else {
      return
    }
    
    
    if loyaltyCardManager.isClipped(coupon) {
      clipButton.backgroundColor = UIColor.darkGray
      clipButton.setTitle("Clipped", for: .normal)
    } else {
      clipButton.backgroundColor = darkGreen
      clipButton.setTitle("Clip", for: .normal)
    }
    fetchImage()
  }
  
  
  // MARK: Helpers
  private func fetchImage() {
    guard let coupon = self.coupon else { return }
    FlippApiManager.fetchImage(coupon.imageUrl) { image in
      self.couponImageView.image = image
    }
  }
  
}
