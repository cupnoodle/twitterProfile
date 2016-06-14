//
//  ViewController.swift
//  twitterProfile
//
//  Created by Axel Kee on 09/06/2016.
//  Copyright © 2016 Sweatshop. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let descriptionText : String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam."
    
    let twitterBlueColor : UIColor = UIColor(red: 0.26, green: 0.67, blue: 0.95, alpha: 1.0)
    let spacingFromTopToSubHeader : CGFloat = 100.0
    let headerHeight : CGFloat = 120.0
    var subHeaderHeight : CGFloat = 170.0
    let avatarImageSize : CGFloat = 70.0
    let avatarImageShrinkedSize : CGFloat = 44.0
    
    var systemStatusBarHeight : CGFloat = 0.0
    var systemNavBarHeight : CGFloat = 0.0
    
    var headerTriggerOffset : CGFloat = 0.0
    
    var isBarCollapsed = false
    var isBarAnimationComplete = false
    
    var blurredImageCache : NSMutableDictionary = NSMutableDictionary()
    
    var coverImageHeaderView : UIImageView = UIImageView()
    var originalBackgroundImage : UIImage = UIImage()
    var customTitleView : UIView = UIView()
    
    
    @IBOutlet weak var tweetTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.initializeNavBar()
        subHeaderHeight += self.calcHeightOfDescriptionLabel(descriptionText)
        
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
        
        constraint = NSLayoutConstraint(item: avatarImageView, attribute: .Bottom, relatedBy: .Equal, toItem: subHeaderView, attribute: .Bottom, multiplier: 1.0, constant: 46.0 - subHeaderHeight)
        constraint.priority = 801
        
        self.view.addConstraint(constraint)
 
        // == Generate blurred image and store it into cache, in background thread so wont obstruct UI
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.generateBlurredImageCache()
        })
        
        self.customTitleView = self.createTitleView()
        
        /*
        let tmpView = UIView(frame: CGRectMake(0, 0, 300, 30))
        tmpView.backgroundColor = UIColor.greenColor()
        
        
        self.navigationItem.titleView = self.customTitleView
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.clipsToBounds = true
         */
 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Scroll view delegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let yPos = scrollView.contentOffset.y
        
        
        print("scrollview content offset y is \(yPos)")
        // after scroll past this offset, the cover image will start to blur
        // scroll down (more tweets)
        let blurStartOffset : CGFloat = headerTriggerOffset + 32.0
        let blurRange : CGFloat = 60.0
        
        // after scroll past this offset, the cover image will start to blur
        // scroll up (pull to refresh)
        let negativeBlurStartOffset : CGFloat = -(systemStatusBarHeight + systemNavBarHeight + 10.0)
        let negativeBlurRange : CGFloat = 40.0
        
        if(yPos > headerTriggerOffset && !self.isBarCollapsed){
            self.switchToMinifiedHeader()
            self.isBarCollapsed = true
        }else if(yPos < headerTriggerOffset && isBarCollapsed){
            self.switchToExpandedHeader()
            self.isBarCollapsed = false
        }
        
        if(yPos > blurStartOffset   && yPos <= blurStartOffset + blurRange) {
            
            // how much height has scrolled beyond the header trigger
            let delta : CGFloat = yPos - blurStartOffset
            
            // adjust navigation bar vertical position
            self.navigationController?.navigationBar.setTitleVerticalPositionAdjustment((blurRange - delta), forBarMetrics: .Default)
            
            self.coverImageHeaderView.image = self.blurredImageAt(delta/blurRange)
        }
        
        if(!isBarAnimationComplete && yPos > blurStartOffset + blurRange) {
            self.navigationController?.navigationBar.setTitleVerticalPositionAdjustment(0, forBarMetrics: .Default)
            self.coverImageHeaderView.image = self.blurredImageAt(1.0)
            self.isBarAnimationComplete = true
        }
        
        
        if(yPos < negativeBlurStartOffset && yPos >= negativeBlurStartOffset - negativeBlurRange) {
            // how much height has scrolled beyond the header trigger
            
            // negativeBlurStartOffset = - 64
            // ypos = -74
            // negativeBlurRange = 30
            
            let delta : CGFloat = negativeBlurStartOffset - yPos
            self.coverImageHeaderView.image = self.blurredImageAt(delta/negativeBlurRange)
        }
        
        if(yPos < negativeBlurStartOffset - negativeBlurRange) {
            self.coverImageHeaderView.image = self.blurredImageAt(1.0)
        }
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
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView : UIView = UIView()
        sectionView.backgroundColor = UIColor.whiteColor()
        
        let items = ["Tweets", "Media", "Likes"]
        
        let segmentedControl : UISegmentedControl = UISegmentedControl(items: items)
        segmentedControl.tintColor = twitterBlueColor
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        
        let separatorView : UIView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = UIColor.lightGrayColor()
        
        sectionView.addSubview(segmentedControl)
        sectionView.addSubview(separatorView)
        
        let views = ["super" : self.view,
                     "segmentedControlView" : segmentedControl,
                     "separatorView" : separatorView]
        
        var format = ""
        var constraints = []
        var constraint : NSLayoutConstraint = NSLayoutConstraint()
        
        // horizontal and vertical center the segmented control
        
        format = "|-[segmentedControlView]-|"
        constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        sectionView.addConstraints(constraints as! [NSLayoutConstraint])
        
        
        constraint = NSLayoutConstraint(item: segmentedControl, attribute: .CenterY, relatedBy: .Equal, toItem: sectionView, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        sectionView.addConstraint(constraint)
        
        // let separator width equal super view width, and set it to align bottom
        format = "|-0-[separatorView]-0-|"
        constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        sectionView.addConstraints(constraints as! [NSLayoutConstraint])
        
        format = "V:[separatorView(0.5)]-0-|"
        constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        sectionView.addConstraints(constraints as! [NSLayoutConstraint])
        
        return sectionView
    }
    
    //MARK: - View Controller's graphic related function
    func createSubHeaderView() -> UIView {
        let view : UIView = UIView()
        
        let iconSize : Int = 12
        
        let followButton = UIButton(type: .RoundedRect)
        followButton.translatesAutoresizingMaskIntoConstraints = false
        followButton.setTitle("  Edit Profile  ", forState: .Normal)
        followButton.layer.cornerRadius = 4
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor.grayColor().CGColor
        followButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
        followButton.titleLabel?.font = UIFont.systemFontOfSize(11.0, weight: UIFontWeightMedium)
        
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Asriel Dreemurr"
        nameLabel.numberOfLines = 1
        nameLabel.font = UIFont.boldSystemFontOfSize(16.0)
        nameLabel.textAlignment = .Left
        
        let handleLabel = UILabel()
        handleLabel.translatesAutoresizingMaskIntoConstraints = false
        handleLabel.text = "@asriel"
        handleLabel.numberOfLines = 1
        handleLabel.font = UIFont.systemFontOfSize(12.0)
        handleLabel.textColor = UIColor.grayColor()
        handleLabel.textAlignment = .Left
        
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = descriptionText
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont.systemFontOfSize(13.0)
        descriptionLabel.textAlignment = .Left
        
        let locationIcon = UIImageView(image: UIImage(named: "Location"))
        locationIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let locationLabel = UILabel()
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.text = "The New Home"
        locationLabel.numberOfLines = 1
        locationLabel.font = UIFont.systemFontOfSize(13.0)
        locationLabel.textColor = UIColor.grayColor()
        locationLabel.textAlignment = .Left
        
        let linkIcon = UIImageView(image: UIImage(named: "Link"))
        linkIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let linkButton = UIButton(type: .System)
        linkButton.translatesAutoresizingMaskIntoConstraints = false
        linkButton.setTitle("asriel.xyz", forState: .Normal)
        linkButton.setTitleColor(twitterBlueColor, forState: .Normal)
        linkButton.titleLabel?.font = UIFont.systemFontOfSize(13.0)
        linkButton.titleLabel?.textAlignment = .Left
        linkButton.addTarget(self, action: #selector(linkButtonTapped), forControlEvents: .TouchUpInside)
        
        let followingLabel = UILabel()
        followingLabel.translatesAutoresizingMaskIntoConstraints = false
        followingLabel.numberOfLines = 1
        
        let followingString = NSMutableAttributedString(string: "24", attributes: [NSFontAttributeName : UIFont.boldSystemFontOfSize(12.0), NSForegroundColorAttributeName : UIColor.blackColor()])
        
        let followingConst = NSMutableAttributedString(string: " FOLLOWING", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(11.0), NSForegroundColorAttributeName : UIColor.grayColor()])
        
        followingString.appendAttributedString(followingConst)
        
        followingLabel.attributedText = followingString
        
        let followerLabel = UILabel()
        followerLabel.translatesAutoresizingMaskIntoConstraints = false
        followerLabel.numberOfLines = 1
        
        let followerString = NSMutableAttributedString(string: "1.2M", attributes: [NSFontAttributeName : UIFont.boldSystemFontOfSize(12.0), NSForegroundColorAttributeName : UIColor.blackColor()])
        
        let followerConst = NSMutableAttributedString(string: " FOLLOWERS", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(11.0), NSForegroundColorAttributeName : UIColor.grayColor()])
        
        followerString.appendAttributedString(followerConst)
        
        followerLabel.attributedText = followerString
        
        
        
        view.addSubview(followButton)
        view.addSubview(nameLabel)
        view.addSubview(handleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(locationIcon)
        view.addSubview(locationLabel)
        view.addSubview(linkIcon)
        view.addSubview(linkButton)
        view.addSubview(followingLabel)
        view.addSubview(followerLabel)
        
        let views = ["super" : self.view,
                     "followButton" : followButton,
                     "nameLabel" : nameLabel,
                     "handleLabel" : handleLabel,
                     "descriptionLabel": descriptionLabel,
                     "locationIcon": locationIcon,
                     "locationLabel": locationLabel,
                     "linkIcon": linkIcon,
                     "linkButton": linkButton,
                     "followingLabel": followingLabel,
                     "followerLabel": followerLabel]
        
        var constraint = NSLayoutConstraint()
        var constraints = []
        var format = ""
        
        format = "[followButton]-8-|"
        constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        view.addConstraints(constraints as! [NSLayoutConstraint])
        
        format = "|-8-[nameLabel]-8-|"
        constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        view.addConstraints(constraints as! [NSLayoutConstraint])
        
        format = "|-8-[handleLabel]-8-|"
        constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        view.addConstraints(constraints as! [NSLayoutConstraint])
        
        format = "|-8-[descriptionLabel]-8-|"
        constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        view.addConstraints(constraints as! [NSLayoutConstraint])
        
        format = "|-10-[locationIcon(\(iconSize))]-6-[locationLabel]"
        constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        view.addConstraints(constraints as! [NSLayoutConstraint])
        
        constraint = NSLayoutConstraint(item: locationLabel, attribute: .CenterY, relatedBy: .Equal, toItem: locationIcon, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        view.addConstraint(constraint)
        
        format = "|-10-[linkIcon(\(iconSize))]"
        constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        view.addConstraints(constraints as! [NSLayoutConstraint])
        
        constraint = NSLayoutConstraint(item: linkButton, attribute: .Leading, relatedBy: .Equal, toItem: linkIcon, attribute: .Trailing, multiplier: 1.0, constant: 6.0)
        view.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item: linkButton, attribute: .CenterY, relatedBy: .Equal, toItem: linkIcon, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        view.addConstraint(constraint)
        
        format = "|-8-[followingLabel]"
        constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        view.addConstraints(constraints as! [NSLayoutConstraint])
        
        constraint = NSLayoutConstraint(item: followerLabel, attribute: .CenterY, relatedBy: .Equal, toItem: followingLabel, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        view.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item: followerLabel, attribute: .Leading, relatedBy: .Equal, toItem: followingLabel, attribute: .Trailing, multiplier: 1.0, constant: 20.0)
        view.addConstraint(constraint)
        
        format = "V:|-[followButton]"
        constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        view.addConstraints(constraints as! [NSLayoutConstraint])
        
        format = "V:|-54-[nameLabel]-2-[handleLabel]-4-[descriptionLabel]-10-[locationIcon(\(iconSize))]-10-[linkIcon(\(iconSize))]-10-[followingLabel]";
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
        
        //wrapperView.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.addSubview(handleLabel)
        wrapperView.addSubview(tweetCountLabel)
        
        
        let views = ["handleLabel" : handleLabel,
                     "tweetCountLabel" : tweetCountLabel,
                     "super" : wrapperView]
        var constraints = []
        var format = ""
        
        
        format = "|-0-[handleLabel]-0-|"
        constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        wrapperView.addConstraints(constraints as! [NSLayoutConstraint])
        
        format = "|-0-[tweetCountLabel]-0-|"
        constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        wrapperView.addConstraints(constraints as! [NSLayoutConstraint])
        
        format = "V:|-0-[handleLabel]-2-[tweetCountLabel]-0-|"
        constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        wrapperView.addConstraints(constraints as! [NSLayoutConstraint])
        
        // set wrapperView frame size, else navbar will treat it as 0 height 0 width
        wrapperView.frame = CGRectMake(0, 0, max(handleLabel.intrinsicContentSize().width, tweetCountLabel.intrinsicContentSize().width), handleLabel.intrinsicContentSize().height + 2 + tweetCountLabel.intrinsicContentSize().height)
        
        wrapperView.clipsToBounds = true
        print("wrapper view height is \(wrapperView.frame.size.height)")
        print("wrapper view width is \(wrapperView.frame.size.width)")
        //self.customTitleView = wrapperView
        
        return wrapperView
    }
    
    func calcHeightOfDescriptionLabel(descriptionText: String) -> CGFloat {
        // |-8-[descriptionLabel-8-|
        return descriptionText.heightWithConstrainedWidth(self.view.frame.size.width - 16.0, font: UIFont.systemFontOfSize(13.0))
    }
    
    // MARK: - Controller private action
    func linkButtonTapped(sender:UIButton!) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://asriel.xyz")!)
        print("link button tapped!")
    }
    
    // MARK: - Navigation bar customization
    
    func initializeNavBar() {
        self.view.backgroundColor = UIColor.greenColor()
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barStyle = .BlackTranslucent
        self.navigationController?.navigationBar.translucent = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: nil)
        
        self.switchToExpandedHeader()
        
    }
    
    func switchToExpandedHeader() {
        print("switching to expanded header")
        
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
        
        print("switching to minified header")
        self.isBarAnimationComplete = false
        self.navigationItem.titleView = self.customTitleView
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.clipsToBounds = true
        //self.createTitleView()
        
        
        
        //Setting the view transform or changing frame origin has no effect, only this call does
        self.navigationController?.navigationBar.setTitleVerticalPositionAdjustment(60.0, forBarMetrics: .Default)
        
        
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
    
    
    // MARK: - Blur effects on image
    
    func blurredImageOf(image: UIImage, withRadius radius: CGFloat) -> UIImage {
        return UIImageEffects.imageByApplyingBlurToImage(image, withRadius: radius, tintColor: UIColor.whiteColor().colorWithAlphaComponent(0.2), saturationDeltaFactor: 1.5, maskImage: nil)
    }
    
    func blurredImageAt(percent: CGFloat) -> UIImage{
        
        //percent is between 0 to 1
        var keyNumber : Int = 0
        
        keyNumber = Int(floor(Double(percent) * 10))
        
        //print("using blur image at key \(keyNumber)")
        
        let image = self.blurredImageCache.objectForKey(String(keyNumber)) as? UIImage
        
        // return original image if cache haven't generate finish
        if(image == nil){
            return self.originalBackgroundImage
        }
        
        return image!
    }
    
    func generateBlurredImageCache() {
        let maxBlurRadius : CGFloat = 30.0
        self.blurredImageCache = NSMutableDictionary()
        
        for i in 1...10 {
            //print("generating image cache of \(i)")
            self.blurredImageCache.setValue(self.blurredImageOf(self.originalBackgroundImage, withRadius: (maxBlurRadius * CGFloat(i)/10.0)), forKey: String(i))
        }
        
        
    }
    
}

