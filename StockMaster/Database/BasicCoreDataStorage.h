//
//  BasicCoreDataStorage.h
//  StockMaster
//
//  Created by Johnny on 15/4/7.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface BasicCoreDataStorage : NSObject {
@private
    NSManagedObjectModel *managedObjectModel;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectContext *rootWriteManagedObjectContext;
    NSManagedObjectContext *mainThreadManagedObjectContext;
    NSManagedObjectContext *executeManagedObjectContext;
    NSManagedObjectContext *scheduleManagedObjectContext;
    
    NSMutableArray *willSaveManagedObjectContextBlocks;
    NSMutableArray *didSaveManagedObjectContextBlocks;
    
@protected
    NSString *databaseFileName;
    NSDictionary *storeOptions;
    
    BOOL autoRemovePreviousDatabaseFile;
    BOOL autoRecreateDatabaseFile;
    BOOL autoAllowExternalBinaryDataStorage;
    
    dispatch_queue_t storageQueue;
    void *storageQueueTag;
}

/**
 * If your subclass needs to do anything for init, it can do so easily by overriding this method.
 * All public init methods will invoke this method at the end of their implementation.
 *
 * Important: If overriden you must invoke [super commonInit] at some point.
 **/
- (void)commonInit;

/**
 * Initializes a core data storage instance, backed by SQLite, with the given database store filename.
 * It is recommended your database filname use the "sqlite" file extension (e.g. "XMPPRoster.sqlite").
 * If you pass nil, a default database filename is automatically used.
 * This default is derived from the classname,
 * meaning subclasses will get a default database filename derived from the subclass classname.
 *
 * If you attempt to create an instance of this class with the same databaseFileName as another existing instance,
 * this method will return nil.
 **/
- (id)initWithDatabaseFilename:(NSString *)databaseFileName storeOptions:(NSDictionary *)storeOptions;

/**
 * Initializes a core data storage instance, backed by an in-memory store.
 **/
- (id)initWithInMemoryStore;

/**
 * Override me, if needed, to provide customized behavior.
 *
 * This method is queried to get the name of the ManagedObjectModel within a bundle.
 * It should return the name of the appropriate file (*.xdatamodel / *.mom / *.momd) sans file extension.
 *
 * The default implementation returns the name of the subclass, stripping any suffix of "CoreDataStorage".
 * E.g., if your subclass was named "XMPPExtensionCoreDataStorage", then this method would return "XMPPExtension".
 *
 * Note that a file extension should NOT be included.
 **/
- (NSString *)managedObjectModelName;

/**
 * This method synchronously invokes the given block (performBlockAndWait) on the mainStorageQueue.
 **/
- (void)executeBlock:(void(^)(NSManagedObjectContext *moc))block;

/**
 * This method asynchronously invokes the given block (performBlock) on the mainStorageQueue.
 *
 * It works very similarly to the executeBlock method.
 * See the executeBlock method above for a full discussion.
 **/
- (void)scheduleBlock:(void(^)(NSManagedObjectContext *moc))block;

/**
 * Readonly access to the databaseFileName used during initialization.
 * If nil was passed to the init method, returns the actual databaseFileName being used (the default filename).
 **/
@property (readonly) NSString *databaseFileName;

/**
 * Readonly access to the databaseOptions used during initialization.
 * If nil was passed to the init method, returns the actual databaseOptions being used (the default databaseOptions).
 **/
@property (strong, readonly) NSDictionary *storeOptions;

@property (strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/**
 * Convenience method to get a managedObjectContext appropriate for use on the main thread.
 * This context should only be used from the main thread.
 *
 * NSManagedObjectContext is a light-weight thread-UNsafe component of the CoreData stack.
 * Thus a managedObjectContext should only be accessed from a single thread, or from a serialized queue.
 *
 * A managedObjectContext is associated with a persistent store.
 * In most cases the persistent store is an sqlite database file.
 * So think of a managedObjectContext as a thread-specific cache for the underlying database.
 *
 * This method lazily creates a proper managedObjectContext,
 * associated with the persistent store of this instance,
 * and configured to automatically merge changesets from other threads.
 **/
@property (strong, readonly) NSManagedObjectContext *mainThreadManagedObjectContext;

/**
 * The Previous Database File is removed before creating a persistant store.
 *
 * Default NO
 **/
@property (readwrite) BOOL autoRemovePreviousDatabaseFile;

/**
 * The Database File is automatically recreated if the persistant store cannot read it e.g. the model changed or the file became corrupt.
 * For greater control overide didNotAddPersistentStoreWithPath:
 *
 * Default NO
 **/
@property (readwrite) BOOL autoRecreateDatabaseFile;

/**
 * This method calls setAllowsExternalBinaryDataStorage:YES for all Binary Data Attributes in the Managed Object Model.
 * On OS Versions that do not support external binary data storage, this property does nothing.
 *
 * Default NO
 **/
@property (readwrite) BOOL autoAllowExternalBinaryDataStorage;

@end
