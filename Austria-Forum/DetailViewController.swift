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
import Crashlytics


enum ScrollDirection : Int {
    case scrollDirectionNone = 0
    case scrollDirectionRight
    case scrollDirectionLeft
    case scrollDirectionUp
    case scrollDirectionDown
    case scrollDirectionCrazy
}


class DetailViewController: UIViewController,  UIToolbarDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var topToolBar: ToolBar!
    @IBOutlet weak var bottomToolBar: ToolBar!
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var constraintTopToolBar: NSLayoutConstraint!
    @IBOutlet weak var constraintBottomToolBar: NSLayoutConstraint!
    
    @IBOutlet weak var licenseTag: UIButton!
    
    @IBAction func homeAction(_ sender: Any) {
        print("home action pressed")
    }
    
    var scrollDirection : ScrollDirection?
    var lastScrollOffset : CGPoint?
    var loadingView : LoadingScreen?
    var pListWorker : ReadWriteToPList?
    var noInternetView : LoadingScreen?
    let favouriteIconTag = 22
    var webKitView: WKWebView
    let toolBarIconSize : CGSize = CGSize(width: 30, height: 30)
    
    var wkNavigatioinCount : Int = 0
    
    let userActionEvent = "User Action"
    let userNavigation = "Navigation"
    
    ///Answer Constants
    public static let answersEventLicense = "License"
    public static let answersEventRandom = "Random Article"
    public static let answersEventMonthly = "Monthly Article"
    public static let answersEventAddFavs = "Add Favourite"
    public static let answersEventFromPush = "Start From Push"
    public static let answersEventLocation = "Location Articles"
    public static let answersEventHome = "Home Navigation"
    public static let answersEventFavs = "Open Favourites"
    public static let answersEventShare = "Share Article"
    public static let answersEventSearch = "Search Articles"
    
    
    
    var toolBarsHidden : Bool = false
    var isLandScape : Bool = false
    
    var detailItem: SearchResult? {
        didSet {
            self.refreshWebView()
        }
    }
    
    
    
    // MARK: - Lifecycle
    required init?(coder aDecoder: NSCoder) {
        self.webKitView = WKWebView(frame: CGRect.zero)
        super.init(coder: aDecoder)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //start it
        self.initScene()
        
     //   fatalError("Currently toolbar is broken. If a link from within the wkwebkit is pressed. the toolbar items wont sent triggered action correctly to registered selector in Toolbar.swift. Quickfix:add ibactions directly from main.storyboard to controller. handle clicks. Better: think about ...")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Always set the current controller as the delegate to ReachabilityHelper
        ReachabilityHelper.sharedInstance.delegate = self
        
        self.setDetailItem()
        
        if UIDevice.current.orientation.isLandscape{
            isLandScape = true
        }
        
        self.trackViewControllerTitleToAnalytics()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //hide navigationBar
        self.navigationController?.isNavigationBarHidden = true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.resizeLoadingScreenSizeAfterSubViewsWereLayout()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    deinit {
        removeObservers()
    }
    
    
    //MARK: UIToolbar - Top Delegate
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .top
    }
    
    //MARK: - Custom Functions
    
    fileprivate func initScene(){
        
        
        //properties configurations
        self.configureProperties()
        //webkit
        self.pleaseSetupUpThisWebKitForMeDearXCodeAndFuckThisStupidLeakyWebViewShit()
        self.registerObserverForAppLaunchingFromLocalNotification()
        self.registerObserverForOrientationChange()
       
        
    }
    
    
    fileprivate func configureProperties(){
        
        //favourite worker
        self.pListWorker = ReadWriteToPList()
        
        //set the toolbar delegate for the top to properly display the hairline
      //  self.topToolBar.delegate = self
        
        //Please Wait ... Screen
        self.loadingView = Bundle.main.loadNibNamed("LoadingScreen", owner: self, options: nil)![0] as? LoadingScreen
        
        //on start up hide progress bar - will be handled by the webkit
        self.progressBar.isHidden = true
        self.progressBar.progress = 0
        self.progressBar.progressViewStyle = UIProgressView.Style.bar
        
        //hide license tag on start up
        self.licenseTag.isHidden = true
        
        //set delegates
        topToolBar.customDelegate = self
        bottomToolBar.customDelegate = self
        
    }
    
    
    fileprivate func registerObserverForAppLaunchingFromLocalNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(DetailViewController.appBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    fileprivate func registerObserverForOrientationChange(){
        NotificationCenter.default.addObserver(self, selector: #selector(DetailViewController.deviceRotated), name: UIDevice.orientationDidChangeNotification, object: nil)

    }
    
    fileprivate func removeObservers(){
        self.webKitView.removeObserver(self, forKeyPath: "URL")
        self.webKitView.removeObserver(self, forKeyPath: "estimatedProgress")
        print("\n\n Removing Observers \n\n")
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc public func deviceRotated(){
        print("Device rotated")
        if(UIDevice.current.orientation.isLandscape)
        {
            if let disableToolbar = UserData.sharedInstance.disableToolbar{
                if disableToolbar {
                    hideToolBars()
                }
            }
            isLandScape = true
        }
        
        if(UIDevice.current.orientation.isPortrait)
        {
            isLandScape = false
            showToolBars()
        }
    }
    
    @objc func appBecomeActive(){
        print("Application Did Become Active Notification - DetailViewController")
        self.setDetailItem()
    }
    
    func setDetailItem(){
        self.detailItem = SearchHolder.sharedInstance.selectedItem
        
    }
    
    
    fileprivate func resizeLoadingScreenSizeAfterSubViewsWereLayout (){
        self.loadingView?.frame = self.view.frame
    }
    
    fileprivate func saveCurrentArticleAsFavourite(webBook: Bool? = false){
        if Helper.saveCurrentArticleAsFavourite(withCurrentUrl: self.webKitView.url, andWithTitle: self.webKitView.title, isWebBook: webBook){
            self.updateFavouriteIcon()
        }
    }
    
    ///This logs the User action to fabric.io but for now we don't use it
    ///Because we instead use the GA API
    fileprivate func logToAnswers(_ message: String, customAttributes: [String : AnyObject]?){
        Answers.logCustomEvent(withName: message, customAttributes: customAttributes)
    }
    
    fileprivate func isRightNowAWebBookLoaded() -> Bool{
        if let currentUrl = webKitView.url?.absoluteString {
            if currentUrl.contains("Web_Books") || currentUrl.contains("web_books") || currentUrl.contains("web-books") {
                return true
            }
        }
        
        return false
    }
    
    
    // MARK: - IBActions
    @IBAction func loadLicenseButton(_ sender: UIButton) {
        
        var answersAttributes : [String: String] = [:]
        
        if let license = SearchHolder.sharedInstance.selectedItem?.licenseResult{
            if let licenseUrl = license.url{
                answersAttributes["License"] = license.id
                let url = URL(string: licenseUrl)!
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        } else if let licenseUrl = LicenseManager.getLinkForLicense("AF"){
            // fallbacl license url
            answersAttributes["License"] = "AF"
            let url = URL(string: licenseUrl)!
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        self.logToAnswers(DetailViewController.answersEventLicense, customAttributes: answersAttributes as [String : AnyObject]?)
        Helper.trackAnalyticsEvent(withCategory: DetailViewController.answersEventLicense, action: answersAttributes["License"]!)
    }
    
    func loadRandomArticle() {
        self.logToAnswers(DetailViewController.answersEventRandom, customAttributes: ["Rnd Article - Category" : UserData.sharedInstance.categorySelected! as AnyObject])
        Helper.trackAnalyticsEvent(withCategory: DetailViewController.answersEventRandom, action: UserData.sharedInstance.categorySelected!)
        self.showLoadingScreen()
        RequestManager.sharedInstance.getRandomArticle(self, categories: [UserData.sharedInstance.categorySelected!])
    }
    
    func loadArticleFromMonthlyPool() {
        self.logToAnswers(DetailViewController.answersEventMonthly, customAttributes: ["Monthly Article" : "requested" as AnyObject])
        
        if UserData.sharedInstance.checkIfArticleOfTheMonthNeedsReload() {
            self.showLoadingScreen()
            RequestManager.sharedInstance.getArticleFromMonthlyPool(self, month: "notset", year: "notset")
            Helper.trackAnalyticsEvent(withCategory: DetailViewController.answersEventMonthly, action: "Load Article From Server")
        } else {
            if (ReachabilityHelper.sharedInstance.connection == ReachabilityType.no_INTERNET){
                self.noInternet()
            } else {
                Helper.trackAnalyticsEvent(withCategory: DetailViewController.answersEventMonthly, action: "Load Article from Storage")
                self.detailItem = UserData.sharedInstance.articleOfTheMonth
            }
        }
    }
    
    func saveArticleAsFavourite() {
        if isRightNowAWebBookLoaded(){
            self.saveCurrentArticleAsFavourite(webBook: true)
        } else {
            self.saveCurrentArticleAsFavourite()
        }
    }
    
    func shareContentButton() {
        if let sr = SearchHolder.sharedInstance.selectedItem {
            Helper.trackAnalyticsEvent(withCategory: DetailViewController.answersEventShare, action: sr.title ?? "got Nil Title", label: sr.url ?? "got Nil Url")
            self.logToAnswers(DetailViewController.answersEventShare, customAttributes: ["Article" : sr.title as AnyObject? ?? "got Nil Title" as AnyObject])
        } else if let currentUrl = self.webKitView.url?.absoluteString {
            Helper.trackAnalyticsEvent(withCategory: DetailViewController.answersEventShare, action: "Webbook" , label: currentUrl )
            self.logToAnswers(DetailViewController.answersEventShare, customAttributes: ["Article" : "Webbook" as AnyObject])
        }
        
        if let currentAfUrl = self.webKitView.url?.absoluteString {
            if currentAfUrl != "" {
                let stringUrl = currentAfUrl.removeAFSkin()
                let url = URL(string: stringUrl)
                let items = [url!]
                let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
                
                //support ipads
                if UIDevice.current.userInterfaceIdiom == .pad {
                    activityVC.popoverPresentationController?.barButtonItem = bottomToolBar.items?.last
                }
                activityVC.completionWithItemsHandler = nil
                self.present(activityVC, animated: true, completion: nil)
            }
        }
    }
    
    func back() {
        if self.webKitView.canGoBack{
            self.webKitView.goBack()
        }
        
        print("back forward list : \(self.webKitView.backForwardList.debugDescription)")
        for bItems in self.webKitView.backForwardList.backList {
            print("url of back item: \(bItems.url.absoluteString)")
        }
    }
    func forward() {
        if self.webKitView.canGoForward {
            self.webKitView.goForward()
        }
        print("back forward list : \(self.webKitView.backForwardList.debugDescription)")
        for bItems in self.webKitView.backForwardList.forwardList {
            print("url of forward item: \(bItems.url.absoluteString)")
        }
    }
    
    func loadHome() {
        if (ReachabilityHelper.sharedInstance.connection == ReachabilityType.no_INTERNET){
            self.noInternet()
            return
        }
        
        SearchHolder.sharedInstance.selectedItem = SearchResult(title: "Austria-Forum", name: "Austria-Forum", url: UserData.AF_URL, score: 100, licenseResult: nil)
        self.logToAnswers(DetailViewController.answersEventHome, customAttributes: nil)
        Helper.trackAnalyticsEvent(withCategory: DetailViewController.answersEventHome, action: "Going Home")
        self.setDetailItem()
    }
    
    
    //MARK: Prepare for Segue - Before Transistion hints
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == "toLocationArticles" {
            self.logToAnswers(DetailViewController.answersEventLocation, customAttributes: nil)
        } else if identifier == "toSearchArticle" {
            self.logToAnswers(DetailViewController.answersEventSearch, customAttributes: nil )
        } else if identifier == "toFavourites"{
            self.logToAnswers(DetailViewController.answersEventFavs, customAttributes: nil )
        }
        print("performing segue \(identifier)")
        
        return true
    }
    
    
    func hintToSettings(inAppSetting: Bool) {
        let alertController : UIAlertController = UIAlertController(title: "Ortungsdienste", message: "Austria-Forum darf zur Zeit nicht auf ihren Standort zugreifen. Sie können dies in den Einstellungen ändern wenn Sie wollen.", preferredStyle: UIAlertController.Style.alert)
        let actionAbort : UIAlertAction = UIAlertAction(title: "Abbruch", style: UIAlertAction.Style.cancel, handler: {
            cancleAction in
            print("pressed cancle")
            
        })
        let actionToSettings : UIAlertAction = UIAlertAction(title: "Einstellungen", style: UIAlertAction.Style.default, handler: {
            alertAction  in
            print("go to settings")
            if inAppSetting{
                self.performSegue(withIdentifier: "toSettings", sender: self)
            } else {
                let settingsUrl = URL(string: UIApplication.openSettingsURLString)
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(settingsUrl!)
                }
                
            }
        })
        alertController.addAction(actionAbort)
        alertController.addAction(actionToSettings)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    
    
    
    
}


//MARK: - Reachability Delegation
extension DetailViewController : ReachabilityDelegate {
    
    func noInternet() {
        
        self.noInternetView = Bundle.main.loadNibNamed("LoadingScreen", owner: self, options: nil)![0] as? LoadingScreen
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
        self.perform(#selector(DetailViewController.hideNoInternetView), with: self, afterDelay: 1)
    }
    
    func InternetBack() {
        if hideNoInternetView(){
            self.refreshWebView()
        }
    }
    
    @objc func hideNoInternetView() -> Bool {
        print("hided no internet notification")
        for v in self.view.subviews {
            if v.tag == 99{
                v.removeFromSuperview()
                return true
            }
        }
        return false
    }
}



//MARK: - UIScrollViewDelegate
extension DetailViewController : UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.scrollDirection == .scrollDirectionUp{
            hideToolBars()
        } else if self.scrollDirection == .scrollDirectionDown {
            if !isLandScape {
                showToolBars()
            } else if let disabledToolbar = UserData.sharedInstance.disableToolbar {
                if !disabledToolbar {
                    showToolBars()
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        
        if let y = self.lastScrollOffset?.y {
            if (y > scrollView.contentOffset.y){
                self.scrollDirection = ScrollDirection.scrollDirectionDown
            }else if (y < scrollView.contentOffset.y) {
                self.scrollDirection = ScrollDirection.scrollDirectionUp
            }
        }
        
        self.lastScrollOffset = scrollView.contentOffset;
    }
    
    fileprivate func hideToolBars(){
        if self.toolBarsHidden {
            //do nothing leave it as it is
        } else {
            //hide it
            self.constraintTopToolBar.constant = -44
            self.constraintBottomToolBar.constant = -44
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                self.view.layoutIfNeeded()
                }, completion: {
                    completed in
                    self.topToolBar.alpha = 0.0
                    self.toolBarsHidden = true
            })
        }
    }
    fileprivate func showToolBars(){
        if self.toolBarsHidden{
            self.constraintTopToolBar.constant = 0
            self.constraintBottomToolBar.constant = 0
            self.topToolBar.alpha = 1
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                self.view.layoutIfNeeded()
                }, completion: {
                    completed in
                    self.toolBarsHidden = false
            })
        } else {
            //nothing leave it as it is
        }
    }
}


//MARK: WKNavigation Delegate - and WebKit Handling
extension DetailViewController : WKNavigationDelegate {
    
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("didFailNavigation")
    }
    
    
    
    
    fileprivate func pleaseSetupUpThisWebKitForMeDearXCodeAndFuckThisStupidLeakyWebViewShit(){
        //add the webview to hirarchy
        self.view.insertSubview(webKitView, belowSubview: self.progressBar)
        
        //so that our constraint work
        webKitView.translatesAutoresizingMaskIntoConstraints = false
        
        //create the constraints
        let topVertical = NSLayoutConstraint(item: webKitView, attribute: .top, relatedBy: .equal, toItem: self.topToolBar, attribute: .bottom, multiplier: 1, constant: 0)
        let bottomVertical = NSLayoutConstraint(item: webKitView, attribute: .bottom, relatedBy: .equal, toItem: self.bottomToolBar, attribute: .top, multiplier: 1, constant: 0)
        let leadingSpace = NSLayoutConstraint(item: webKitView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leadingMargin, multiplier: 1, constant: -19)
        let trailingSpace = NSLayoutConstraint(item: webKitView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailingMargin, multiplier: 1, constant: 19)
        view.addConstraints([topVertical, bottomVertical,leadingSpace,trailingSpace])
        
        
        
        //set the delegates
        self.webKitView.navigationDelegate = self
        self.webKitView.scrollView.delegate = self
        
        //disable overscrolling
        self.webKitView.scrollView.alwaysBounceHorizontal = false
        
        //add observer for managing the progressbar
        webKitView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        //oberserver for updating favourite icon when in webbooks browsing mode
        webKitView.addObserver(self, forKeyPath: "URL", options: NSKeyValueObservingOptions.new, context: nil)
        
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: Error) {
        _ = error.localizedDescription
        print("didFailNavigation")
        /* let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .Alert)
         alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
         if error.code != -999 {
         presentViewController(alert, animated: true, completion: nil)
         }*/
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "estimatedProgress") {
            let finishedLoading = webKitView.estimatedProgress == 1
            if finishedLoading {
                self.perform(#selector(DetailViewController.hideProgressBar), with: nil, afterDelay: 0.5)
            } else {
                self.progressBar.isHidden = false
            }
            progressBar.setProgress(Float(webKitView.estimatedProgress), animated: true)
            
        }
        if (keyPath == "URL") {
            print("URL change")
            if isRightNowAWebBookLoaded(){
                print("updated icons in observer mode")
                self.updateFavouriteIcon()
            }
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void){
        
        print("url of property:\(String(describing: self.webKitView.url?.absoluteString))")
        print("request of navigation \(String(describing: navigationAction.request.url?.absoluteString))")
        
        let urlIsFormatted : Bool = (navigationAction.request.url?.absoluteString.contains("?skin=page"))! ||
                                    (navigationAction.request.url?.absoluteString.contains("&skin=page"))!
        
      
        
        if (!(navigationAction.request.url?.absoluteString.contains("austria-forum.org"))! && !(navigationAction.request.url?.absoluteString.contains("embed"))!) {
            if wkNavigatioinCount > 1 {
                let url = navigationAction.request.url
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url!)
                }
            }
            decisionHandler(WKNavigationActionPolicy.cancel)
        } else {
            if (navigationAction.request.url?.absoluteString.contains("embed"))!{
                decisionHandler(WKNavigationActionPolicy.allow)
            }
            else if !urlIsFormatted{
                let url = navigationAction.request.url?.absoluteString.getSkinnedAFUrl()
                wkNavigatioinCount = 0
                self.webKitView.load(URLRequest(url: URL(string: url!)!))
                decisionHandler(WKNavigationActionPolicy.cancel)
            } else {
                decisionHandler(WKNavigationActionPolicy.allow)
            }
        }
        wkNavigatioinCount = wkNavigatioinCount + 1
    }
    
    
    
    
    
    //webViewDidFinishLoad
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation){
        print("did finish navigation")
        // if !isCorrectSkinnedPage(){
        //      self.refreshWebView()
        //     return
        // }
        
        SearchHolder.sharedInstance.currentUrl = self.webKitView.url?.absoluteString
        let currentCategory : String? = CategoriesListed.GetBeautyCategoryFromUrlString((self.webKitView.url?.absoluteString)!)
        SearchHolder.sharedInstance.currentCategory = currentCategory
        
        self.updateFavouriteIcon()
        UserData.sharedInstance.lastVisitedString = SearchHolder.sharedInstance.currentUrl
        
        self.getPageInfoFromUrl(SearchHolder.sharedInstance.currentUrl!.removeAFSkin())
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
            print("did not add \(String(describing: self.loadingView?.debugDescription))")
        }
        
    }
    
    
    func updateFavouriteIcon() {
        let toolBarItems = self.bottomToolBar.items!
        for item in toolBarItems {
            if item.tag == self.favouriteIconTag {
                if self.pListWorker!.isFavourite(["url": (self.webKitView.url?.absoluteString.removeAFSkin())!]){
                    item.image = self.bottomToolBar.likedImage
                } else {
                    item.image = self.bottomToolBar.notLikedImage
                    
                }
            }
        }
    }
    
    func refreshWebView(){
        //load the new set artivle into the webView
        if var stringUrl = self.detailItem?.url, var selectedUrl = SearchHolder.sharedInstance.currentUrl {
            stringUrl = stringUrl.removeAFSkin()
            selectedUrl = selectedUrl.removeAFSkin()
            //we don't want to reload the webview if the url didn't change
            let webKitUrl = self.webKitView.url?.absoluteString.removeAFSkin()
            if webKitUrl == stringUrl {
                return
            }
            //the url is not the same anymore rebuild it with the skin and load it
            let url : URL? = URL(string: stringUrl.getSkinnedAFUrl())
            print("\(#function) loading \(String(describing: url?.absoluteString))")
            self.webKitView.load(URLRequest(url: url!))
        } else {
            let loadUrl = UserData.sharedInstance.lastVisitedString!.removeAFSkin()
            if self.webKitView.url?.absoluteString.removeAFSkin() == loadUrl {
                return
            }
            let url : URL? = URL(string: loadUrl.getSkinnedAFUrl())
            print("\(#function) loading \(String(describing: url?.absoluteString))")
            self.webKitView.load(URLRequest(url: url!))
        }
    }
    
    fileprivate func isCorrectSkinnedPage() -> Bool{
        if let currentUrl = (self.webKitView.url?.absoluteString){
            if currentUrl.contains("?skin=page"){
                return true
            }
        }
        return false
    }
    
    internal func prepareUrlForloading(url : String) -> String{
        if url.contains("?"){
            return url.appending("&skin=page")
        } else {
            return url.appending("?skin=page")
        }
    }
    
    func updateLicenseTag(){
        if let license = SearchHolder.sharedInstance.selectedItem?.licenseResult {
            let licenseImageName = LicenseManager.getImageNameForLicense(license.css ?? "af")
            if let name = licenseImageName {
                let image = UIImage(named: name)
                self.licenseTag.setImage(image, for: UIControl.State())
                self.licenseTag.isHidden = false
            }
        } else {
            //fallback license
            let licenseImageName = LicenseManager.getImageNameForLicense("af")
            if let name = licenseImageName {
                let image = UIImage(named: name)
                self.licenseTag.setImage(image, for: UIControl.State())
                self.licenseTag.isHidden = false
            }
            
        }
        
    }
    
    func getPageInfoFromUrl(_ url: String){
        RequestManager.sharedInstance.getPageInfoFromUrls(self, urls: [url])
    }
    
    
    @objc func hideProgressBar() {
        self.progressBar.isHidden = true
        self.progressBar.setProgress(0, animated: false)
    }
    
    
    @objc func hideLoadingScreen() {
        self.loadingView?.activityIndicator.stopAnimating()
        self.loadingView?.removeFromSuperview()
    }
    
    //MARK: injecting JS to webview
    func loadTitleViaJS() -> String{
        
        let title = ""
        
        return title
    }
}





