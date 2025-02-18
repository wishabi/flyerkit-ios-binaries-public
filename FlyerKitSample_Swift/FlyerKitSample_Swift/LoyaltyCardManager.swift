import Foundation

class LoyaltyCardManager {
  
  // MARK: Properties
  private var clippedCoupons = [Coupon]()
  
  // MARK: Lifecycle
  init() {
    flippApiManager.fetchClippedCoupons { coupons in
      self.clippedCoupons += coupons
    }
  }
  
  // MARK: Operations
  open func getClippedCoupons() -> [Coupon] {
    return clippedCoupons
  }
  
  open func clipCoupon(_ coupon: Coupon) {
    if (isClipped(coupon)) {
      return
    }
    
    flippApiManager.clipCoupon(coupon)
    clippedCoupons.append(coupon)
  }
  
  open func isClipped(_ coupon: Coupon) -> Bool{
    return indexOfCoupon(coupon) != nil
  }
  
  open func isClipped(couponId: Int) -> Bool {
    for coupon in clippedCoupons {
      if coupon.id == couponId {
         return true
      }
    }
    
    return false
  }
  
  
  // MARK: Helpers
  private func indexOfCoupon(_ coupon: Coupon) -> Int? {
    return self.clippedCoupons.index(where: { (c: Coupon) -> Bool in
      return c.id == coupon.id
    })
  }
  
  
}
