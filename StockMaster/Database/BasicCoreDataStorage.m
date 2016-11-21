//
//  BasicCoreDataStorage.m
//  StockMaster
//
//  Created by Johnny on 15/4/7.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import "BasicCoreDataStorage.h"
#import <objc/runtime.h>

@implementation BasicCoreDataStorage

static NSMutableSet *databaseFileNames;

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        databaseFileNames = [[NSMutableSet alloc] init];
    });
}

+ (BOOL)registerDatabaseFileName:(NSString *)dbFileName
{
    BOOL result = NO;
    
    @synchronized(databaseFileNames)
    {
        if (![databaseFileNames containsObject:dbFileName])
        {
            [databaseFileNames addObject:dbFileName];
            result = YES;
        }
    }
    
    return result;
}

+ (void)unregisterDatabaseFileName:(NSString *)dbFileName
{
    @synchronized(databaseFileNames)
    {
        [databaseFileNames removeObject:dbFileName];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Override Me
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString *)managedObjectModelName
{
    // Override me, if needed, to provide customized behavior.
    //
    // This method is queried to get the name of the ManagedObjectModel within the app bundle.
    // It should return the name of the appropriate file (*.xdatamodel / *.mom / *.momd) sans file extension.
    //
    // The default implementation returns the name of the subclass, stripping any suffix of "CoreDataStorage".
    // E.g., if your subclass was named "XMPPExtensionCoreDataStorage", then this method would return "XMPPExtension".
    //
    // Note that a file extension should NOT be included.
    
    NSString *className = NSStringFromClass([self class]);
    NSString *suffix = @"CoreDataStorage";
    
    if ([className hasSuffix:suffix] && ([className length] > [suffix length]))
    {
        return [className substringToIndex:([className length] - [suffix length])];
    }
    else
    {
        return className;
    }
}

- (NSBundle *)managedObjectModelBundle
{
    return [NSBundle bundleForClass:[self class]];
}

- (NSString *)defaultDatabaseFileName
{
    // Override me, if needed, to provide customized behavior.
    //
    // This method is queried if the initWithDatabaseFileName:storeOptions: method is invoked with a nil parameter for databaseFileName.
    //
    // You are encouraged to use the sqlite file extension.
    
    return [NSString stringWithFormat:@"%@.db", [self managedObjectModelName]];
}

- (NSDictionary *)defaultStoreOptions
{
    
    // Override me, if needed, to provide customized behavior.
    //
    // This method is queried if the initWithDatabaseFileName:storeOptions: method is invoked with a nil parameter for defaultStoreOptions.
    
    NSDictionary *defaultStoreOptions = nil;
    
    if(databaseFileName)
    {
        defaultStoreOptions = @{ NSMigratePersistentStoresAutomaticallyOption: @(YES),
                                 NSInferMappingModelAutomaticallyOption : @(YES) };
    }
    
    return defaultStoreOptions;
}

- (void)willCreatePersistentStoreWithPath:(NSString *)storePath options:(NSDictionary *)theStoreOptions
{
    // Override me, if needed, to provide customized behavior.
    //
    // If you are using a database file with pure non-persistent data (e.g. for memory optimization purposes on iOS),
    // you may want to delete the database file if it already exists on disk.
    //
    // If this instance was created via initWithDatabaseFilename, then the storePath parameter will be non-nil.
    // If this instance was created via initWithInMemoryStore, then the storePath parameter will be nil.
}

- (BOOL)addPersistentStoreWithPath:(NSString *)storePath options:(NSDictionary *)theStoreOptions error:(NSError **)errorPtr
{
    // Override me, if needed, to completely customize the persistent store.
    //
    // Adds the persistent store path to the persistent store coordinator.
    // Returns true if the persistent store is created.
    //
    // If this instance was created via initWithDatabaseFilename, then the storePath parameter will be non-nil.
    // If this instance was created via initWithInMemoryStore, then the storePath parameter will be nil.
    
    NSPersistentStore *persistentStore;
    
    if (storePath)
    {
        // SQLite persistent store
        
        NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
        
        persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                   configuration:nil
                                                                             URL:storeUrl
                                                                         options:storeOptions
                                                                           error:errorPtr];
    }
    else
    {
        // In-Memory persistent store
        
        persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
                                                                   configuration:nil
                                                                             URL:nil
                                                                         options:nil
                                                                           error:errorPtr];
    }
    
    return persistentStore != nil;
}

