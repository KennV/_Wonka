/*
  KVAbstractDataController.m
  Apollo-00.00.00

  Created by Kenn Villegas on 8/28/15.
  Copyright © 2015 K3nnV. All rights reserved.
*/

#import "KVAbstractDataController.h"

@interface KVAbstractDataController () {
}
@end

@implementation KVAbstractDataController

@synthesize MOC = _MOC;
@synthesize MOM = _MOM;
@synthesize PSK = _PSK;
@synthesize miObjects =_miObjects;

-(instancetype)initAllUp {
    if (!(self = [super init])) {
        return nil;
    }
//    if (!self.PSK.description) {
//        NSLog(@"Could Not Init PSCoordinator");
//    }
//    if (!self.MOC.description) {
//        NSLog(@"Could Not Init Context");
//    }
//    if (!self.MOM.description) {
//        NSLog(@"Could Not Init Model");
//    }
    _copyDatabaseIfNotPresent = YES;
    NSLog(@"applicationDocumentsDirectory = %@",self.applicationDocumentsDirectory);
    return self;
}

#pragma mark - Core Data stack
- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "edu._Company._Application" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)MOM {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_MOM != nil) {
        return _MOM;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Apollo-00_00_00" withExtension:@"MOMd"];
    _MOM = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _MOM;
}

- (NSPersistentStoreCoordinator *)PSK {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_PSK != nil) {
        return _PSK;
    }
    
    // Create the coordinator and store
    
    _PSK = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self MOM]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Apollo-00_00_00.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_PSK addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _PSK;
}

- (NSManagedObjectContext *)MOC {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_MOC != nil) {
        return _MOC;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self PSK];
    if (!coordinator) {
        return nil;
    }
    _MOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_MOC setPersistentStoreCoordinator:coordinator];
    return _MOC;
}

#pragma mark - Core Data Saving support
- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.MOC;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark -

- (void)performAutomaticLightweightMigration {
    
    NSError *error;
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", self.dbName, @".sqlite"]];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    if (![_PSK addPersistentStoreWithType:NSSQLiteStoreType
                            configuration:nil
                                      URL:storeURL
                                  options:options
                                    error:&error]){
        // Handle the error.
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchCon {
  // This is old code, and I use it on a table but I am not sure it goes here. But it can be cleaner
  // self.entityClassName

    if (_fetchCon != nil) {
        return _fetchCon;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate. (Event, RootEntity, ABSTRACT_OBJ)
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityClassName inManagedObjectContext:self.MOC];

    [fetchRequest setEntity:entity];
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"hexID" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.MOC sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchCon = aFetchedResultsController;
    
    NSError *error = nil;
    
    if (![self.fetchCon performFetch:&error]) {
        NSLog(@"It is Fun \nAND Insightful to Know when and Why this happened");
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _fetchCon;
}

- (NSArray *)miObjects {
    if (!_miObjects) {
        _miObjects = [[NSMutableArray alloc]init];
    }
  NSEntityDescription *enitiyOne = [[[self fetchCon] fetchRequest] entity]; //Hmm??
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:[enitiyOne name]];
    NSError *error = nil;

    _miObjects = [[[self fetchCon]managedObjectContext] executeFetchRequest:request error:&error];
    if (_miObjects.count == 0 ) {
        NSLog(@"stack = %lu Should I Make an Object?",(unsigned long)[_miObjects count]);
        NSLog(@"or should the tvController do it?");
    }
//    NSLog(@"stack = %lu",(unsigned long)[_miObjects count]); only log this once
    return _miObjects;
}

#pragma mark - Control
- (void)makeNewPerson {
//    KVPerson *p = [NSEntityDescription insertNewObjectForEntityForName:(@"KVPerson") inManagedObjectContext:self.MOC];
//    KVRootEntityData *d = [NSEntityDescription insertNewObjectForEntityForName:OBJ_DATA inManagedObjectContext:self.MOC];
//    KVRootEntityGraphics *g = [NSEntityDescription insertNewObjectForEntityForName:OBJ_GRAPHICS inManagedObjectContext:self.MOC];
//    KVRootEntityPhysics *physX = [NSEntityDescription insertNewObjectForEntityForName:OBJ_PHYSICS inManagedObjectContext:self.MOC];
//    
//    [[KVPersonController class]setupPerson:p data:d graphics:g physics:physX randomizedIfYES:YES];
//    NSError *error = nil;
//    if (![self.MOC save:&error]) {
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort(); }
}

- (void)deleteAnObject:(id)thisObjOrNil {
    ; // That's nifty if I do not pass it a valid obj then I will delete first or last
}
#pragma mark - utilities

- (NSManagedObject *)createEntity
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityClassName] inManagedObjectContext:[self MOC]];
}

- (void)deleteEntity:(NSManagedObject *)e  {
    [[self MOC] deleteObject:e];
}

- (NSMutableArray *)getEntities:(NSString *)entityName
                       sortedBy:(NSSortDescriptor *)sortDescriptor
              matchingPredicate:(NSPredicate *)predicate
{
    NSError *error = nil;
    
    // Create the request object
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    // Set the entity type to be fetched
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self MOC]];
    [request setEntity:entity];
    
    // Set the predicate if specified
    if (predicate) {
        [request setPredicate:predicate];
    }
    
    // Set the sort descriptor if specified
    if (sortDescriptor) {
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [request setSortDescriptors:sortDescriptors];
    }
    
    // Execute the fetch
    NSMutableArray *mutableFetchResults = [[_MOC executeFetchRequest:request error:&error] mutableCopy];
    
    if (mutableFetchResults == nil) {
        
        // Handle the error.
    }
    
    return mutableFetchResults;
}

- (NSMutableArray *)getAllEntities
{
    return [self getEntities:[self entityClassName] sortedBy:nil matchingPredicate:nil];
}

- (NSMutableArray *)getEntitiesMatchingPredicate: (NSPredicate *)p
{
    return [self getEntities:[self entityClassName] sortedBy:nil matchingPredicate:p];
}

- (NSMutableArray *)getEntitiesMatchingPredicateString: (NSString *)predicateString, ...;
{
    va_list variadicArguments;
    va_start(variadicArguments, predicateString);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString
                                                    arguments:variadicArguments];
    va_end(variadicArguments);
    return [self getEntities:[self entityClassName] sortedBy:nil matchingPredicate:predicate];
}

- (NSMutableArray *)getEntitiesSortedBy:(NSSortDescriptor *)sortDescriptor
                      matchingPredicate:(NSPredicate *)predicate
{
    return [self getEntities:[self entityClassName] sortedBy:sortDescriptor matchingPredicate:predicate];
}

- (NSMutableArray *)getEntities:(NSString *)entityName sortedBy:(NSSortDescriptor *)sortDescriptor matchingPredicateString:(NSString *)predicateString, ...;
{
    va_list variadicArguments;
    va_start(variadicArguments, predicateString);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString
                                                    arguments:variadicArguments];
    va_end(variadicArguments);
    return [self getEntities:entityName sortedBy:sortDescriptor matchingPredicate:predicate];
}

- (void) registerRelatedObject:(KVAbstractDataController *)controllerObject
{
    controllerObject.MOC = [self MOC];
}

- (void)saveEntities
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [self MOC];
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}
@end
