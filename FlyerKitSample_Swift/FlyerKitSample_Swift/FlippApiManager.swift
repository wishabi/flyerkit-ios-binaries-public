import Foundation


// Store code selected by user
var STORE_CODE = "001"
// Locale of user (en, fr, en-US, en-CA)
let LOCALE = "en-CA"
// Flipp's name identifier of merchant
let MERCHANT_IDENTIFIER = "flippflyerkit"
// Access token provided by Flipp
let ACCESS_TOKEN = ""
// Root URL of API calls
let ROOT_URL = "https://api.flipp.com/"
// API version number (vX.X)
let API_VERSION = "v3.0"
// Default Flyer ID
let DEFAULT_FLYER_ID = 788309
// Flipp's merchant ID
let MERCHANT_ID = "4489"


class FlippApiManager {
  
  // MARK: Config
  let flyerkitBaseUrl = "https://api.flipp.com/flyerkit/v3.0/"
  let accessToken = ""
  let merchantId = "4489"
  
  
  // MARK: Properties
  var urlSession: URLSession
  
  init() {
    self.urlSession = URLSession(
      configuration: URLSessionConfiguration.default,
      delegate: nil,
      delegateQueue: OperationQueue.main
    )
  }
  
  
  // MARK: API Methods
  
  /*
   *  Fetch flyer
   *
   *  GET /publication/<flyer_id>/products?postal_code=<postal_code>
   *  Fetches a list of FlyerItems for a given flyer id and postal code
   *
   */
  func fetchFlyer(_ flyerId: Int, postalCode: String, callback: @escaping (Any) -> Void) {
    guard let url = URL(string: "\(flyerkitBaseUrl)publication/\(flyerId)/products?access_token=\(accessToken)&postal_code=\(postalCode)") else { return }
    self.urlSession.dataTask(with: url) { data, resp, error in
      
      callback(0)
    }
    
  }
  
  /*
   * Fetch flyer item details
   *
   * GET /product/<flyer_item_id>
   * Returns details for a product in the form of a FlyerItem object
   *
   */
  func fetchFlyerItem(flyerItemId: Int, onSuccess: @escaping (FlyerItem) -> Void) {
    let url = buildApiUrlWithString("product/\(flyerItemId)")
  
    print("Flyer item url: \(url.absoluteString)")
    self.urlSession.dataTask(with: url, completionHandler: { data, response, error in
      guard
        let data = data,
        let flyerItemData = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: AnyObject]
        else {
          return
      }
      
      var flyerCoupons = [Coupon]()
      if let coupons = flyerItemData["coupons"] as? [[String:AnyObject]] {
        for couponData in coupons {
          
          let coupon = Coupon(title: couponData["sale_story"] as? String ?? "",
                              promoText: couponData["promotion_text"] as? String ?? "",
                              id: couponData["coupon_id"] as? Int ?? -1,
                              imageUrl: couponData["image"] as? String ?? "")
          
          flyerCoupons.append(coupon)
        }
        
      }
      
      
      let flyerItem = FlyerItem(id: flyerItemData["id"] as? Int ?? -1,
                                name: flyerItemData["name"] as? String ?? "",
                                desc: flyerItemData["description"] as? String ?? "",
                                price: flyerItemData["price_text"] as? String ?? "",
                                saleStory: flyerItemData["sale_story"] as? String ?? "",
                                validFrom: flyerItemData["valid_from"] as? String ?? "",
                                validTo: flyerItemData["valid_to"] as? String ?? "",
                                imageUrl: flyerItemData["image_url"] as? String ?? "",
                                coupons: flyerCoupons)
      
      onSuccess(flyerItem)
    }).resume()
  }
  
  
  /*
   * Clip coupon
   *
   * POST /clip
   * Clips a given coupon to the given loyalty card
   *
   */
  func clipCoupon(_ coupon: Coupon) {
    let url = buildApiUrlWithString("coupons/clip")
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    let body = [
      "external_id": "\(coupon.id)",
      "coupon_id": "\(coupon.id)",
      "loyalty_program_coupon_id": 199183,
      "card_id": "42143530224",
      "loyalty_program_id": 305,
      "merchant_id": merchantId
    ] as [String : Any]
    
    request.httpBody = NSKeyedArchiver.archivedData(withRootObject: body)
    
    urlSession.dataTask(with: request) { data, resp, error in
    }.resume()
  }
  
  
  /*
   * Fetch clipped coupons
   *
   * POST /get_clipped_coupons
   * Returns a list of coupon ids which have been clipped to the given loyalty card
   */
  func fetchClippedCoupons(_ callback: @escaping ([Coupon]) -> Void) {
    let url = buildApiUrlWithString("coupons/get_clipped_coupons")
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    let body = [
      "loyalty_program_id": 305,
      "card_id": "42143530224",
      "merchant_id": MERCHANT_ID
    ] as [String: Any]
    
//    request.httpBody = NSKeyedArchiver.archivedData(withRootObject: body)
    request.httpBody = try? JSONSerialization.data(withJSONObject: body)
    
    urlSession.dataTask(with: request) { (data: Data?, resp: URLResponse?, err: Error?) in
      guard
        let data = data,
        let clippedCouponData = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: [[String: AnyObject]]]
        else {
          return
      }
      
      guard let couponData = clippedCouponData["loyalty_program_coupons"] else { return }
      let coupons = couponData.map({ (data: [String : AnyObject]) -> Coupon in
        let couponId = data["id"] as! Int
        return Coupon(title: "\(couponId)", promoText: "", id: couponId, imageUrl: "http://placehold.it/50x50")
      })
      
      callback(coupons)
      
      }.resume()
  }
  
  // MARK: Helpers
  static func fetchImage(_ url: String, callback: @escaping (UIImage) -> Void) {
    let urlSession = URLSession(
      configuration: URLSessionConfiguration.default,
      delegate: nil,
      delegateQueue: OperationQueue.main
    )
    
    let imageUrl = URL(string: url)!
    urlSession.dataTask(with: imageUrl, completionHandler: { data, response, error in
      if let data = data {
        callback(UIImage(data: data)!)
      }
    }).resume()
  }
  
  fileprivate func buildApiUrlWithString(_ url: String) -> URL {
    return URL(string: "\(flyerkitBaseUrl)\(url)?access_token=\(accessToken)")!
  }
  
}