- (void)didNotAddPersistentStoreWithPath:(NSString *)storePath options:(NSDictionary *)theStoreOptions error:(NSError *)error
{
    // Override me, if needed, to provide customized behavior.
    //
    // For example, if you are using the database for non-persistent data and the model changes,
    // you may want to delete the database file if it already exists on disk.
    //
    // E.g:
    //
    // [[NSFileManager defaultManager] removeItemAtPath:storePath error:NULL];
    // [self addPersistentStoreWithPath:storePath error:NULL];
    //
    // This method is invoked on the storageQueue.
}

- (void)didCreateManagedObjectContext
{
    // Override me to provide customized behavior.
    // For example, you may want to perform cleanup of any non-persistent data before you start using the database.
    //
    // This method is invoked on the storageQueue.
}

- (void)willSaveManagedObjectContext
{
    // Override me if you need to do anything special just before changes are saved to disk.
    //
    // This method is invoked on the storageQueue.
}

- (void)didSaveManagedObjectContext
{
    // Override me if you need to do anything special after changes have been saved to disk.
    //
    // This method is invoked on the storageQueue.
}

- (void)mainThreadManagedObjectContextDidMergeChanges
{
    // Override me if you want to do anything special when changes get propogated to the main thread.
    //
    // This method is invoked on the main thread.
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Setup
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@synthesize databaseFileName;
@synthesize storeOptions;

- (void)commonInit
{
    storageQueue = dispatch_queue_create(class_getName([self class]), NULL);
    
    storageQueueTag = &storageQueueTag;
    dispatch_queue_set_specific(storageQueue, storageQueueTag, storageQueueTag, NULL);
    
    willSaveManagedObjectContextBlocks = [[NSMutableArray alloc] init];
    didSaveManagedObjectContextBlocks = [[NSMutableArray alloc] init];
}

- (id)init
{
    return [self initWithDatabaseFilename:nil storeOptions:nil];
}

- (id)initWithDatabaseFilename:(NSString *)aDatabaseFileName storeOptions:(NSDictionary *)theStoreOptions
{
    if ((self = [super init]))
    {
        if (aDatabaseFileName)
            databaseFileName = [aDatabaseFileName copy];
        else
            databaseFileName = [[self defaultDatabaseFileName] copy];
        
        if(theStoreOptions)
            storeOptions = theStoreOptions;
        else
            storeOptions = [self defaultStoreOptions];
        
        if (![[self class] registerDatabaseFileName:databaseFileName])
        {
            return nil;
        }
        
        [self commonInit];
        NSAssert(storageQueue != NULL, @"Subclass forgot to invoke [super commonInit]");
    }
    return self;
}

- (id)initWithInMemoryStore
{
    if ((self = [super init]))
    {
        [self commonInit];
        NSAssert(storageQueue != NULL, @"Subclass forgot to invoke [super commonInit]");
    }
    return self;
}

- (BOOL)configureWithParent:(id)aParent queue:(dispatch_queue_t)queue
{
    // This is the standard configure method used by xmpp extensions to configure a storage class.
    //
    // Feel free to override this method if needed,
    // and just invoke super at some point to make sure everything is kosher at this level as well.
    
    NSParameterAssert(aParent != nil);
    NSParameterAssert(queue != NULL);
    
    if (queue == storageQueue)
    {
        // This class is designed to be run on a separate dispatch queue from its parent.
        // This allows us to optimize the database save operations by buffering them,
        // and executing them when demand on the storage instance is low.
        
        return NO;
    }
    
    return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Core Data Setup
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString *)persistentStoreDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    
    // Attempt to find a name for this application
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if (appName == nil) {
        appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    }
    
    if (appName == nil) {
        appName = @"xmppframework";
    }
    
    
    NSString *result = [basePath stringByAppendingPathComponent:appName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:result])
    {
        [fileManager createDirectoryAtPath:result withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return result;
}

- (NSManagedObjectModel *)managedObjectModel
{
    // This is a public method.
    // It may be invoked on any thread/queue.
    
    __block NSManagedObjectModel *result = nil;
    dispatch_block_t block = ^{ @autoreleasepool {
        if (managedObjectModel) {
            result = managedObjectModel;
            return;
        }
        
        NSString *momName = [self managedObjectModelName];
        NSString *momPath = [[self managedObjectModelBundle] pathForResource:momName ofType:@"mom"];
        if (momPath == nil) {
            // The model may be versioned or created with Xcode 4, try momd as an extension.
            momPath = [[self managedObjectModelBundle] pathForResource:momName ofType:@"momd"];
        }
        
        if (momPath) {
            // If path is nil, then NSURL or NSManagedObjectModel will throw an exception
            NSURL *momUrl = [NSURL fileURLWithPath:momPath];
            
            managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momUrl];
        }
        else
        {
            NSLog(@"%@: Couldn't find managedObjectModel file - %@", [self class], momName);
        }
        
        if([NSAttributeDescription instancesRespondToSelector:@selector(setAllowsExternalBinaryDataStorage:)])
        {
            if(autoAllowExternalBinaryDataStorage)
            {
                NSArray *entities = [managedObjectModel entities];
                
                for(NSEntityDescription *entity in entities)
                {
                    NSDictionary *attributesByName = [entity attributesByName];
                    
                    [attributesByName enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                        
                        if([obj attributeType] == NSBinaryDataAttributeType)
                        {
                            [obj setAllowsExternalBinaryDataStorage:YES];
                        }
                    }];
                }
            }
        }
        
        result = managedObjectModel;
    }};
    
    if (dispatch_get_specific(storageQueueTag))
        block();
    else
        dispatch_sync(storageQueue, block);
    
    return result;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    // This is a public method.
    // It may be invoked on any thread/queue.
    
    __block NSPersistentStoreCoordinator *result = nil;
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        if (persistentStoreCoordinator) {
            result = persistentStoreCoordinator;
            return;
        }
        
        NSManagedObjectModel *mom = [self managedObjectModel];
        if (mom == nil) {
            return;
        }
        
        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
        
        if (databaseFileName)
        {
            // SQLite persistent store
            
            NSString *docsPath = [self persistentStoreDirectory];
            NSString *storePath = [docsPath stringByAppendingPathComponent:databaseFileName];
            if (storePath)
            {
                // If storePath is nil, then NSURL will throw an exception
                
                if(autoRemovePreviousDatabaseFile)
                {
                    if ([[NSFileManager defaultManager] fileExistsAtPath:storePath])
                    {
                        [[NSFileManager defaultManager] removeItemAtPath:storePath error:nil];
                    }
                }
                
                [self willCreatePersistentStoreWithPath:storePath options:storeOptions];
                
                NSError *error = nil;
                
                BOOL didAddPersistentStore = [self addPersistentStoreWithPath:storePath options:storeOptions error:&error];
                
                if(autoRecreateDatabaseFile && !didAddPersistentStore)
                {
                    [[NSFileManager defaultManager] removeItemAtPath:storePath error:NULL];
                    
                    didAddPersistentStore = [self addPersistentStoreWithPath:storePath options:storeOptions error:&error];
                }
                
                if (!didAddPersistentStore)
                {
                    [self didNotAddPersistentStoreWithPath:storePath options:storeOptions error:error];
                }
            }
            else
            {
                NSLog(@"%@: Error creating persistentStoreCoordinator - Nil persistentStoreDirectory",
                            [self class]);
            }
        }
        else
        {
            // In-Memory persistent store
            
            [self willCreatePersistentStoreWithPath:nil options:storeOptions];
            
            NSError *error = nil;
            if (![self addPersistentStoreWithPath:nil options:storeOptions error:&error])
            {
                [self didNotAddPersistentStoreWithPath:nil options:storeOptions error:error];
            }
        }
        
        result = persistentStoreCoordinator;
        
    }};
    
    if (dispatch_get_specific(storageQueueTag))
        block();
    else
        dispatch_sync(storageQueue, block);
    
    return result;
}

