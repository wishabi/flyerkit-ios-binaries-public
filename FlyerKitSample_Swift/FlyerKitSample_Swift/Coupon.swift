import Foundation


class Coupon {
  let title: String
  let promoText: String
  let id: Int
  let imageUrl: String
  
  
  init(title: String, promoText: String, id: Int, imageUrl: String) {
    self.title = title
    self.promoText = promoText
    self.id = id
    self.imageUrl = imageUrl
  }
}
