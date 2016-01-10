//
//  DetailViewController.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 10.12.15.
//  Copyright © 2015 Paul Neuhold. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController, ReachabilityDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var detailItem: SearchResult? {
        didSet {
            self.refreshUI()
        }
    }
    
    
    var loadingView : LoadingScreen?
    var pListWorker : ReadWriteToPList?
    let favouriteIconTag = 3
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Always set the current controller as the delegate to ReachabilityHelper
        ReachabilityHelper.sharedInstance.delegate = self
        self.webView.delegate = self
        self.webView.scrollView.delegate = self
        self.webView.scrollView.backgroundColor = UIColor.whiteColor()
        self.topToolBar.clipsToBounds = true
        self.webView.clipsToBounds = true
        
        self.loadingView = NSBundle.mainBundle().loadNibNamed("LoadingScreen", owner: self, options: nil)[0] as? LoadingScreen
        self.pListWorker = ReadWriteToPList()
        
        
        self.progressBar.hidden = true
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.detailItem = SearchHolder.sharedInstance.selectedItem
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.loadingView?.frame = self.view.frame
        
    }
    
    
    // MARK: - IBActions
    
    
    
    @IBAction func loadRandomArticle(sender: AnyObject) {
        
        self.showLoadingScreen()
        //we pick a random category on the client, because picking a random from all categories on the server takes too long
        let allCategories = ["AEIOU","Alltagskultur","AustriaWiki","Bilder_und_Videos","Community","Geography","Kunst_und_Kultur","Natur","Politik_und_Geschichte","Videos","Wissenschaft_und_Wirtschaft","Wissenssammlungen/Biographien","Wissenssammlungen/Essays"]
        let oneCategory: String = allCategories[(random() % allCategories.count)]
        
        RequestManager.sharedInstance.getRandomArticle(self, categories: [oneCategory])
    }
    @IBAction func loadArticleFromMonthlyPool(sender: AnyObject) {
               
        if UserData.sharedInstance.checkIfArticleOfTheMonthNeedsReload() {
            self.showLoadingScreen()
            RequestManager.sharedInstance.getArticleFromMonthlyPool(self, month: "notset", year: "notset")
        } else {
            self.detailItem = UserData.sharedInstance.articleOfTheMonth
        }
    }
    @IBAction func saveArticleAsFavourite(sender: AnyObject) {
    
        var  activeArticle : [String:String] = [:]
        if let activeArticleInWebView = SearchHolder.sharedInstance.selectedItem {
            activeArticle["title"] = activeArticleInWebView.title
            activeArticle["url"] = activeArticleInWebView.url.stringByReplacingOccurrencesOfString("?skin=page", withString: "")
        } else if let activeTitle = SearchHolder.sharedInstance.currentTitle, let activeUrl = self.webView.request?.URLString {
            activeArticle["title"] = activeTitle
            activeArticle["url"] = activeUrl.stringByReplacingOccurrencesOfString("?skin=page", withString: "")
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
        
        if let currentAfUrl = self.webView.request?.URLString {
            let stringUrl = currentAfUrl.stringByReplacingOccurrencesOfString("?skin=page", withString: "")
            let url = NSURL(string: stringUrl)
            let activityVC = UIActivityViewController(activityItems: [url!], applicationActivities: nil)
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
        
        
        
    }
    
    @IBAction func locationArticleAction(sender: UIBarButtonItem) {
        
        
    }
    
    
    
    
    //MARK: - Custom Functions
    func refreshUI(){
        //load the new set artivle into the webView
        if let stringUrl = self.detailItem?.url {
            if self.webView.request?.URLString == stringUrl{
                return
            }
            let newUrl = stringUrl // only local server stuff // --> stringUrl.stringByReplacingOccurrencesOfString("localhost", withString: "192.168.178.21")
            let skinRaw = newUrl.stringByAppendingString("?skin=page")
            let url : NSURL? = NSURL(string: skinRaw)
            print("load into webView: \(url?.URLString)")
            self.webView.loadRequest(NSURLRequest(URL: url!))
            
            
        }
    }
    
    
    func showLoadingScreen() {
        
        if let v = self.loadingView {
            print("adding \(v) now")
            
            
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
                if self.pListWorker!.isFavourite(["url": (self.webView.request?.URLString)!]){
                    item.image = UIImage(named: "liked.png")
                } else {
                    item.image = UIImage(named: "like_it.png")
                    
                }
            }
        }
    }
    
    
    // MARK: - Delegation
    
    func noInternet() {
        //we present a no internet viewcontroller.
    }
    
    
    
    
    
}

