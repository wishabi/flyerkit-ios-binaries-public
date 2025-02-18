import Foundation
class IframeViewController: UIViewController {
  
  // Mark: Properties
  let scrollView = UIScrollView()
  let webView = UIWebView()
  var flyerItemId: Int = -1
  
  // MARK: Init and View Lifecycle Methods
  
  override func loadView() {
    super.loadView()
    
    view = UIView()
    view.addSubview(scrollView)
    
    // constraints
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|",
                                                       options: [], metrics: nil, views: ["scrollView": scrollView]))
    view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|",
                                                       options: [], metrics: nil, views: ["scrollView": scrollView]))
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Iframe Details"
    edgesForExtendedLayout = []
    view.backgroundColor = UIColor.white
    webView.backgroundColor = UIColor.blue
    
    // Get DCv2 item details from flyertown
    let urlString = "\(ROOT_URL)flyerkit/\(API_VERSION)/product/\(flyerItemId)?access_token=\(ACCESS_TOKEN)"
    print("Flyer Item Iframe URL: " + urlString)
    guard let url = URL(string: urlString) else { return }
    urlSession.dataTask(with: url, completionHandler: {
      data, response, error in
      guard let data = data,
        let flyerItem = try? JSONSerialization.jsonObject(with: data, options: [])
        else { return }
      self.setIframeView(flyerItem as AnyObject)
    }) .resume()
  }
  
  // MARK: Other Methods
  
  // Create the view for a iframe item (display_type = 15)
  func setIframeView(_ flyerItem: AnyObject) {
    if let iframeUrl = flyerItem["web_url"] as? String {
      // add webview with iframe set to item url
      let url = iframeUrl + "?postal_code=" + POSTAL_CODE +
        "&locale=" + LOCALE + "&merchant_id=" + MERCHANT_ID
      print("Iframe URL: " + url)
      scrollView.addSubview(webView)
      webView.frame = scrollView.frame
      webView.loadRequest(URLRequest(url: URL(string: iframeUrl)!))
    }
  }
}
