import Foundation
class StoreSelectorViewController: UITableViewController {
  
  // MARK: Properties
  fileprivate var stores: [AnyObject] = []
  
  // MARK: Init and View Lifecycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Get store selector details from flyertown
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    let urlString = "\(ROOT_URL)flyerkit/\(API_VERSION)/stores/\(MERCHANT_IDENTIFIER)?access_token=\(ACCESS_TOKEN)&postal_code=\(POSTAL_CODE)"
    print("Store Select URL: " + urlString)
    guard let url = URL(string: urlString) else { return }
    urlSession.dataTask(with: url, completionHandler: {
      data, response, error in
      guard let data = data,
        let array = try? JSONSerialization.jsonObject(with: data, options: [])
        else { return }
      
      self.stores = array as! [AnyObject]
      self.tableView.reloadData()
    }) .resume()
  }
  
  // MARK: Table View Methods
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return stores.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")!
    let store = stores[(indexPath as NSIndexPath).row]
    
    cell.textLabel?.text = store["name"] as? String
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let store = stores[(indexPath as NSIndexPath).row]
    guard let
      storeCode = store["merchant_store_code"] as? String
      else { return }
    STORE_CODE = storeCode
    let flyerListingController = FlyerListViewController()
    navigationController?.pushViewController(flyerListingController, animated: true)
  }
}