- (NSManagedObjectContext *)rootWriteManagedObjectContext
{
    if (rootWriteManagedObjectContext) {
        return rootWriteManagedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator) {
        rootWriteManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        rootWriteManagedObjectContext.persistentStoreCoordinator = coordinator;
        rootWriteManagedObjectContext.undoManager = nil;
    }
    return rootWriteManagedObjectContext;
}

- (NSManagedObjectContext *)mainThreadManagedObjectContext
{
    if (mainThreadManagedObjectContext) {
        return mainThreadManagedObjectContext;
    }
    
    mainThreadManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    mainThreadManagedObjectContext.parentContext = self.rootWriteManagedObjectContext;
    return mainThreadManagedObjectContext;
}

- (NSManagedObjectContext *)executeManagedObjectContext
{
    if (executeManagedObjectContext) {
        return executeManagedObjectContext;
    }
    
    executeManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    executeManagedObjectContext.parentContext = self.mainThreadManagedObjectContext;
    [self didCreateManagedObjectContext];
    return executeManagedObjectContext;
}

- (NSManagedObjectContext *)scheduleManagedObjectContext
{
    if (scheduleManagedObjectContext) {
        return scheduleManagedObjectContext;
    }
    
    scheduleManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    scheduleManagedObjectContext.parentContext = self.mainThreadManagedObjectContext;
    [self didCreateManagedObjectContext];
    return scheduleManagedObjectContext;
}

