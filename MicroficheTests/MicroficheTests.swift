import UIKit
import XCTest
import Microfiche

/// Person Struct will be an example Immutable Data Structure we want to archive
struct Person {
    let name: String
    let age: Int
}

private struct Archive {
    static var path: String? {
        let documentsDirectories = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true) as? [String]
        let documentDirectory = documentsDirectories?.first
        if let dir = documentDirectory {
            let documentPath = dir + "/items.archive"
            return documentPath
        }
        return nil
    }
}

// Person needs to be equatable in order to be used in a Set
extension Person: Equatable {}
func ==(rhs: Person, lhs: Person) -> Bool{
    return (rhs.name == lhs.name) && (rhs.age == lhs.age)
}
// Person Must be hashable to be used in a set
extension Person : Hashable {
    var hashValue: Int {
        return self.name.hashValue
    }
}


class microficheTests: XCTestCase {

    func testArrayArchiveAndRestore() {
        // Create and Array for archiving
        let me = Person(name: "John", age: 30)
        let shelby = Person(name: "Shelby", age: 31)
        let people = [me, shelby]
        // Archive the Collection, In this case an Array<People>
        let arrayArchive = NSKeyedArchiver.archivedDataWithRootObject(convertCollectionToArrayOfData(people))

        // Restore the data from the archive, Note the required cast to NSMutableArray
        let arayUnarchive = NSKeyedUnarchiver.unarchiveObjectWithData(arrayArchive) as? NSMutableArray

        // Finally take the Restored NSMutableArray, and convert it back to our preferred Data type
        // NOTE: The cast is required! Without this the Type Inference Engine will not know what type
        // of object should be returned to you
        let restoredArray = restoreFromArchiveArray(arayUnarchive!) as Array<Person>
        XCTAssert(restoredArray == people, "Restored Array is equal to the Source Data")
    }

    func testDictionaryArchiveAndRestore(){

        let me = Person(name: "John", age: 30)
        let shelby = Person(name: "Shelby", age: 31)
        let dictionaryPeeps: Dictionary<NSUUID, Person> = [NSUUID(): me, NSUUID(): shelby]

        let dictionaryArchive = NSKeyedArchiver.archivedDataWithRootObject(convertCollectionToArrayOfData(dictionaryPeeps))

        let dictionaryUnarchive = NSKeyedUnarchiver.unarchiveObjectWithData(dictionaryArchive) as? NSMutableArray
        let restoredDictionary = restoreFromArchiveArray(dictionaryUnarchive!) as Dictionary<NSUUID, Person>
        XCTAssert(restoredDictionary == dictionaryPeeps, "Restored Set is equal to the Source Data")
    }

    func testArchiveCollectionAtPath(){
        let me = Person(name: "John", age: 30)
        let shelby = Person(name: "Shelby", age: 31)
        let people = [me, shelby]
        if let path = Archive.path {
            println("Got a good archivePath: \(path)")
            let result = archiveCollection(people, atPath: path)
            XCTAssert(result == true, "Collection people was sucessfully archived")

            let collection: Array<Person>? = restoreCollectionFromPath(path)
            XCTAssert(collection! == people, "Collection People was successfully restored")

        }
    }
    func testRestoreFromPathWhereNoDataHasBeenSaved(){
        let collection: Array<Person>? = restoreCollectionFromPath("someInvalidPath")
        XCTAssert(collection == nil, "restoringCollectionfromPath returns nil")
    }

}