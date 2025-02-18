import Foundation

enum FlyerItemType: Int {
  case video = 3
  case link = 5
  case anchor = 7
  case iframe = 15
  case coupon = 25
}

class FlyerItem {
  let id: Int
  let name: String
  let desc: String
  let price: String
  let saleStory: String
  let validFrom: String?
  let validTo: String?
  let imageUrl: String
  let coupons: [Coupon]
  
  init(id: Int, name: String, desc: String, price: String, saleStory: String,
       validFrom: String?, validTo: String?, imageUrl: String, coupons: [Coupon]) {
    self.id = id
    self.name = name
    self.desc = desc
    self.price = price
    self.saleStory = saleStory
    self.validTo = validTo
    self.validFrom = validFrom
    self.imageUrl = imageUrl
    self.coupons = coupons
  }
}
