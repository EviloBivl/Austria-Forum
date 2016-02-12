//
//  DetailViewController.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 10.12.15.
//  Copyright © 2015 Paul Neuhold. All rights reserved.
//

import Foundation
import UIKit
import WebKit

enum ScrollDirection : Int {
    case ScrollDirectionNone = 0
    case ScrollDirectionRight
    case ScrollDirectionLeft
    case ScrollDirectionUp
    case ScrollDirectionDown
    case ScrollDirectionCrazy
}


class DetailViewController: UIViewController, ReachabilityDelegate, UIToolbarDelegate, WKNavigationDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var constraintTopToolBar: NSLayoutConstraint!
    @IBOutlet weak var constraintBottomToolBar: NSLayoutConstraint!
    
    @IBOutlet weak var licenseTag: UIButton!
    
    var scrollDirection : ScrollDirection?
    var lastScrollOffset : CGPoint?
    var loadingView : LoadingScreen?
    var pListWorker : ReadWriteToPList?
    var noInternetView : LoadingScreen?
    let favouriteIconTag = 3
    var webKitView: WKWebView
    
    var toolBarsHidden : Bool = false
    
    var detailItem: SearchResult? {
        didSet {
            self.refreshWebView()
        }
    }
    
   required init?(coder aDecoder: NSCoder) {
        self.webKitView = WKWebView(frame: CGRectZero)
        super.init(coder: aDecoder)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //set up properties and view settings
        self.configureViews()
        
        //init the pListWorker to write to plist files
        self.pListWorker = ReadWriteToPList()

        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {
            notification in
            print("recieved UIApplicationBecomeActive Notification")
            self.setDetailItem()
        })
        
    }
    
    private func pleaseSetupUpThisWebKitForMeDearXCodeAndFuckThisStupidLeakyWebViewShit(){
        
        self.view.insertSubview(webKitView, belowSubview: self.progressBar)
        webKitView.translatesAutoresizingMaskIntoConstraints = false
    
        let topVertical = NSLayoutConstraint(item: webKitView, attribute: .Top, relatedBy: .Equal, toItem: self.topToolBar, attribute: .Bottom, multiplier: 1, constant: 0)
        let bottomVertical = NSLayoutConstraint(item: webKitView, attribute: .Bottom, relatedBy: .Equal, toItem: self.bottomToolBar, attribute: .Top, multiplier: 1, constant: 0)
        let leadingSpace = NSLayoutConstraint(item: webKitView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .LeadingMargin, multiplier: 1, constant: -19)
        let trailingSpace = NSLayoutConstraint(item: webKitView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .TrailingMargin, multiplier: 1, constant: 19)
        
        view.addConstraints([topVertical, bottomVertical,leadingSpace,trailingSpace])
        
        
        self.webKitView.navigationDelegate = self
        self.webKitView.scrollView.delegate = self
       
        webKitView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
        
    }
    
    
    //MARK : WEBKIT NAVIGATION DELEGATE =======
    
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: NSError) {
        var msg : String = ""
        if let url = webView.URL?.URLString {
            msg = error.localizedDescription + url
        } else{
            msg = error.localizedDescription
        }
        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
  
 
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (keyPath == "estimatedProgress") {
            print("progriss : \(webKitView.estimatedProgress)")
            let finishedLoading = webKitView.estimatedProgress == 1
            if finishedLoading {
                self.performSelector("hideProgressBar", withObject: nil, afterDelay: 0.5)
            } else {
                self.progressBar.hidden = false
            }
            progressBar.setProgress(Float(webKitView.estimatedProgress), animated: true)
            
        }
    }
    //===
    //should start LoadWithRequest 
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void){
       
        print("url of webview: \(webView.URL?.absoluteString)")
        print("url of property:\(self.webKitView.URL?.absoluteString)")
    
        print("action of navigation \(navigationAction.navigationType.rawValue)")
        print("request of navigation \(navigationAction.request.URLString)")
        
        
        
        if !navigationAction.request.URLString.containsString("austria-forum.org") && !navigationAction.request.URLString.containsString("embed"){
            UIApplication.sharedApplication().openURL(navigationAction.request.URL!)
            decisionHandler(WKNavigationActionPolicy.Cancel)
        } else {
            if navigationAction.request.URLString.containsString("embed"){
                decisionHandler(WKNavigationActionPolicy.Allow)
            }
            
            else if !navigationAction.request.URLString.containsString("?skin=page"){
                self.webKitView.loadRequest(NSURLRequest(URL: NSURL(string: navigationAction.request.URLString.stringByAppendingString("?skin=page"))!))
                decisionHandler(WKNavigationActionPolicy.Cancel)
            } else {
                decisionHandler(WKNavigationActionPolicy.Allow)
            }
        }
    }

    
    
    
    
    //webViewDidFinishLoad
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation){
        print("did finish navigation")
       // if !isCorrectSkinnedPage(){
      //      self.refreshWebView()
       //     return
       // }
        
        let currentTitle : String? = self.loadCurrentTitleFromHTML()
        SearchHolder.sharedInstance.currentTitle = currentTitle
        SearchHolder.sharedInstance.currentUrl = self.webKitView.URL?.URLString
        let currentCategory : String? = CategoriesListed.GetBeautyCategoryFromUrlString((self.webKitView.URL?.URLString)!)
        SearchHolder.sharedInstance.currentCategory = currentCategory
        
        self.updateFavouriteIcon()
        UserData.sharedInstance.lastVisitedString = SearchHolder.sharedInstance.currentUrl
        
        // we leave getting info from the js as it is - but non the less we start the request if we made a mistake
        // or perhaps the js > request so we are double "safe"
        self.getPageInfoFromUrl(SearchHolder.sharedInstance.currentUrl!.stringByReplacingOccurrencesOfString("?skin=page", withString: ""))
        
        
        self.checkIfScrollViewIsScrollableToToggleToolbars()
        
        
        
    }
    
    
    
    
    //
    
    //==========
    
    
    func setDetailItem(){
        self.detailItem = SearchHolder.sharedInstance.selectedItem
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //Always set the current controller as the delegate to ReachabilityHelper
        ReachabilityHelper.sharedInstance.delegate = self
        
        self.detailItem = SearchHolder.sharedInstance.selectedItem
        self.checkIfScrollViewIsScrollableToToggleToolbars()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //hide navigationBar
        self.navigationController?.navigationBarHidden = true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //resize the loadingscreen frame to the current viewcontroller after layout is defined
        self.loadingView?.frame = self.view.frame
       
        
    }
    
    //MARK: - Custom Functions
    private func configureViews(){
        //webview
        //self.configureWebView()
        //now replaced be set up webkit
        self.pleaseSetupUpThisWebKitForMeDearXCodeAndFuckThisStupidLeakyWebViewShit()

        
        
        
        //toolbars
        //self.topToolBar.clipsToBounds = true
        //self.topToolBar.layer.borderColor = UIColor.blackColor().CGColor
        //self.topToolBar.layer.borderWidth = 1
        //self.topToolBar.layer.masksToBounds = true
        
        //set the toolbar delegate for the top to properly display the hairline
        self.topToolBar.delegate = self
        
        
        //Please Wait ... Screen
        self.loadingView = NSBundle.mainBundle().loadNibNamed("LoadingScreen", owner: self, options: nil)[0] as? LoadingScreen
        
        //hide progressbar if not needed
        self.progressBar.hidden = true
        self.progressBar.progress = 0
        self.progressBar.progressViewStyle = UIProgressViewStyle.Bar
        
        //hide license tag because we don't have information about license for now
        self.licenseTag.hidden = true
        
    }
    
    private func configureWebView(){
        self.webView.delegate = self
        self.webView.scrollView.delegate = self
        self.webView.scrollView.backgroundColor = UIColor.whiteColor()
        self.webView.clipsToBounds = true
        self.webView.scrollView.alwaysBounceHorizontal = false
        self.webView.scrollView.alwaysBounceVertical = false
        
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .Top
    }
    
    // MARK: - IBActions
    @IBAction func loadLicenseButton(sender: UIButton) {
        
        if let license = SearchHolder.sharedInstance.selectedItem?.license{
            if let licenseUrl = LicenseManager.getLinkForLicense(license){
                let url = NSURL(string: licenseUrl)!
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
   
    @IBAction func back(sender: UIBarButtonItem) {
        if self.webKitView.canGoBack{
            self.webKitView.goBack()
        }
    }
    @IBAction func forward(sender: UIBarButtonItem) {
        if self.webKitView.canGoForward {
            self.webKitView.goForward()
        }
    }

    @IBAction func loadRandomArticle(sender: AnyObject) {
        self.showLoadingScreen()
        RequestManager.sharedInstance.getRandomArticle(self, categories: [UserData.sharedInstance.categorySelected!])
    }
    
    @IBAction func loadArticleFromMonthlyPool(sender: AnyObject) {
        if UserData.sharedInstance.checkIfArticleOfTheMonthNeedsReload() {
            self.showLoadingScreen()
            RequestManager.sharedInstance.getArticleFromMonthlyPool(self, month: "notset", year: "notset")
        } else {
            if (ReachabilityHelper.sharedInstance.connection == ReachabilityType.NO_INTERNET){
                self.noInternet()
            } else {
                self.detailItem = UserData.sharedInstance.articleOfTheMonth
            }
        }
    }
    
    @IBAction func saveArticleAsFavourite(sender: AnyObject) {
        var  activeArticle : [String:String] = [:]
        var sr = SearchHolder.sharedInstance.selectedItem
        if let activeArticleInWebView = SearchHolder.sharedInstance.selectedItem, let currentCategory = SearchHolder.sharedInstance.currentCategory {
            activeArticle["title"] = activeArticleInWebView.title
            activeArticle["url"] = activeArticleInWebView.url.stringByReplacingOccurrencesOfString("?skin=page", withString: "")
            activeArticle["category"] = currentCategory
        } else if let activeTitle = SearchHolder.sharedInstance.currentTitle, let activeUrl = self.webKitView.URL?.URLString , let currentCategory = SearchHolder.sharedInstance.currentCategory {
            activeArticle["title"] = activeTitle
            activeArticle["url"] = activeUrl.stringByReplacingOccurrencesOfString("?skin=page", withString: "")
            activeArticle["category"] = currentCategory
        }
        
        if !activeArticle.isEmpty {
            pListWorker?.loadFavourites()
            if pListWorker?.isFavourite(activeArticle) == false {
                pListWorker?.saveFavourite(activeArticle)
            } else {
                pListWorker?.removeFavourite(activeArticle)
            }
            FavouritesHolder.sharedInstance.refresh()
            self.updateFavouriteIcon()
        } else {
            print("No Article Loaded for saving as Favourite")
        }
    }
    
    @IBAction func shareContentButton(sender: UIBarButtonItem) {
        if let currentAfUrl = self.webKitView.URL?.URLString {
            if currentAfUrl != "" {
                let stringUrl = currentAfUrl.stringByReplacingOccurrencesOfString("?skin=page", withString: "")
                let url = NSURL(string: stringUrl)
                let activityVC = UIActivityViewController(activityItems: [url!], applicationActivities: nil)
                
                //support ipads
                if activityVC.respondsToSelector("popoverPresentationController"){
                    activityVC.popoverPresentationController?.barButtonItem = sender
                }
                self.presentViewController(activityVC, animated: true, completion: nil)
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        
        if identifier == "toLocationArticles" {
            let locationAuthorizationSystemSetting = MyLocationManager.sharedInstance.isAllowedBySystem()
            if locationAuthorizationSystemSetting == false{
                self.hintToSettings(inAppSetting: false)
                return false
            }
            if let localAllowence = UserData.sharedInstance.locationDistanceChangeAllowed {
                if !localAllowence{
                    self.hintToSettings(inAppSetting: true)
                    return false
                }
            }
        }
        return true
    }
    
    //MARK: - Custom Functions
    
    
    
    func hintToSettings(inAppSetting inAppSetting: Bool) {
        let alertController : UIAlertController = UIAlertController(title: "Ortungsdienste", message: "Austria-Froum darf zur Zeit nicht auf ihren Standort zugreifen. Sie können dies in den Einstellungen ändern wenn Sie wollen.", preferredStyle: UIAlertControllerStyle.Alert)
        let actionAbort : UIAlertAction = UIAlertAction(title: "Abbruch", style: UIAlertActionStyle.Cancel, handler: {
            cancleAction in
            print("pressed cancle")
            
        })
        let actionToSettings : UIAlertAction = UIAlertAction(title: "Einstellungen", style: UIAlertActionStyle.Default, handler: {
            alertAction  in
            print("go to settings")
            if inAppSetting{
                self.performSegueWithIdentifier("toSettings", sender: self)
            } else {
                let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
                UIApplication.sharedApplication().openURL(settingsUrl!)
                
            }
        })
        alertController.addAction(actionAbort)
        alertController.addAction(actionToSettings)
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    
    
    func showLoadingScreen() {
        
        if let v = self.loadingView {
            print("adding \(v) now")
            
            v.labelMessage.text = "Bitte Warten ..."
            self.view.addSubview(v)
            v.bringSubviewToFront(self.view)
            v.activityIndicator.startAnimating()
            v.viewLoadingHolder.backgroundColor = UIColor(white: 0.4, alpha: 0.9)
            v.viewLoadingHolder.layer.cornerRadius = 5
            v.viewLoadingHolder.layer.masksToBounds = true;
            
            
        } else {
            print("did not add \(self.loadingView?.debugDescription)")
        }
        
    }
    
    
    func updateFavouriteIcon() {
        let toolBarItems = self.bottomToolBar.items!
        for item in toolBarItems {
            if item.tag == self.favouriteIconTag {
                if self.pListWorker!.isFavourite(["url": (self.webKitView.URL?.URLString)!]){
                    item.image = UIImage(named: "Hearts_Filled_50.png")
                } else {
                    item.image = UIImage(named: "Hearts_50.png")
                    
                }
            }
        }
    }
    
    func refreshWebView(){
        //load the new set artivle into the webView
        if var stringUrl = self.detailItem?.url {
            stringUrl = stringUrl.stringByReplacingOccurrencesOfString("?skin=page", withString: "")
            //we don't want to reload the webview if the url didn't change
            if self.webKitView.URL?.URLString.stringByReplacingOccurrencesOfString("?skin=page", withString: "") == stringUrl{
                return
            }
            //the url is not the same anymore rebuild it with the skin and load it
            let url : NSURL? = NSURL(string: stringUrl.stringByAppendingString("?skin=page"))
            print("\(__FUNCTION__) loading \(url?.URLString)")
            self.webKitView.loadRequest(NSURLRequest(URL: url!))
        } else {
            let loadUrl = UserData.sharedInstance.lastVisitedString!.stringByReplacingOccurrencesOfString("?skin=page", withString: "")
            if self.webKitView.URL?.URLString.stringByReplacingOccurrencesOfString("?skin=page", withString: "") == loadUrl {
                return
            }
            let url : NSURL? = NSURL(string: loadUrl.stringByAppendingString("?skin=page"))
            print("\(__FUNCTION__) loading \(url?.URLString)")
            self.webKitView.loadRequest(NSURLRequest(URL: url!))
        }
    }
    
    
    // MARK: - Delegation ReachablityHelper
    
    func noInternet() {
        
        self.noInternetView = NSBundle.mainBundle().loadNibNamed("LoadingScreen", owner: self, options: nil)[0] as? LoadingScreen
        self.noInternetView?.frame = self.view.frame
        self.noInternetView?.frame.origin.y  -= 100
        self.noInternetView?.tag = 99
        self.hideLoadingScreen()
        if let v = self.noInternetView {
            
            v.labelMessage.text = "Bitte überprüfen Sie ihre Internetverbindung."
            self.view.addSubview(v)
            v.bringSubviewToFront(self.view)
            v.activityIndicator.startAnimating()
            v.viewLoadingHolder.backgroundColor = UIColor(white: 0.4, alpha: 0.9)
            v.viewLoadingHolder.layer.cornerRadius = 5
            v.viewLoadingHolder.layer.masksToBounds = true;
            print("added no Internet Notification")
        }
        self.performSelector("hideNoInternetView", withObject: self, afterDelay: 1)
    }
    
    func hideNoInternetView(){
        print("hided no internet notification")
        for v in self.view.subviews {
            if v.tag == 99{
                v.removeFromSuperview()
            }
        }
    }
    
    func InternetBack() {
        hideNoInternetView()
      self.refreshWebView()
    }
}

//MARK: - UIScrollViewDelegate
extension DetailViewController : UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.scrollDirection == .ScrollDirectionUp{
            hideToolBars()
        } else if self.scrollDirection == .ScrollDirectionDown {
            showToolBars()
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView){
        if (self.lastScrollOffset?.y > scrollView.contentOffset.y){
            self.scrollDirection = ScrollDirection.ScrollDirectionDown
            
        }else if (self.lastScrollOffset?.y < scrollView.contentOffset.y) {
            self.scrollDirection = ScrollDirection.ScrollDirectionUp
        }
        self.lastScrollOffset = scrollView.contentOffset;
        
    }
    
    private func hideToolBars(){
        if self.toolBarsHidden {
            //do nothing leave it as it is
        } else {
            //hide it
            self.constraintTopToolBar.constant = -44
            self.constraintBottomToolBar.constant = -44
            UIView.animateWithDuration(0.2, delay: 0, options: .CurveLinear, animations: {
                self.view.layoutIfNeeded()
                }, completion: {
                    completed in
                    self.topToolBar.alpha = 0.0
                    self.toolBarsHidden = true
                    print("far to early")
                    self.checkIfScrollViewIsScrollableToToggleToolbars()
            })
        }
    }
    private func showToolBars(){
        if self.toolBarsHidden{
            //show them
            self.constraintTopToolBar.constant = 0
            self.constraintBottomToolBar.constant = 0
            self.topToolBar.alpha = 1
            UIView.animateWithDuration(0.2, delay: 0, options: .CurveLinear, animations: {
                self.view.layoutIfNeeded()
                }, completion: {
                    completed in
                    self.toolBarsHidden = false
            })
        } else {
            //nothing leave it as it is
        }
    }
    
    private func checkIfScrollViewIsScrollableToToggleToolbars (){
        let isScrollViewScrollable = self.webKitView.scrollView.contentSize.height >= self.view.bounds.height
        if !isScrollViewScrollable {
         //   self.showToolBars()
        }
        
    }
}


//MARK: - NetworkDelegate
extension DetailViewController : NetworkDelegation {
    func onRequestFailed(from: String?){
        self.loadingView?.labelMessage.text = "Ups! Der Austria-Forum Server ist zur Zeit nicht erreichbar"
        self.performSelector("hideLoadingScreen", withObject: nil, afterDelay: 3)
        print("\(__FUNCTION__) loading \(UserData.sharedInstance.lastVisitedString!)")
        self.webKitView.loadRequest(NSURLRequest(URL: NSURL(string: UserData.sharedInstance.lastVisitedString!)!))
    }
    func onRequestSuccess(from: String?){
        
        if let from = from {
            if from == "search.getPageInfo"{
                print("getPageInfo returned successfully");
                //fake the license for now
                //TODO really we need to get rid of it, just for testing
                //SearchHolder.sharedInstance.selectedItem?.license = "CC0"
                
                //update the license tag when we are getting a succes from the server
                self.updateLicenseTag()
                
                return
            }
        }
        
        if let _ = SearchHolder.sharedInstance.selectedItem {
            self.detailItem = SearchHolder.sharedInstance.selectedItem
            self.hideLoadingScreen()
            
        } else {
            self.loadingView?.labelMessage.text = SearchHolder.sharedInstance.resultMessage
            self.performSelector("hideLoadingScreen", withObject: nil, afterDelay: 3)
            print("\(__FUNCTION__) loading \(UserData.sharedInstance.lastVisitedString!)")
            self.webKitView.loadRequest(NSURLRequest(URL: NSURL(string: UserData.sharedInstance.lastVisitedString!)!))
        }
        
        //fake the license for now
        //TODO really we need to get rid of it, just for testing
        //SearchHolder.sharedInstance.selectedItem?.license = "CC0"
        
        //update the license tag when we are getting a succes from the server
        self.updateLicenseTag()
    }
}



//MARK: - WebView Delegate
extension DetailViewController : UIWebViewDelegate {
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool{
        print("webview delegate was called");
        print("requested url is: \(request.URLString)")
        
        //present content which isnt from AF in Safari
        if request.URLString.containsString(BaseRequest.urlAFStatic) == false {
            //if we have a embed youtube video within an iframe dont open in safari
            if request.URLString.containsString("embed"){
                return true
            }
            UIApplication.sharedApplication().openURL(request.URL!)
            return false
        }
        
        
        
        if navigationType == .BackForward {
            SearchHolder.sharedInstance.selectedItem = nil
            SearchHolder.sharedInstance.currentUrl = request.URLString
        } else {
            
            var pageUrl = request.URLString
            if !pageUrl.containsString("?skin=page"){
//                pageUrl = request.URLString.stringByReplacingOccurrencesOfString("#?skin=page", withString: "")
//                pageUrl = request.URLString.stringByReplacingOccurrencesOfString("?skin=page", withString: "")
                SearchHolder.sharedInstance.selectedItem = nil
                SearchHolder.sharedInstance.currentUrl = pageUrl
                pageUrl += "?skin=page"
                let url : NSURL? = NSURL(string: pageUrl)
                self.webView.loadRequest(NSURLRequest(URL: url!))
                return false
            } else if pageUrl.containsString("redirect"){
                let url : NSURL? = NSURL(string: UserData.sharedInstance.lastVisitedString!)
                self.webView.loadRequest(NSURLRequest(URL: url!))
                return false
            }
        }
        
        return true;
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        
        if !isCorrectSkinnedPage(){
            self.refreshWebView()
            return
        }
        let currentTitle : String? = self.loadCurrentTitleFromHTML()
        SearchHolder.sharedInstance.currentTitle = currentTitle
        SearchHolder.sharedInstance.currentUrl = self.webView.request?.URLString
        let currentCategory : String? = CategoriesListed.GetBeautyCategoryFromUrlString((self.webView.request?.URLString)!)
        SearchHolder.sharedInstance.currentCategory = currentCategory
        self.progressBar.setProgress(1, animated: true)
        self.performSelector("hideProgressBar", withObject: nil, afterDelay: 0.5)
        self.updateFavouriteIcon()
        UserData.sharedInstance.lastVisitedString = SearchHolder.sharedInstance.currentUrl
        
        // we leave getting info from the js as it is - but non the less we start the request if we made a mistake
        // or perhaps the js > request so we are double "safe"
        self.getPageInfoFromUrl(SearchHolder.sharedInstance.currentUrl!.stringByReplacingOccurrencesOfString("?skin=page", withString: ""))
        
        
        self.checkIfScrollViewIsScrollableToToggleToolbars()
        
    }
    
    private func isCorrectSkinnedPage() -> Bool{
        if let currentUrl = (self.webKitView.URL?.URLString){
            if currentUrl.containsString("?skin=page"){
                return true
            }
        }
        return false
    }
    
    func updateLicenseTag(){
        if let license = SearchHolder.sharedInstance.selectedItem?.license {
            let licenseImageName = LicenseManager.getImageNameForLicense(license)
            if let name = licenseImageName{
                let image = UIImage(named: name)
                self.licenseTag.setImage(image, forState: .Normal)
                self.licenseTag.hidden = false;
                return
            }
        }
        self.licenseTag.hidden = true
    }
    
    func getPageInfoFromUrl(url: String){
        RequestManager.sharedInstance.getPageInfoFromUrls(self, urls: [url])
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?){
        self.hideProgressBar()
        
        
        print("Der gewünschte Inhalt kann in der App leider nicht wiedergegeben werden")
        
    }
    
    func hideProgressBar() {
        self.progressBar.hidden = true
        self.progressBar.setProgress(0, animated: false)
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        self.progressBar.hidden = false
        self.progressBar.setProgress(0.5, animated: true)
    }
    
    func hideLoadingScreen() {
        self.loadingView?.activityIndicator.stopAnimating()
        self.loadingView?.removeFromSuperview()
    }
    
    
    func loadCurrentTitleFromHTML () -> String? {
        return ""
        let jsCMD =
        //declare a function
        "function getHeaderTitle () { var values = document.getElementsBySelector(\"h1\");" +
            "if (values.length > 0){" +
            "var headerTag = values[0]; " +
            "}" +
            "return headerTag.getText()}" +
            //now call the function and get a return string
        "getHeaderTitle()"
        
        
        let jsCMD2 =
        "function getWebBookInfo () { " +
            "var values = document.getElementsByClassName(\"bread-title\");" +
            "if (values.length == 2){" +
            "return values[1].textContent;" +
            "} else if (values.length == 1){" +
            "return values[0].textContent;" +
            "}" +
            "}" +
        "getWebBookInfo()"
        
        
        
        
        var title : String?
        var titleWebBook : String?
        
        
        self.webKitView.evaluateJavaScript(jsCMD, completionHandler: {
            (result, error) -> Void in
            title = result as? String
        })
        
        self.webKitView.evaluateJavaScript(jsCMD2, completionHandler: {
            (result, error) -> Void in
            titleWebBook = result as? String
        })
        
        if title!.characters.count > 0 {
            print("Returning title : \(title) count of title is \(title!.characters.count)")
            return title
        } else {
            
            print("Returning title : \(titleWebBook)")
            return titleWebBook
        }
    }
    
}



