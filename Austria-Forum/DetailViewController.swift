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
import PKHUD


enum ScrollDirection : Int {
    case scrollDirectionNone = 0
    case scrollDirectionRight
    case scrollDirectionLeft
    case scrollDirectionUp
    case scrollDirectionDown
    case scrollDirectionCrazy
}


class DetailViewController: UIViewController,  UIToolbarDelegate {
    
    //MARK: - Toolbar Actions
    @IBAction func didPressHome(_ sender: Any) { loadHome() }
    @IBAction func didPressRandom(_ sender: Any) { loadRandomArticle() }
    @IBAction func didPressMonthly(_ sender: Any) { loadArticleFromMonthlyPool() }
    @IBAction func didPressLocation(_ sender: Any) { push(type: .location) }
    @IBAction func didPressSearch(_ sender: Any) { push(type: .search)}
    @IBAction func didPressSettings(_ sender: Any) { push(type: .settings) }
    @IBAction func didPressBack(_ sender: Any) { back() }
    @IBAction func didPressForward(_ sender: Any) { forward() }
    @IBAction func didPressFavourite(_ sender: Any) { saveArticleAsFavourite() }
    @IBAction func didPressFavouriteList(_ sender: Any) { push(type: .favourites) }
    @IBAction func didPressShare(_ sender: Any) { shareContentButton() }
    
    private func push(type: ToolBar.ToolbarItemType) {
        guard let controller = type.viewController else { return }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Properties
    @IBOutlet weak var topToolBar: ToolBar!
    @IBOutlet weak var bottomToolBar: ToolBar!
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var constraintTopToolBar: NSLayoutConstraint!
    @IBOutlet weak var constraintBottomToolBar: NSLayoutConstraint!
    
    @IBOutlet weak var licenseTag: UIButton!
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var visualEffectViewHeight: NSLayoutConstraint!
    var scrollDirection : ScrollDirection?
    var lastScrollOffset : CGPoint?
    var pListWorker : ReadWriteToPList?
    let favouriteIconTag = 22
    var webKitView: WKWebView
    let toolBarIconSize : CGSize = CGSize(width: 30, height: 30)
    
    var wkNavigatioinCount : Int = 0
    
    
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
        
        if #available(iOS 11.0, *) {
           visualEffectViewHeight.constant = self.view.safeAreaInsets.top
        } else {
           visualEffectViewHeight.constant = UIApplication.shared.statusBarFrame.height
        }
        
        if UIDevice.current.orientation.isLandscape{
            isLandScape = true
        }
        
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
        self.setupWebkitView()
        self.registerObserverForAppLaunchingFromLocalNotification()
        self.registerObserverForOrientationChange()
       
        
    }
    
    
    fileprivate func configureProperties(){
        
        //favourite worker
        self.pListWorker = ReadWriteToPList()
        
        //set the toolbar delegate for the top to properly display the hairline
        //self.topToolBar.delegate = self
        
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
    
    fileprivate func saveCurrentArticleAsFavourite(webBook: Bool? = false){
        if Helper.saveCurrentArticleAsFavourite(withCurrentUrl: self.webKitView.url, andWithTitle: self.webKitView.title, isWebBook: webBook){
            self.updateFavouriteIcon()
        }
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
        
        
        if let license = SearchHolder.sharedInstance.selectedItem?.licenseResult{
            if let licenseUrl = license.url{
                let url = URL(string: licenseUrl)!
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        } else if let licenseUrl = LicenseManager.getLinkForLicense("AF"){
            // fallbacl license url
            let url = URL(string: licenseUrl)!
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func loadRandomArticle() {
        self.showLoadingScreen()
        RequestManager.sharedInstance.getRandomArticle(self, categories: [UserData.sharedInstance.categorySelected!])
    }
    
    func loadArticleFromMonthlyPool() {
        if UserData.sharedInstance.checkIfArticleOfTheMonthNeedsReload() {
            self.showLoadingScreen()
            RequestManager.sharedInstance.getArticleFromMonthlyPool(self, month: "notset", year: "notset")
         } else {
            if (ReachabilityHelper.sharedInstance.connection == ReachabilityType.no_INTERNET){
                self.noInternet()
            } else {
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
        self.setDetailItem()
    }
    
    
    //MARK: Prepare for Segue - Before Transistion hints
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
                    UIApplication.shared.open(settingsUrl!)
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
        guard !toolBarsHidden else { return }
            if #available(iOS 11.0, *) {
                let insets = self.view.safeAreaInsets
                self.constraintBottomToolBar.constant = -(self.bottomToolBar.frame.height + insets.bottom )
                self.constraintTopToolBar.constant = -(self.topToolBar.frame.height + insets.top)
            } else {
                self.constraintBottomToolBar.constant = -self.bottomToolBar.frame.height
                self.constraintTopToolBar.constant = -self.topToolBar.frame.height
            }
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                self.view.layoutIfNeeded()
                }, completion: {
                    completed in
                    self.topToolBar.alpha = 0.0
                    self.bottomToolBar.alpha = 0.0
                    self.toolBarsHidden = true
            })
    }
    
    fileprivate func showToolBars(){
        guard self.toolBarsHidden else { return }
            self.constraintTopToolBar.constant = 0
            self.constraintBottomToolBar.constant = 0
            self.topToolBar.alpha = 1
            self.bottomToolBar.alpha = 1
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                self.view.layoutIfNeeded()
                }, completion: {
                    completed in
                    self.toolBarsHidden = false
            })
    }
}


//MARK: WKNavigation Delegate - and WebKit Handling
extension DetailViewController : WKNavigationDelegate {
    
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("didFailNavigation")
    }
    
    
    
    
    fileprivate func setupWebkitView(){
        //add the webview to hirarchy
        self.view.insertSubview(webKitView, belowSubview: self.progressBar)
        self.view.bringSubviewToFront(visualEffectView)
        
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
                    UIApplication.shared.open(url!)
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
    
    //MARK: injecting JS to webview
    func loadTitleViaJS() -> String{
        
        let title = ""
        
        return title
    }
}





//MARK: - NetworkDelegate
extension DetailViewController : NetworkDelegation {
    func onRequestFailed(){
        self.flashErrorMessage(title: nil, message: "Webservice nicht verfügbar")
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
            self.flashErrorMessage(title: nil, message: SearchHolder.sharedInstance.resultMessage)
            self.webKitView.load(URLRequest(url: URL(string: (UserData.sharedInstance.lastVisitedString?.getSkinnedAFUrl())!)!))
        }
        
        //update the license tag when we are getting a succes from the server
        self.updateLicenseTag()
    }
    
}

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
