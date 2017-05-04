//
//  DictionayTransformer.swift
//  Unova
//
//  Created by iosdev on 04/05/17.
//  Copyright © 2017 Unova. All rights reserved.
//

import Foundation

class DictionaryTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        
        return NSKeyedUnarchiver.unarchiveObject(with: data)
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let dictionary = value as? NSDictionary else { return nil }
        
        return NSKeyedArchiver.archivedData(withRootObject: dictionary)
    }

}
