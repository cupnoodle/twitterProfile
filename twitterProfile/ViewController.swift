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
    let avatarImageSize : CGFloat = 64.0
    let avatarImageShrinkedSize : CGFloat = 44.0
    
    var systemStatusBarHeight : CGFloat = 0.0
    var systemNavBarHeight : CGFloat = 0.0
    
    var headerTriggerOffset : CGFloat = 0.0
    
    let isBarCollapsed = false
    let isBarAnimationComplete = false
    
    var coverImageHeaderView : UIImageView = UIImageView()
    
    @IBOutlet weak var tweetTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        systemStatusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        systemNavBarHeight = self.navigationController!.navigationBar.frame.height
        
        // minus the component in bracket to compensate the adjusted scroll inset
        headerTriggerOffset = headerHeight - (systemStatusBarHeight + systemNavBarHeight) - systemStatusBarHeight - systemNavBarHeight
        
        self.tweetTable.dataSource = self
        self.tweetTable.delegate = self
        self.tweetTable.translatesAutoresizingMaskIntoConstraints = false
        
        // minus the component in bracket to compensate the adjusted scroll inset
        self.tweetTable.tableHeaderView?.frame = CGRectMake(0, 0, self.view.frame.size.width, headerHeight - (systemNavBarHeight + systemStatusBarHeight) + subHeaderHeight)
        
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
         * 1 : headerImageView
         * 2 : avatarImageView
         */
        
        self.automaticallyAdjustsScrollViewInsets = true
        
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
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
}