//MARK: - UIScrollViewDelegate
extension DetailViewController : UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView){
        //TODO better handling for hiding the toolbars - fade in/out
        //  self.topToolBar.hidden = true
        //  self.bottomToolBar.hidden = true
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        //  self.topToolBar.hidden = false
        //  self.bottomToolBar.hidden = false
    }
    
}


//MARK: - NetworkDelegate
extension DetailViewController : NetworkDelegation {
    func onRequestFailed(){
        self.loadingView?.activityIndicator.stopAnimating()
        self.loadingView?.removeFromSuperview()
        
    }
    func onRequestSuccess(){
        let stringUrl = SearchHolder.sharedInstance.selectedItem!.url
        let newUrl = stringUrl.stringByReplacingOccurrencesOfString("localhost", withString: "192.168.178.21")
        let skinRaw = newUrl.stringByAppendingString("?skin=page")
        let url : NSURL? = NSURL(string: skinRaw)
        print("pageUrl = \(url?.URLString)")
        self.webView.loadRequest(NSURLRequest(URL: url!))
        
        self.loadingView?.removeFromSuperview()
    }
}


//MARK: - WebView Delegate
extension DetailViewController : UIWebViewDelegate {
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool{
        print("webview delegate was called");
        print("requested url is: \(request.URLString)")
        
        //present content which isnt from AF in Safari
        if request.URLString.containsString(BaseRequest.urlAFStatic) == false {
            UIApplication.sharedApplication().openURL(request.URL!)
            return false
        }
        
        if navigationType == UIWebViewNavigationType.LinkClicked {
            
            let pageUrl = request.URLString + "?skin=page"
            let url : NSURL? = NSURL(string: pageUrl)
            SearchHolder.sharedInstance.selectedItem = nil
            SearchHolder.sharedInstance.lastUrl = request.URLString
            self.webView.loadRequest(NSURLRequest(URL: url!))
            return false
            
        } else if navigationType == .BackForward {
            SearchHolder.sharedInstance.selectedItem = nil
            SearchHolder.sharedInstance.lastUrl = request.URLString
        }
        return true;
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        
        let currentTitle : String? = self.loadCurrentTitleFromHTML()
        SearchHolder.sharedInstance.currentTitle = currentTitle
        self.progressBar.setProgress(1, animated: true)
        self.performSelector("hideProgressBar", withObject: nil, afterDelay: 0.5)
        self.updateFavouriteIcon()
    }
    
    func hideProgressBar() {
        self.progressBar.hidden = true
        self.progressBar.setProgress(0, animated: false)
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        self.progressBar.hidden = false
        self.progressBar.setProgress(0.5, animated: true)
        
    }
    
    func loadCurrentTitleFromHTML () -> String? {
        let jsCMD =
        //declare a function
        "function getHeaderTitle () { var values = document.getElementsBySelector(\"h1\");" +
            "if (values.length > 0){" +
            "var headerTag = values[0]; " +
            "}" +
            "return headerTag.getText()}" +
            //now call the function and get a return string
        "getHeaderTitle()"
        
        return self.webView.stringByEvaluatingJavaScriptFromString(jsCMD)
    }
    
}



