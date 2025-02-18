import Foundation
import MediaPlayer

class VideoViewController: UIViewController {
  
  // Mark: Properties
  let scrollView = UIScrollView()
  let videoView = UIWebView()
  var moviePlayer:MPMoviePlayerController!
  
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
    
    title = "Video Details"
    edgesForExtendedLayout = []
    view.backgroundColor = UIColor.white
    
    // Get video item details from flyertown
    let urlString = "\(ROOT_URL)flyerkit/\(API_VERSION)/product/\(flyerItemId)?access_token=\(ACCESS_TOKEN)"
    print("Flyer Item Video URL: " + urlString)
    guard let url = URL(string: urlString) else { return }
    urlSession.dataTask(with: url, completionHandler: { data, response, error in
      guard
        let data = data,
        let flyerItem = (try? JSONSerialization.jsonObject(with: data, options: [])) as? NSDictionary
        else { return }
      
      self.setVideoView(flyerItem)
    }) .resume()
  }
  
  // MARK: Other Methods
  
  // Create the view for a video item (display_type = 3)
  func setVideoView(_ flyerItem: NSDictionary) {
    if let videoUrl = flyerItem["video_url"] as? String,
      let videoType = flyerItem["video_type"] as? Int {
      // handle case where the video url is a youtube embedded url or a plain mp4 url.
      // video type is 0 when url is a youtube embedded url and 1 when it is an mp4 url
      if (videoType == 0) {
        // add webview with iframe set to the embedded youtube url
        scrollView.addSubview(videoView)
        videoView.contentMode = UIViewContentMode.scaleAspectFit
        videoView.frame = view.frame
        let html = "<html><body><iframe src=\""+videoUrl+"\"></iframe></body></html>"
        videoView.loadHTMLString(html, baseURL: Bundle.main.resourceURL)
      } else {
        // add a movie player and play the raw mp4 file
        guard let url = URL(string: videoUrl) else { return }
        moviePlayer = MPMoviePlayerController(contentURL: url)
        moviePlayer.view.frame = CGRect(x: 0, y: 0, width: 200, height: 150)
        scrollView.addSubview(moviePlayer.view)
        moviePlayer.isFullscreen = true
        moviePlayer.play()
      }
    }
  }
}
