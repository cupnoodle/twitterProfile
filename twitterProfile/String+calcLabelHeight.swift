//
//  String+calcLabelHeight.swift
//  twitterProfile
//
//  Created by Soul on 13/06/2016.
//  Copyright © 2016 Sweatshop. All rights reserved.
//

import Foundation

extension String {
    
    //http://stackoverflow.com/questions/30450434/figure-out-size-of-uilabel-based-on-string-in-swift
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.max)
        
        let boundingBox = self.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
}