- (BOOL)autoRemovePreviousDatabaseFile
{
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{ @autoreleasepool {
        result = autoRemovePreviousDatabaseFile;
    }};
    
    if (dispatch_get_specific(storageQueueTag))
        block();
    else
        dispatch_sync(storageQueue, block);
    
    return result;
}

- (void)setAutoRemovePreviousDatabaseFile:(BOOL)flag
{
    dispatch_block_t block = ^{
        autoRemovePreviousDatabaseFile = flag;
    };
    
    if (dispatch_get_specific(storageQueueTag))
        block();
    else
        dispatch_sync(storageQueue, block);
}

- (BOOL)autoRecreateDatabaseFile
{
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{ @autoreleasepool {
        result = autoRecreateDatabaseFile;
    }};
    
    if (dispatch_get_specific(storageQueueTag))
        block();
    else
        dispatch_sync(storageQueue, block);
    
    return result;
}

- (void)setAutoRecreateDatabaseFile:(BOOL)flag
{
    dispatch_block_t block = ^{
        autoRecreateDatabaseFile = flag;
    };
    
    if (dispatch_get_specific(storageQueueTag))
        block();
    else
        dispatch_sync(storageQueue, block);
}

- (BOOL)autoAllowExternalBinaryDataStorage
{
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{ @autoreleasepool {
        result = autoAllowExternalBinaryDataStorage;
    }};
    
    if (dispatch_get_specific(storageQueueTag))
        block();
    else
        dispatch_sync(storageQueue, block);
    
    return result;
}

- (void)setAutoAllowExternalBinaryDataStorage:(BOOL)flag
{
    dispatch_block_t block = ^{
        autoAllowExternalBinaryDataStorage = flag;
    };
    
    if (dispatch_get_specific(storageQueueTag))
        block();
    else
        dispatch_sync(storageQueue, block);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Utilities
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)saveContext:(NSManagedObjectContext *)managedObjectContext
{
    //
    if (![managedObjectContext hasChanges]) {
        return;
    }
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        NSAssert(NO, @"%@: Error saving - %@ %@", [self class], error, [error userInfo]);
        [managedObjectContext rollback];
        return;
    }
    
    // 触发主线程UI更新
    if (![self.mainThreadManagedObjectContext hasChanges]) {
        return;
    }
    [self.mainThreadManagedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        if (![self.mainThreadManagedObjectContext save:&error]) {
            NSAssert(NO, @"%@: Error saving - %@ %@", [self class], error, [error userInfo]);
            [self.mainThreadManagedObjectContext rollback];
            return;
        }
    }];
    
    // 子线程写入文件
    if (![self.rootWriteManagedObjectContext hasChanges]) {
        return;
    }
    [self.rootWriteManagedObjectContext performBlock:^{
        NSError *error = nil;
        if (![self.rootWriteManagedObjectContext save:&error]) {
            NSAssert(NO, @"%@: Error saving - %@ %@", [self class], error, [error userInfo]);
            [self.rootWriteManagedObjectContext rollback];
            return;
        }
    }];
}

- (void)executeBlock:(void(^)(NSManagedObjectContext *moc))block
{
    NSManagedObjectContext *moc = self.executeManagedObjectContext;
    [moc performBlockAndWait:^{
        block(moc);
        [self saveContext:moc];
    }];
}

- (void)scheduleBlock:(void(^)(NSManagedObjectContext *moc))block
{
    NSManagedObjectContext *moc = self.scheduleManagedObjectContext;
    [moc performBlock:^{
        block(moc);
        [self saveContext:moc];
    }];
}

- (void)addWillSaveManagedObjectContextBlock:(void (^)(void))willSaveBlock
{
    dispatch_block_t block = ^{
        [willSaveManagedObjectContextBlocks addObject:[willSaveBlock copy]];
    };
    
    if (dispatch_get_specific(storageQueueTag))
        block();
    else
        dispatch_sync(storageQueue, block);
}

- (void)addDidSaveManagedObjectContextBlock:(void (^)(void))didSaveBlock
{
    dispatch_block_t block = ^{
        [didSaveManagedObjectContextBlocks addObject:[didSaveBlock copy]];
    };
    
    if (dispatch_get_specific(storageQueueTag))
        block();
    else
        dispatch_sync(storageQueue, block);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Memory Management
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)dealloc
{
    if (databaseFileName)
    {
        [[self class] unregisterDatabaseFileName:databaseFileName];
    }
    
#if !OS_OBJECT_USE_OBJC
    if (storageQueue)
        dispatch_release(storageQueue);
#endif
    
}

@end