//MARK: - NetworkDelegate
extension DetailViewController : NetworkDelegation {
    func onRequestFailed(){
        self.loadingView?.labelMessage.text = "Ups! Der Austria-Forum Server ist zur Zeit nicht erreichbar"
        self.perform(#selector(DetailViewController.hideLoadingScreen), with: nil, afterDelay: 3)
        print("\(#function) loading \(UserData.sharedInstance.lastVisitedString!)")
        self.webKitView.load(URLRequest(url: URL(string: (UserData.sharedInstance.lastVisitedString?.getSkinnedAFUrl())!)!))
    }
    func onRequestSuccess(_ from: String){
        //  print("Returned from method_ \(from)")
        
        if from == "search.getPageInfo"{
            print("getPageInfo returned successfully");
            
            //update the license tag when we are getting a succes from the server
            self.updateLicenseTag()
            if let _ = SearchHolder.sharedInstance.selectedItem {
                self.detailItem = SearchHolder.sharedInstance.selectedItem
            }
            
            return
        }
        
        
        if let _ = SearchHolder.sharedInstance.selectedItem {
            self.detailItem = SearchHolder.sharedInstance.selectedItem
            self.hideLoadingScreen()
            
        } else {
            self.loadingView?.labelMessage.text = SearchHolder.sharedInstance.resultMessage
            self.perform(#selector(DetailViewController.hideLoadingScreen), with: nil, afterDelay: 3)
            print("\(#function) loading \(UserData.sharedInstance.lastVisitedString!)")
            self.webKitView.load(URLRequest(url: URL(string: (UserData.sharedInstance.lastVisitedString?.getSkinnedAFUrl())!)!))
        }
        
        //update the license tag when we are getting a succes from the server
        self.updateLicenseTag()
    }
    
}
/**
 case settings = 10
 case random = 11
 case monthly = 12
 case location = 13
 case search = 14
 case home = 15
 
 //bottom toolbartags
 case back = 20
 case forward = 21
 case like = 22
 case favourites = 23
 case share = 24
 */

extension DetailViewController: ToolbarDelegate {
    func didPressToolbarButton(with itemType: ToolBar.ToolbarItemType) {
        switch itemType {
        case .settings,
             .location,
             .search,
             .favourites:
            if let controller = itemType.viewController {
                navigationController?.pushViewController(controller, animated: true)
            }
        case .home:
            loadHome()
        case .random:
            loadRandomArticle()
        case .monthly:
            loadArticleFromMonthlyPool()
        case .back:
            back()
        case .forward:
            forward()
        case .like:
            saveArticleAsFavourite()
        case .share:
            shareContentButton()
        }
    }
}





// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
