//
//  DetailViewController.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 10.12.15.
//  Copyright © 2015 Paul Neuhold. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController, ReachabilityDelegate, UIWebViewDelegate, UIScrollViewDelegate, NetworkDelegation {
    
    // MARK: - Properties
    @IBOutlet weak var webView: UIWebView!
    var webKitView : WKWebView?
    
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    
    
    required init?(coder aDecoder: NSCoder) {
        self.webKitView = WKWebView(frame: CGRectZero)
        super.init(coder: aDecoder)
    }
    
    
    var detailItem: SearchResult? {
        didSet {
            self.refreshUI()
        }
    }
    
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
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.detailItem = SearchHolder.sharedInstance.selectedItem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - IBActions
    
    
    @IBAction func back(sender: AnyObject) {
        
    }
    
    @IBAction func loadRandomArticle(sender: AnyObject) {
        RequestManager.sharedInstance.getRandomArticle(self, categories: [])
    }
    @IBAction func loadArticleFromMonthlyPool(sender: AnyObject) {
        RequestManager.sharedInstance.getArticleFromMonthlyPool(self, month: "November", year: "2015")
    }
    
    //MARK: - Custom Functions
    func refreshUI(){
        //load the new set artivle into the webView
        let stringUrl = self.detailItem?.url
        let newUrl = stringUrl?.stringByReplacingOccurrencesOfString("localhost", withString: "192.168.178.21")
        let skinRaw = newUrl?.stringByAppendingString("?skin=page")
        let url : NSURL? = NSURL(string: skinRaw!)
        self.webView.loadRequest(NSURLRequest(URL: url!))
    }
    
    
    // MARK: - Delegation
    
    func noInternet() {
        //we present a no internet viewcontroller.
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool{
        print("webview delegate was called");
        if navigationType == UIWebViewNavigationType.LinkClicked {
            let pageUrl = request.URLString + "?skin=page"
            if pageUrl.containsString(BaseRequest.urlAFStatic) {
                let url : NSURL? = NSURL(string: pageUrl)
                self.webView.loadRequest(NSURLRequest(URL: url!))
                return false
            } else {
                UIApplication.sharedApplication().openURL(request.URL!)
                return false
            }
            
        }
        return true;
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView){
        //TODO better handling for hiding the toolbars - fade in/out
        //  self.topToolBar.hidden = true
        //  self.bottomToolBar.hidden = true
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        //  self.topToolBar.hidden = false
        //  self.bottomToolBar.hidden = false
    }
    
    func onRequestFailed(){
        
    }
    func onRequestSuccess(){
        let stringUrl = SearchHolder.sharedInstance.selectedItem!.url
        let newUrl = stringUrl.stringByReplacingOccurrencesOfString("localhost", withString: "192.168.178.21")
        let skinRaw = newUrl.stringByAppendingString("?skin=page")
        let url : NSURL? = NSURL(string: skinRaw)
        self.webView.loadRequest(NSURLRequest(URL: url!))
    }
}




