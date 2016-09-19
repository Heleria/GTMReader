//
//  Based on 'GTMRelated.swift' from 'Climb Crusher', created by Jacob Henning Rothschild on 20/03/2016, Copyright © 2016 Jacob Henning Rothschild. All rights reserved.
//
//  This remake was created by Jacob Henning Rothschild on 27/06/2016
//  Copyright © 2016 Jacob Henning Rothschild. All rights reserved.
//

import Foundation

private let TAG = "GTM_Related"
var GTM: TAGManager!, GTM_CONTAINER: TAGContainer!, CONTAINER_ID: String!

// INFO: CGSize is the only of the values we wish to support that doesn't conform to protocal AnyObject. Instead it requires that we expand to Any. The casts Any as! [Any] and [Any] as! T both fail, making Any useless in the case of readArray and readDictionary. AnyObject, on the other hand, doesn't have any of these problems, and works just fine. We seldom use harcoded CGSizes and thus it has been decided to support CGSize-variables in GTM, but not CGSizes in collection types.

// TODO Turn into CocoaPods-library and post on GitHub under MIT-license

private let stringColors = ["RED" : UIColor.redColor(), "ORANGE" : UIColor.orangeColor(), "GREEN" : UIColor.greenColor(), "BLUE" : UIColor.blueColor(), "CYAN" : UIColor.cyanColor(), "YELLOW" : UIColor.yellowColor(), "MAGENTA" : UIColor.magentaColor(), "PURPLE" : UIColor.purpleColor(), "BROWN" : UIColor.brownColor(), "CLEAR" : UIColor.clearColor(), "WHITE" : UIColor.whiteColor(), "LIGHT_GRAY" : UIColor.lightGrayColor(), "GRAY" : UIColor.grayColor(), "DARK_GRAY" : UIColor.darkGrayColor(), "BLACK" : UIColor.blackColor(), "LIGHT_TEXT" : UIColor.lightTextColor(), "DARK_TEXT" : UIColor.darkTextColor(), "GROUP_TABLE_VIEW_BACKGROUND" : UIColor.groupTableViewBackgroundColor()]
private var gtmCache = [String : Any](), cacheable = false

/// The type a value within a collection type is
private enum ValueType : String {
    case STRING = "STRING", INT = "INT", DOUBLE = "DOUBLE", FLOAT = "FLOAT", COLOR = "COLOR", SIZE = "SIZE", ARRAY = "ARRAY", DICTIONARY = "DICTIONARY"
}

/// Sets gtmCache[key] = value and returns value
private func putAndGet<T>(key: String, value: T) -> T {
    if cacheable {
        gtmCache[key] = value as? NSObject
    }
    return value
}

extension String {
    /// The value stored in 'GTM_CONTAINER' where key is 'self'
    public func gtm<T>() -> T { return value(self) }
    /// The String stored in 'GTM_CONTAINER' where key is 'self'
    public var string: String { return value(self) }
    /// The Int stored in 'GTM_CONTAINER' where key is 'self'
    public var int: Int { return value(self) }
    /// The Double stored in 'GTM_CONTAINER' where key is 'self'
    public var double: Double { return value(self) }
    /// The CGFloat stored in 'GTM_CONTAINER' where key is 'self'
    public var float: CGFloat { return value(self) }
    /// The UIColor stored in 'GTM_CONTAINER' where key is 'self'
    public var color: UIColor { return value(self) }
    /// The CGSize stored in 'GTM_CONTAINER' where key is 'self'
    public var size: CGSize { return value(self) }
    /// The array stored in 'GTM_CONTAINER' where key is 'self'
    public var array: [AnyObject] { return value(self) }
    /// The dictionary stored in 'GTM_CONTAINER' where key is 'self'
    public var dictionary: [String : AnyObject] { return value(self) }
}

/// - Returns: A String from GTM or from cache if read before. Thus performance cost of this function ≈0
public func string(key: String) -> String { return value(key) }
/// - Returns: An Int from GTM or from cache if read before. Thus performance cost of this function ≈0
public func int(key: String) -> Int { return value(key) }
/// - Returns: A Double from GTM or from cache if read before. Thus performance cost of this function ≈0
public func double(key: String) -> Double { return value(key) }
/// - Returns: A CGFloat from GTM or from cache if read before. Thus performance cost of this function ≈0
public func float(key: String) -> CGFloat { return value(key) }
/// - Returns: A UIColor object from GTM or from cache if read before. Thus performance cost of this function ≈0
public func color(key: String) -> UIColor { return value(key) }
/// - Returns: A CGSize object from GTM or from cache if read before. Thus performance cost of this function ≈0
public func size(key: String) -> CGSize { return value(key) }
/// - Returns: An array of Any (allows for all arrays) from GTM or from cache if read before. Thus performance cost of this function ≈0
public func array<T>(key: String) -> T { return value(key) }
/// - Returns: An array of Any (allows for all arrays) from GTM or from cache if read before. Thus performance cost of this function ≈0
public func dictionary<T>(key: String) -> T { return value(key) }

/// - Returns: A value of type 'type' or T from GTM or from cache if read before. Thus performance cost of this function ≈0
public func value<T>(key: String) -> T {
    return (gtmCache[key] ?? putAndGet(key, value: valueForKey(key))) as! T
}

/// - Returns: The value that is stored behind 'key'
private func valueForKey(key: String) -> Any {
    return valueForKey(key, type: typeForKey(key))
}

/// - Returns: The 'ValueType' of the value behind 'key'
private func typeForKey(key: String) -> ValueType {
    return ValueType(rawValue: GTM_CONTAINER.stringForKey("\(key)|type"))!
}

