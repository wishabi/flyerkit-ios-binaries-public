import Foundation

// MARK: Global Variables

// Postal/ZIP code given by user (L1B9C3, 90210)
var POSTAL_CODE = "10011"

class PostalCodeViewController: UIViewController, UITextFieldDelegate {
  // MARK: Properties
  let postalCodeInput = UITextField()
  let defaultFlyerButton = UIButton()
  
  // MARK: Init and View Lifecycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Find flyers"
    self.tabBarItem = UITabBarItem(title: title, image: UIImage(named: "ic_search"), tag: 0)
    edgesForExtendedLayout = []
    view.backgroundColor = UIColor.white
    
    // add postal input field
    view.addSubview(postalCodeInput)
    postalCodeInput.placeholder = "Enter Zip/Postal Code"
    postalCodeInput.font = UIFont.systemFont(ofSize: 15)
    postalCodeInput.borderStyle = UITextBorderStyle.roundedRect
    postalCodeInput.autocorrectionType = UITextAutocorrectionType.no
    postalCodeInput.keyboardType = UIKeyboardType.default
    postalCodeInput.returnKeyType = UIReturnKeyType.done
    postalCodeInput.clearButtonMode = UITextFieldViewMode.whileEditing;
    postalCodeInput.delegate = self
    
    // add postal input constraints
    postalCodeInput.translatesAutoresizingMaskIntoConstraints = false
    postalCodeInput.addConstraint(NSLayoutConstraint(
      item: postalCodeInput, attribute: NSLayoutAttribute.width,
      relatedBy: NSLayoutRelation.equal, toItem: nil,
      attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 170))
    self.view.addConstraint(NSLayoutConstraint(item: postalCodeInput,
                                               attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal,
                                               toItem: self.view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 10))
    self.view.addConstraint(NSLayoutConstraint(
      item: postalCodeInput, attribute: .centerX, relatedBy: .equal,
      toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
    
    // add default flyer button
    view.addSubview(defaultFlyerButton)
    defaultFlyerButton.setTitle("Default Flyer", for: UIControlState())
    defaultFlyerButton.backgroundColor = UIColor.black
    defaultFlyerButton.addTarget(
      self, action: #selector(defaultFlyerButtonAction), for: .touchUpInside)
    
    // add default flyer button constraints
    defaultFlyerButton.translatesAutoresizingMaskIntoConstraints = false
    defaultFlyerButton.addConstraint(NSLayoutConstraint(
      item: defaultFlyerButton, attribute: NSLayoutAttribute.width,
      relatedBy: NSLayoutRelation.equal, toItem: nil,
      attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 150))
    self.view.addConstraint(NSLayoutConstraint(
      item: defaultFlyerButton, attribute: NSLayoutAttribute.top,
      relatedBy: NSLayoutRelation.equal, toItem: postalCodeInput,
      attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 50))
    self.view.addConstraint(NSLayoutConstraint(
      item: defaultFlyerButton, attribute: .centerX, relatedBy: .equal,
      toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
    
    
  }
  
  // MARK: TextField Delegates
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    POSTAL_CODE = textField.text!
    textField.resignFirstResponder()
    let storeViewController = StoreSelectorViewController()
    navigationController?.pushViewController(storeViewController, animated: true)
    return true
  }
  
  // MARK: Other Methods
  
  func defaultFlyerButtonAction () {
    let flyerViewController = FlyerViewController(flyerId: DEFAULT_FLYER_ID, postalCode: POSTAL_CODE)
    navigationController?.pushViewController(flyerViewController, animated: true)
  }
}
