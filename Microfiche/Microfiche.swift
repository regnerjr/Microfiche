//
//  Microfiche.swift
//  Microfiche is an set of functions usable in Swift for
//  archiving Array<T> and Dictionary<T,U>
//
//  Created by John Regner on 3/13/15.
//

import Foundation

/// Archives a Swift Collection to a given path.
///
/// :param: collection A Swift Collection (Array<T>, Dictionary<T,U>)
/// :param: atPath A valid path hopefully in the app sandbox
///
/// :returns: true if the operation was successful, false if not
///
public func archiveCollection<T: CollectionType>(collection: T, atPath path: String) -> Bool {
    let dataArray = convertCollectionToArrayOfData(collection)
    println("DataArray: \(dataArray)")
    let result = NSKeyedArchiver.archiveRootObject(dataArray, toFile: path)
    println("Result: \(result)")
    return result
}

/// Restores a Collection which has been previously archived at a given path
///
/// Note this method is overloaded on the return type, and uses return type type inference, be sure to assign the result to the correctly shaped collection
///
/// :param: path A path which points to an archive
///
/// :returns: A collection of objects, or nil if an error occurs
///
public func restoreCollectionFromPath<T>(path: String) -> Array<T>?{
    let data = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as! NSMutableArray?
    switch data {
    case .Some(let theData): return restoreFromArchiveArray(theData)
    case .None: return nil
    }
}

/// Restores a Collection which has been previously archived at a given path
///
/// Note this method is overloaded on the return type, and uses return type type inference, be sure to assign the result to the correctly shaped collection
/// 
/// :param: path A path which points to an archive
/// 
/// :returns: A collection of objects, or nil if an error occurs
/// 
public func restoreCollectionFromPath<T,U>(path: String) -> Dictionary<T,U>?{
    let data = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as! NSMutableArray?
    switch data {
    case .Some(let theData): return restoreFromArchiveArray(theData)
    case .None: return nil
    }
}

/// Restores a Collection which has been previously archived at a given path
///
/// Note this method is overloaded on the return type, and uses return type type inference, be sure to assign the result to the correctly shaped collection
///
/// :param: path A path which points to an archive
///
/// :returns: A collection of objects, or nil if an error occurs
///
public func restoreCollectionFromPath<T>(path: String) -> Set<T>?{
    let data = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as! NSMutableArray?
    switch data {
    case .Some(let theData): return restoreFromArchiveArray(theData)
    case .None: return nil
    }
}

/// Pass in your Swift Collection before Archiving. This function returns an object which is suitable for NSKeyedArchiving
///
/// Converts input Collection<T> into an NSMutableArray<NSData> works with Array<T> and Dictionary<T,U>
///
/// :param: collection Any Swift Collection Type
///
/// :returns: An NSMutableArray suitable for passing on to your archiver
///
public func convertCollectionToArrayOfData<T: CollectionType>(collection: T) -> NSMutableArray {
    return NSMutableArray(array: map(collection){
        var mutableItem = $0
        return NSData(bytes: &mutableItem, length: sizeof(T.Generator.Element.self))
        })
}

/// This function takes an archive (NSMutableArray) which you will get back from an NSKeyedUnarchiver
///
/// :param: array An NSMutableArray, returned by the NSKeyedUnarchiver
///
/// :returns: An Array of your given type. The data that was originally archived
///
public func restoreFromArchiveArray<T>( array: NSMutableArray) -> Array<T>{
    return Array<T>( map( array ) { memoryOfType(fromAnyObject: $0) } )
}

/// This function takes an archive (NSMutableArray) which you will get back from an NSKeyedUnarchiver
///
/// :param: array An NSMutableArray, returned by the NSKeyedUnarchiver
///
/// :returns: An Set of your given type. The data that was originally archived
///
public func restoreFromArchiveArray<T>(array: NSMutableArray) -> Set<T> {
    return Set<T>( map( array ) { memoryOfType(fromAnyObject: $0) } as [T] )
}

/// This function takes an archive (NSMutableArray) which you will get back from an NSKeyedUnarchiver
///
/// :param: array An NSMutableArray, returned by the NSKeyedUnarchiver
///
/// :returns: A Dictionary of your given type. The data that was originally archived
///
public func restoreFromArchiveArray<T,U>(array: NSMutableArray) -> Dictionary<T,U>{
    var results = Dictionary<T,U>()
    map(array){ item -> Void in
        let (k,v): (T,U)  = memoryOfType(fromAnyObject: item)
        results[k] = v
    }
    return results
}

/// This is a helper function. You probably should not be calling this
///
/// But if you do want to call it, pleas note that the Type T
/// which all the sizes and Pointer types use is inferred from the return type
/// You may need to explicitly declare a return type when using this.
/// see `restoreDictFromArchiveArray` for an example
///
private func memoryOfType<T>(fromAnyObject obj: AnyObject) -> T {
    let mutableData = obj as! NSData
    var itemData = UnsafeMutablePointer<T>.alloc(sizeof(T))
    mutableData.getBytes(itemData, length: sizeof(T))
    return itemData.memory
}