/// - Returns: The correct output through handling 'key' based on 'type'
private func valueForKey(key: String, type: ValueType) -> Any {
    switch (type) {
    case .STRING: return GTM_CONTAINER.stringForKey(key)
    case .INT: return Int(GTM_CONTAINER.stringForKey(key))!
    case .DOUBLE: return GTM_CONTAINER.doubleForKey(key)
    case .FLOAT: return CGFloat(GTM_CONTAINER.doubleForKey(key))
    case .COLOR: return stringToColor(GTM_CONTAINER.stringForKey(key))
    case .SIZE: return stringToSize(GTM_CONTAINER.stringForKey(key))
    case .ARRAY: return readArray(key)
    case .DICTIONARY: return readDictionary(key)
    }
}

/// Reads a UIColor from GTM
private func readColor(key: String) -> UIColor {
    return stringToColor(GTM_CONTAINER.stringForKey(key))
}

/// Reads a CGSize from GTM
private func readSize(key: String) -> CGSize {
    return stringToSize(GTM_CONTAINER.stringForKey(key))
}

/// - Returns: UIColor created from a recipe in the form of a string
private func stringToColor(input: String) -> UIColor {
    if input.containsString("#") {
        let colorHex = UInt32(input.substringFromIndex(input.startIndex.advancedBy(1)), radix: 16)!
        // colorHex << 8 Moves RGB into their positions RGBA, UInt32(0xff) adds opaque alpha component
        return UIColor(netHex: input.characters.count == 7 ? colorHex << 8 + UInt32(0xff) : colorHex)
    } else {
        return stringColors[input] ?? UIColor.clearColor()
    }
}

/// - Returns: CGSize created from a recipe in the form of a string
private func stringToSize(input: String) -> CGSize {
    let components = input.componentsSeparatedByString(",")
    return CGSizeMake(stringToCGFloat(components[0]), stringToCGFloat(components[1]))
}

/// - Returns: 'input' converted to CGFloat
private func stringToCGFloat(input: String) -> CGFloat {
    return CGFloat(Double(input)!)
}

/// Reads an array from GTM
/// - Returns: AnyObject instead of [AnyObject] because it is required for cast to T to work (at least when T is [[String]])
private func readArray(key: String) -> AnyObject {
    var output = [AnyObject]()
    for i: Int64 in 0 ..< GTM_CONTAINER.int64ForKey(key) {
        output.append(collectionValueForKey("\(key),\(i)"))
    }
    return output
}

/// Reads a dictionary from GTM
private func readDictionary(key: String) -> AnyObject {
    var output = [String : AnyObject]()
    // Don't worry, testing shows this only calls 'readArray()' once
    for dictionaryKey in (readArray("\(key):KEYS") as! [String]) {
        output[dictionaryKey] = collectionValueForKey("\(key);\(dictionaryKey)")
    }
    return output
}

/// - Returns: The correct output through handling 'key' based on 'type' so long as 'type' != .SIZE where it will throw assertion
private func collectionValueForKey(key: String) -> AnyObject {
    if let value = valueForKey(key) as? AnyObject {
        return value
    }
    assertionFailure("\(TAG):\(#function)| Tried putting CGSize in collection type. This is not possible because it doesn't conform to AnyObject")
    return ""
}

/// Sets 'GTM_CONTAINER' which will be used for all later calls. 'GTM_CONTAINER = gtmContainer'
public func setGTMContainer(gtmContainer: TAGContainer) {
    GTM_CONTAINER = gtmContainer
}

/// Sets 'GTM_CONTAINER' which will be used for all later calls. 'GTM_CONTAINER = gtmContainer'
public func setGTMContainer(tagManager: TAGManager) {
    GTM_CONTAINER = tagManager.getContainerById(CONTAINER_ID)
}

public class GTMManager : NSObject, TAGContainerOpenerNotifier {
    static let sharedInstance = GTMManager()
    private let TAG = "GTMManager."
    
    // NOTE: Before calling TAGContainerOpener.openContainerWithId() no container is available. Synchronically right after calling this method the default container is available. When containerAvailable() is reached/called the default container has been replaced with the server version.
    
    /// Gets GTM instance, configures GTM logger and launches GTM key-value pairs container retrieval from server
    /// - Parameter containerId: The id of the Google Tag Manager container we will be using
    public func launchGTM(containerId: String) {
        CONTAINER_ID = containerId
        GTM = TAGManager.instance()
        // Starts process of attempting to download value collection from GTM server
        TAGContainerOpener.openContainerWithId(CONTAINER_ID, tagManager: GTM, openType: kTAGOpenTypePreferFresh, timeout: nil, notifier: self)
        collectGTMContainer()
    }
    
    /// Indicates that a non-default container is now available. We call container.refresh() so that in case the container is outdated, it will be updated for next call
    public func containerAvailable(container: TAGContainer!) {
        print("\(TAG)containerAvailable() reached; clearing gtmCache")
        gtmCache.removeAll()
        cacheable = true
        container.refresh()
        collectGTMContainer()
    }
    
    /// Sets 'GTM_CONTAINER' to 'GTM.getContainerById(CONTAINER_ID)'
    private func collectGTMContainer() {
        GTM_CONTAINER = GTM.getContainerById(CONTAINER_ID)
    }
}

private extension UIColor {
    /// Creates a new rgba UIColor object from an rgba (NOTE: rgba, NOT argb like in Android) hex. This is convenient, because rgba is easier for DictionaryMigrator to create, and is thus how UIColors will be stored in GTM
    convenience init(netHex: UInt32) {
        // See https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/AdvancedOperators.html for explanation
        self.init(red: CGFloat((netHex >> 24) & 0xff) / 255, green: CGFloat((netHex >> 16) & 0xff) / 255, blue: CGFloat((netHex >> 8) & 0xff) / 255, alpha: CGFloat(netHex & 0xff) / 255)
    }
}
