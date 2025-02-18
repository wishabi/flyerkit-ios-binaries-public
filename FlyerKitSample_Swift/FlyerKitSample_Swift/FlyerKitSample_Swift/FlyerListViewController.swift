import Foundation
class FlyerListViewController: UITableViewController {
  
  // MARK: Properties
  fileprivate var flyers: [AnyObject] = []
  
  // MARK: Init and View Lifecycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Flyers"
    edgesForExtendedLayout = []
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    
    // get list of flyers from flyertown
    guard let url = URL(string:
      "\(ROOT_URL)flyerkit/\(API_VERSION)/publications/\(MERCHANT_IDENTIFIER)?" +
      "store_code=\(STORE_CODE)&locale=\(LOCALE)&access_token=\(ACCESS_TOKEN)") else {
        return
    }
    print("Flyer Listing URL: " + String(describing: url))
    urlSession.dataTask(with: url, completionHandler: {
      data, response, error in
      guard let json = try? JSONSerialization.jsonObject(with: data!, options: []),
        let array = json as? [AnyObject] else { return }
      
      self.flyers = array
      self.tableView.reloadData()
    }) .resume()
  }
  
  // MARK: Table View Methods
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return flyers.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")!
    let flyer = flyers[(indexPath as NSIndexPath).row]
    
    cell.textLabel?.text = flyer["external_display_name"] as? String
    cell.imageView?.image = nil
    
    // get flyer image
    guard let imageURLString = flyer["thumbnail_image_url"] as? String,
      let imageURL = URL(string: imageURLString) else { return cell }
    urlSession.dataTask(with: imageURL, completionHandler: {
      data, response, error in
      if let data = data, let imageView = cell.imageView {
        imageView.image = UIImage(data: data)
        cell.layoutSubviews()
      }
    }) .resume()
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let flyer = flyers[(indexPath as NSIndexPath).row]
    guard let
      flyerId = flyer["id"] as? Int,
      let postalCode = flyer["postal_code"] as? String
      else { return }
    
    let flyerViewController = FlyerViewController(flyerId: flyerId, postalCode: postalCode)
    navigationController?.pushViewController(flyerViewController, animated: true)
  }
}
