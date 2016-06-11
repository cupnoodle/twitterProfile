//
//  ViewController.swift
//  twitterProfile
//
//  Created by Axel Kee on 09/06/2016.
//  Copyright © 2016 Sweatshop. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let headerHeight : CGFloat = 100.0
    let subHeaderHeight : CGFloat = 100.0
    let avatarImageSize : CGFloat = 70.0
    let avatarImageShrinkedSize : CGFloat = 44.0
    
    var systemStatusBarHeight : CGFloat = 0.0
    var systemNavBarHeight : CGFloat = 0.0
    
    var headerTriggerOffset : CGFloat = 0.0
    
    var isBarCollapsed = false
    var isBarAnimationComplete = false
    
    var blurredImageCache : NSDictionary = NSDictionary()
    
    var coverImageHeaderView : UIImageView = UIImageView()
    var originalBackgroundImage : UIImage = UIImage()
    var customTitleView : UIView = UIView()
    
    
    @IBOutlet weak var tweetTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.initializeNavBar()
        
        systemStatusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        systemNavBarHeight = self.navigationController!.navigationBar.frame.height
        
        // minus the component in bracket to compensate the adjusted scroll inset
        headerTriggerOffset = headerHeight - (systemStatusBarHeight + systemNavBarHeight) - systemStatusBarHeight - systemNavBarHeight
        
        self.tweetTable.dataSource = self
        self.tweetTable.delegate = self
        self.tweetTable.translatesAutoresizingMaskIntoConstraints = false
        
        // minus the component in bracket to compensate the adjusted scroll inset
        self.tweetTable.tableHeaderView?.frame = CGRectMake(0, 0, self.view.frame.size.width, headerHeight - (systemNavBarHeight + systemStatusBarHeight) + subHeaderHeight)
        
        self.originalBackgroundImage = UIImage(named: "Cover")!
        
        let coverImageView : UIImageView = UIImageView(image: UIImage(named: "Cover"))
        coverImageView.translatesAutoresizingMaskIntoConstraints = false //auto layout
        coverImageView.contentMode = .ScaleAspectFill
        coverImageView.clipsToBounds = true
        
        self.coverImageHeaderView = coverImageView
        
        self.tweetTable.tableHeaderView?.addSubview(self.coverImageHeaderView)
        
        let subHeaderView : UIView = self.createSubHeaderView()
        subHeaderView.translatesAutoresizingMaskIntoConstraints = false
        self.tweetTable.tableHeaderView?.insertSubview(subHeaderView, belowSubview: coverImageHeaderView)
        
        let avatarImageView : UIImageView = self.createAvatarImageView()
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        self.tweetTable.tableHeaderView?.addSubview(avatarImageView)
        
        /*
         * At this point tableHeader views are ordered like this:
         * Bottom to top in this order :
         * 0 : subHeaderView
         * 1 : coverImageHeaderView
         * 2 : avatarImageView
         */
        
        self.automaticallyAdjustsScrollViewInsets = true
        
        /* Auto Layout Settings */
        
        // Initialize dictionary of views
        let views = ["super" : self.view,
                     "tableView" : self.tweetTable,
                     "coverImageHeaderView" : self.coverImageHeaderView,
                     "subHeaderView" : subHeaderView,
                     "avatarImageView" : avatarImageView]
        let metrics = ["headerHeight" : headerHeight - (systemNavBarHeight + systemStatusBarHeight),
                       "minHeaderHeight" : systemStatusBarHeight + systemNavBarHeight,
                       "subHeaderHeight" : self.subHeaderHeight,
                       "avatarSize" : avatarImageSize,
                       "avatarShrinkedSize" : avatarImageShrinkedSize]
        var constraints = []
        var constraint : NSLayoutConstraint = NSLayoutConstraint()
        var format = ""
        
        // == Table view auto layout already set in storyboard
        
        // == Image header view width is same as table view width
        
        format = "|-0-[coverImageHeaderView]-0-|"
        constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
        self.tweetTable.tableHeaderView?.addConstraints(constraints as! [NSLayoutConstraint])
        
        format = "|-0-[subHeaderView]-0-|"
        constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
        self.tweetTable.tableHeaderView?.addConstraints(constraints as! [NSLayoutConstraint])
        
        // == Image header view's height should not be less than navbar, and subHeaderView stay below navbar
        
        format = "V:[coverImageHeaderView(>=minHeaderHeight)]-(subHeaderHeight@750)-|"
        constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
        self.view.addConstraints(constraints as! [NSLayoutConstraint])
        
        format = "V:|-(headerHeight)-[subHeaderView(subHeaderHeight)]"
        constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
        self.view.addConstraints(constraints as! [NSLayoutConstraint])
        
        // == Image header view should stick on top of the screen
        
        let stickyConstraint : NSLayoutConstraint = NSLayoutConstraint(item: coverImageHeaderView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0.0)
        self.view.addConstraint(stickyConstraint)
        
        // == Avatar should stick to the left of the screen with default margin
        format = "|-[avatarImageView]"
        constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
        self.view.addConstraints(constraints as! [NSLayoutConstraint])
        
        // == Avatar is square
        constraint = NSLayoutConstraint(item: avatarImageView, attribute: .Width, relatedBy: .Equal, toItem: avatarImageView, attribute: .Height, multiplier: 1.0, constant: 0.0)
        self.view.addConstraint(constraint)
        
        // == Avatar size can between avatar size and avatar shrinked size
        format = "V:[avatarImageView(<=avatarSize@760,>=avatarShrinkedSize@800)]"
        constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
        self.view.addConstraints(constraints as! [NSLayoutConstraint])
        
        // == Avatar top least distance to main view top
        // notice the avatar shrinked size has higher priority, it means that once the avatar is shrinked to that size, the avatar top constraint will be violated and avatar will scroll up
        constraint = NSLayoutConstraint(item: avatarImageView, attribute: .Top, relatedBy: .GreaterThanOrEqual, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: systemStatusBarHeight + systemNavBarHeight)
        constraint.priority = 790
        self.view.addConstraint(constraint)
 
        
        // == Avatar bottom aligned to SubHeader bottom, this has higher precedence to the avatar top constraint
        
        constraint = NSLayoutConstraint(item: avatarImageView, attribute: .Bottom, relatedBy: .Equal, toItem: subHeaderView, attribute: .Bottom, multiplier: 1.0, constant: -50)
        constraint.priority = 801
        
        self.view.addConstraint(constraint)
 
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - Table View source and delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let reuseIdentifier = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) //as! UITableViewCell
        
        cell.textLabel!.text = "Item " + String(indexPath.row)
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    //MARK: - View Controller's graphic related function
    func createSubHeaderView() -> UIView {
        let view : UIView = UIView()
        
        
        let followButton = UIButton(type: .RoundedRect)
        followButton.translatesAutoresizingMaskIntoConstraints = false
        followButton.setTitle("  Follow  ", forState: .Normal)
        followButton.layer.cornerRadius = 2
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor.greenColor().CGColor
        
        view.addSubview(followButton)
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Asriel Dreemurr"
        nameLabel.numberOfLines = 1
        nameLabel.font = UIFont.boldSystemFontOfSize(18.0)
        
        view.addSubview(nameLabel)
        
        
        let views = ["super" : self.view,
                     "followButton" : followButton,
                     "nameLabel" : nameLabel]
        
        var constraints = []
        var format = ""
        
        format = "[followButton]-8-|"
        constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        view.addConstraints(constraints as! [NSLayoutConstraint])
        
        format = "|-8-[nameLabel]"
        constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        view.addConstraints(constraints as! [NSLayoutConstraint])
        
        format = "V:|-[followButton]"
        constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        view.addConstraints(constraints as! [NSLayoutConstraint])
        
        format = "V:|-60-[nameLabel]";
        constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        view.addConstraints(constraints as! [NSLayoutConstraint])
        
        return view
    }
    
    func createAvatarImageView() -> UIImageView {
        let avatarView : UIImageView = UIImageView(image: UIImage(named: "Avatar"))
        avatarView.contentMode = .ScaleToFill
        avatarView.layer.cornerRadius = 8.0
        avatarView.layer.borderWidth = 3.0
        avatarView.layer.borderColor = UIColor.whiteColor().CGColor
        
        avatarView.clipsToBounds = true
        return avatarView
    }
    
    func createTitleView() -> UIView {
        let handleLabel : UILabel = UILabel()
        handleLabel.translatesAutoresizingMaskIntoConstraints = false
        handleLabel.text = "Asriel"
        handleLabel.numberOfLines = 1
        handleLabel.textColor = UIColor.whiteColor()
        handleLabel.font = UIFont.boldSystemFontOfSize(15.0)
        handleLabel.textAlignment = .Center
        
        let tweetCountLabel : UILabel = UILabel()
        tweetCountLabel.translatesAutoresizingMaskIntoConstraints = false
        tweetCountLabel.text = "1,000 Tweets"
        tweetCountLabel.numberOfLines = 1
        tweetCountLabel.textColor =  UIColor.whiteColor()
        tweetCountLabel.font = UIFont.boldSystemFontOfSize(10.0)
        tweetCountLabel.textAlignment = .Center
        
        let wrapperView = UIView()
        wrapperView.addSubview(handleLabel)
        wrapperView.addSubview(tweetCountLabel)
        
        let views = ["handleLabel" : handleLabel,
                     "tweetCountLabel" : tweetCountLabel]
        var constraints = []
        var format = ""
        
        format = "|-0-[handleLabel]-0-|"
        constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        wrapperView.addConstraints(constraints as! [NSLayoutConstraint])
        
        format = "|-0-[tweetCountLabel]-0-|"
        constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        wrapperView.addConstraints(constraints as! [NSLayoutConstraint])
        
        format = "V:|-0-[handleLabel]-2-[tweetCountLabel]-0-|"
        constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: .AlignAllCenterX, metrics: nil, views: views)
        
        // set wrapperView frame size, else navbar will treat it as 0 height 0 width
        wrapperView.frame = CGRectMake(0, 0, max(handleLabel.intrinsicContentSize().width, tweetCountLabel.intrinsicContentSize().width), handleLabel.intrinsicContentSize().height + 2 + tweetCountLabel.intrinsicContentSize().height)
        
        wrapperView.clipsToBounds = true
        
        return wrapperView
    }
    
    // MARK: - Navigation bar customization
    
    func initializeNavBar() {
        self.view.backgroundColor = UIColor.greenColor()
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barStyle = .Black
        self.navigationController?.navigationBar.translucent = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: nil)
        
        self.switchToExpandedHeader()
        
    }
    
    func switchToExpandedHeader() {
        
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.titleView = nil
        
        self.isBarAnimationComplete = false
        self.coverImageHeaderView.image = self.originalBackgroundImage
        
        /*
         * At this point tableHeader views are ordered like this:
         * Bottom to top in this order :
         * 0 : subHeaderView
         * 1 : coverImageHeaderView
         * 2 : avatarImageView
         */
        
        // Inverse Z-Order of avatar and cover image view. i.e : put avatar in front of cover image view
        self.tweetTable.tableHeaderView?.exchangeSubviewAtIndex(1, withSubviewAtIndex: 2)
    }
    
    func switchToMinifiedHeader() {
        
        self.isBarAnimationComplete = false
        self.navigationItem.titleView = createTitleView()
        self.navigationController?.navigationBar.clipsToBounds = true
        
        //Setting the view transform or changing frame origin has no effect, only this call does
        self.navigationController?.navigationBar.setTitleVerticalPositionAdjustment(systemNavBarHeight, forBarMetrics: .Default)
        
        
        /*
         * At this point tableHeader views are ordered like this:
         * Bottom to top in this order :
         * 0 : subHeaderView
         * 1 : coverImageHeaderView
         * 2 : avatarImageView
         */
        
        // Inverse Z-Order of avatar and cover image view. i.e : put avatar in front of cover image view
        self.tweetTable.tableHeaderView?.exchangeSubviewAtIndex(1, withSubviewAtIndex: 2)
    }
    
    // MARK: - Scroll view delegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let yPos = scrollView.contentOffset.y
        
        if(yPos > headerTriggerOffset && !self.isBarCollapsed){
            self.switchToMinifiedHeader()
            self.isBarCollapsed = true
        }else if(yPos < headerTriggerOffset && isBarCollapsed){
            self.switchToExpandedHeader()
            self.isBarCollapsed = false
        }
    }
    
    // MARK: - Blur effects on image
    
    func blurredImageOf(image: UIImage, withRadius radius: CGFloat) -> UIImage {
        return UIImageEffects.imageByApplyingBlurToImage(image, withRadius: radius, tintColor: UIColor.whiteColor().colorWithAlphaComponent(0.2), saturationDeltaFactor: 1.5, maskImage: nil)
    }
    
    func blurredImageAt(percent: CGFloat) -> UIImage{
        
        //percent is between 0 to 1
        var keyNumber : Int = 0
        
        keyNumber = Int(ceil(Double(percent) * 10))
        
        let image = self.blurredImageCache.objectForKey(String(keyNumber)) as? UIImage
        
        // return original image if cache haven't generate finish
        if(image == nil){
            return self.originalBackgroundImage
        }
        
        return image!
    }
    
    func generateBlurredImageCache() {
        let maxBlurRadius : CGFloat = 30.0
        self.blurredImageCache = NSDictionary()
        
        for i in 1...10 {
            self.blurredImageCache.setValue(self.blurredImageOf(self.originalBackgroundImage, withRadius: (maxBlurRadius * CGFloat(i)/10.0)), forKey: String(i))
        }
        
        
    }
    
}

