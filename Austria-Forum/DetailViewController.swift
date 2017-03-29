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
    
    let answersEventLicense = "License"
    let answersEventRandom = "Random Article"
    let answersEventMonthly = "Monthly Article"
    let answersEventAddFavs = "Add Favourite"
    static let answersEventFromPush = "Start From Push"
    let answersEventLocation = "Location Articles"
    let answersEventHome = "Home Navigation"
    let answersEventFavs = "Open Favourites"
    let answersEventShare = "Share Article"
    let answersEventSearch = "Search Articles"
    
    
    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Always set the current controller as the delegate to ReachabilityHelper
        ReachabilityHelper.sharedInstance.delegate = self
        
        self.setDetailItem()
        
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation){
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
        self.topToolBar.delegate = self
        
        //Please Wait ... Screen
        self.loadingView = Bundle.main.loadNibNamed("LoadingScreen", owner: self, options: nil)![0] as? LoadingScreen
        
        //on start up hide progress bar - will be handled by the webkit
        self.progressBar.isHidden = true
        self.progressBar.progress = 0
        self.progressBar.progressViewStyle = UIProgressViewStyle.bar
        
        //hide license tag on start up
        self.licenseTag.isHidden = true
        
        
        
    }
    
    
    fileprivate func registerObserverForAppLaunchingFromLocalNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(DetailViewController.appBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    fileprivate func registerObserverForOrientationChange(){
        NotificationCenter.default.addObserver(self, selector: #selector(DetailViewController.deviceRotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    fileprivate func removeObservers(){
        self.webKitView.removeObserver(self, forKeyPath: "URL")
        self.webKitView.removeObserver(self, forKeyPath: "estimatedProgress")
        print("\n\n Removing Observers \n\n")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        //        webKitView.removeObserver(self, forKeyPath: "URL", context: nil)
        //        webKitView.removeObserver(self, forKeyPath: "estimatedProgress", context: nil)
        //
    }
    
    func deviceRotated(){
        if(UIDeviceOrientationIsLandscape(UIDevice.current.orientation))
        {
            if let disableToolbar = UserData.sharedInstance.disableToolbar{
                if disableToolbar {
                    hideToolBars()
                }
            }
            isLandScape = true
        }
        
        if(UIDeviceOrientationIsPortrait(UIDevice.current.orientation))
        {
            isLandScape = false
            showToolBars()
        }
    }
    
    func appBecomeActive(){
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
        var  activeArticle : [String:String] = [:]
        
        if let activeArticleInWebView = SearchHolder.sharedInstance.selectedItem, let currentCategory = SearchHolder.sharedInstance.currentCategory {
            activeArticle["title"] = activeArticleInWebView.title
            activeArticle["url"] = activeArticleInWebView.url?.replacingOccurrences(of: "?skin=page", with: "")
            activeArticle["category"] = currentCategory
        } else if let activeTitle = SearchHolder.sharedInstance.currentTitle, let activeUrl = self.webKitView.url?.absoluteString , let currentCategory = SearchHolder.sharedInstance.currentCategory {
            activeArticle["title"] = activeTitle
            activeArticle["url"] = activeUrl.replacingOccurrences(of: "?skin=page", with: "")
            activeArticle["category"] = currentCategory
        } else if let activeUrl = self.webKitView.url?.absoluteString , let currentCategory = SearchHolder.sharedInstance.currentCategory {
            activeArticle["title"] = self.webKitView.url?.path ?? activeUrl
            activeArticle["url"] = activeUrl.replacingOccurrences(of: "?skin=page", with: "")
            activeArticle["category"] = currentCategory
        }
        
        if let webBook = webBook {
            if webBook {
                if let activeUrl = self.webKitView.url?.absoluteString {
                    activeArticle["title"] = self.webKitView.title ?? activeUrl
                    activeArticle["url"] = activeUrl.replacingOccurrences(of: "?skin=page", with: "")
                    activeArticle["category"] = "Web Book"
                }
            }
        }
        
        if !activeArticle.isEmpty {
            _ = pListWorker?.loadFavourites()
            if pListWorker?.isFavourite(activeArticle) == false {
                _ = pListWorker?.saveFavourite(activeArticle)
                self.trackAnalyticsEvent(withCategory: answersEventAddFavs, action: activeArticle["title"]!, label: "\(activeArticle["url"]!)  \(activeArticle["category"]!)")
            } else {
                _ = pListWorker?.removeFavourite(activeArticle)
            }
            FavouritesHolder.sharedInstance.refresh()
            self.updateFavouriteIcon()
        } else {
            print("No Article Loaded for saving as Favourite")
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
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        } else if let licenseUrl = LicenseManager.getLinkForLicense("AF"){
            // fallbacl license url
            answersAttributes["License"] = "AF"
            let url = URL(string: licenseUrl)!
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        self.logToAnswers(answersEventLicense, customAttributes: answersAttributes as [String : AnyObject]?)
        self.trackAnalyticsEvent(withCategory: answersEventLicense, action: answersAttributes["License"]!)
    }
    
    @IBAction func loadRandomArticle(_ sender: AnyObject) {
        self.logToAnswers(answersEventRandom, customAttributes: ["Rnd Article - Category" : UserData.sharedInstance.categorySelected! as AnyObject])
        self.trackAnalyticsEvent(withCategory: answersEventRandom, action: UserData.sharedInstance.categorySelected!)
        self.showLoadingScreen()
        RequestManager.sharedInstance.getRandomArticle(self, categories: [UserData.sharedInstance.categorySelected!])
    }
    
    @IBAction func loadArticleFromMonthlyPool(_ sender: AnyObject) {
        self.logToAnswers(answersEventMonthly, customAttributes: ["Monthly Article" : "requested" as AnyObject])
        
        if UserData.sharedInstance.checkIfArticleOfTheMonthNeedsReload() {
            self.showLoadingScreen()
            RequestManager.sharedInstance.getArticleFromMonthlyPool(self, month: "notset", year: "notset")
            self.trackAnalyticsEvent(withCategory: answersEventMonthly, action: "Load Article From Server")
        } else {
            if (ReachabilityHelper.sharedInstance.connection == ReachabilityType.no_INTERNET){
                self.noInternet()
            } else {
                self.trackAnalyticsEvent(withCategory: answersEventMonthly, action: "Load Article from Storage")
                self.detailItem = UserData.sharedInstance.articleOfTheMonth
            }
        }
    }
    
    @IBAction func saveArticleAsFavourite(_ sender: AnyObject) {
        if isRightNowAWebBookLoaded(){
            self.saveCurrentArticleAsFavourite(webBook: true)
        } else {
            self.saveCurrentArticleAsFavourite()
        }
    }
    
    @IBAction func shareContentButton(_ sender: UIBarButtonItem) {
        if let sr = SearchHolder.sharedInstance.selectedItem {
            self.trackAnalyticsEvent(withCategory: answersEventShare, action: sr.title ?? "got Nil Title", label: sr.url ?? "got Nil Url")
            self.logToAnswers(answersEventShare, customAttributes: ["Article" : sr.title as AnyObject? ?? "got Nil Title" as AnyObject])
        } else if let currentUrl = self.webKitView.url?.absoluteString {
            self.trackAnalyticsEvent(withCategory: answersEventShare, action: "Webbook" , label: currentUrl )
            self.logToAnswers(answersEventShare, customAttributes: ["Article" : "Webbook" as AnyObject])
        }
        
        if let currentAfUrl = self.webKitView.url?.absoluteString {
            if currentAfUrl != "" {
                let stringUrl = currentAfUrl.replacingOccurrences(of: "?skin=page", with: "")
                let url = URL(string: stringUrl)
                let items = [url!]
                let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
                //we exclude them because we have massive leaks in the built-in functions
                activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.copyToPasteboard,UIActivityType.addToReadingList]
                //support ipads
                
                if activityVC.responds(to: #selector(getter: UIViewController.popoverPresentationController)){
                    activityVC.popoverPresentationController?.barButtonItem = sender
                }
                activityVC.completionWithItemsHandler = nil
                
                self.present(activityVC, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        if self.webKitView.canGoBack{
            self.webKitView.goBack()
        }
        
        print("back forward list : \(self.webKitView.backForwardList.debugDescription)")
        for bItems in self.webKitView.backForwardList.backList {
            print("url of back item: \(bItems.url.absoluteString)")
        }
    }
    @IBAction func forward(_ sender: UIBarButtonItem) {
        if self.webKitView.canGoForward {
            self.webKitView.goForward()
        }
        print("back forward list : \(self.webKitView.backForwardList.debugDescription)")
        for bItems in self.webKitView.backForwardList.forwardList {
            print("url of forward item: \(bItems.url.absoluteString)")
        }
    }
    
    @IBAction func loadHome(_ sender: UIBarButtonItem) {
        if (ReachabilityHelper.sharedInstance.connection == ReachabilityType.no_INTERNET){
            self.noInternet()
            return
        }
        
        SearchHolder.sharedInstance.selectedItem = SearchResult(title: "Austria-Forum", name: "Austria-Forum", url: UserData.AF_URL, score: 100, licenseResult: nil)
        self.logToAnswers(answersEventHome, customAttributes: nil)
        self.trackAnalyticsEvent(withCategory: answersEventHome, action: "Going Home")
        self.setDetailItem()
    }
    
    
    //MARK: Prepare for Segue - Before Transistion hints
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == "toLocationArticles" {
            self.logToAnswers(answersEventLocation, customAttributes: nil)
        } else if identifier == "toSearchArticle" {
            self.logToAnswers(answersEventSearch, customAttributes: nil )
        } else if identifier == "toFavourites"{
            self.logToAnswers(answersEventFavs, customAttributes: nil )
        }
        print("performing segue \(identifier)")
        
        return true
    }
    
    
    func hintToSettings(inAppSetting: Bool) {
        let alertController : UIAlertController = UIAlertController(title: "Ortungsdienste", message: "Austria-Forum darf zur Zeit nicht auf ihren Standort zugreifen. Sie können dies in den Einstellungen ändern wenn Sie wollen.", preferredStyle: UIAlertControllerStyle.alert)
        let actionAbort : UIAlertAction = UIAlertAction(title: "Abbruch", style: UIAlertActionStyle.cancel, handler: {
            cancleAction in
            print("pressed cancle")
            
        })
        let actionToSettings : UIAlertAction = UIAlertAction(title: "Einstellungen", style: UIAlertActionStyle.default, handler: {
            alertAction  in
            print("go to settings")
            if inAppSetting{
                self.performSegue(withIdentifier: "toSettings", sender: self)
            } else {
                let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl!, options: [:], completionHandler: nil)
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
            v.bringSubview(toFront: self.view)
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
    
    func hideNoInternetView() -> Bool {
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
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
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
                let url = prepareUrlForloading(url: (navigationAction.request.url?.absoluteString)!)
                wkNavigatioinCount = 0
                self.webKitView.load(URLRequest(url: URL(string: url)!))
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
        
        self.getPageInfoFromUrl(SearchHolder.sharedInstance.currentUrl!.replacingOccurrences(of: "?skin=page", with: ""))
    }
    
    
    func showLoadingScreen() {
        
        if let v = self.loadingView {
            print("adding \(v) now")
            
            v.labelMessage.text = "Bitte Warten ..."
            self.view.addSubview(v)
            v.bringSubview(toFront: self.view)
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
                if self.pListWorker!.isFavourite(["url": (self.webKitView.url?.absoluteString)!]){
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
            stringUrl = stringUrl.replacingOccurrences(of: "?skin=page", with: "")
            selectedUrl = selectedUrl.replacingOccurrences(of: "?skin=page", with: "")
            //we don't want to reload the webview if the url didn't change
            let webKitUrl = self.webKitView.url?.absoluteString.replacingOccurrences(of: "?skin=page", with: "")
            if webKitUrl == stringUrl {
                return
            }
            //the url is not the same anymore rebuild it with the skin and load it
            let url : URL? = URL(string: prepareUrlForloading(url: stringUrl))
            print("\(#function) loading \(String(describing: url?.absoluteString))")
            self.webKitView.load(URLRequest(url: url!))
        } else {
            let loadUrl = UserData.sharedInstance.lastVisitedString!.replacingOccurrences(of: "?skin=page", with: "")
            if self.webKitView.url?.absoluteString.replacingOccurrences(of: "?skin=page", with: "") == loadUrl {
                return
            }
            let url : URL? = URL(string: prepareUrlForloading(url: loadUrl))
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
                self.licenseTag.setImage(image, for: UIControlState())
                self.licenseTag.isHidden = false
            }
        } else {
            //fallback license
            let licenseImageName = LicenseManager.getImageNameForLicense("af")
            if let name = licenseImageName {
                let image = UIImage(named: name)
                self.licenseTag.setImage(image, for: UIControlState())
                self.licenseTag.isHidden = false
            }
            
        }
        
    }
    
    func getPageInfoFromUrl(_ url: String){
        RequestManager.sharedInstance.getPageInfoFromUrls(self, urls: [url])
    }
    
    
    func hideProgressBar() {
        self.progressBar.isHidden = true
        self.progressBar.setProgress(0, animated: false)
    }
    
    
    func hideLoadingScreen() {
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
        self.webKitView.load(URLRequest(url: URL(string: self.prepareUrlForloading(url: UserData.sharedInstance.lastVisitedString!))!))
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
            self.webKitView.load(URLRequest(url: URL(string: self.prepareUrlForloading(url: UserData.sharedInstance.lastVisitedString!))!))
        }
        
        //update the license tag when we are getting a succes from the server
        self.updateLicenseTag()
    }
    
}




