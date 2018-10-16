import Foundation
import UIKit
import CoreData

/// In order for NSPersistentContainer to find our model (which isn't) in
/// the `MainBundle`, we must subclass it.
public class PickColorPersistentContainer: NSPersistentContainer {

    override public class func defaultDirectoryURL() -> URL {
        let url = super.defaultDirectoryURL().appendingPathComponent("PickColor")
        if !FileManager.default.fileExists(atPath: url.absoluteString) {
            try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: [:])
        }
        print("db location=\(url.absoluteString)")
        return url
    }

}

struct Persistance {

    public static func save(color: UIColor) {
        container.performBackgroundTask { ctx in
            let insertedColor = NSEntityDescription.insertNewObject(forEntityName: Color.self.description(), into: ctx) as! Color
            insertedColor.lastUsed = Date() as NSDate
            insertedColor.red = Float(color.red)
            insertedColor.green = Float(color.green)
            insertedColor.blue = Float(color.blue)

            do {
                try ctx.save()
                print("Saved => \(insertedColor)")
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }

    public static var container: PickColorPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = PickColorPersistentContainer(name: "PickColorModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

}
