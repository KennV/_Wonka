/*
  KVAbstractDataController.h
  Apollo-00.00.00

  Created by Kenn Villegas on 8/28/15.
  Copyright © 2015 K3nnV. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface KVAbstractDataController : NSObject <NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSManagedObjectContext *MOC;
@property (readonly, strong, nonatomic) NSManagedObjectModel *MOM;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *PSK;
@property (strong, nonatomic) NSFetchedResultsController *fetchCon;

@property (nonatomic, copy) NSString* dbName;
@property (nonatomic, copy) NSString* entityClassName;
@property (nonatomic, assign) BOOL copyDatabaseIfNotPresent;
//
@property (strong, nonatomic) NSArray *miObjects; //(NSMutableArray *)getAllEntities;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

-(instancetype)initAllUp;
//-(void)makeNewPerson;

// Create a new entity of the default type
- (NSManagedObject *)createEntity;
// Mark the specified entity for deletion
- (void) deleteEntity:(NSManagedObject *)e;
// Gets all entities of the default type
- (NSMutableArray *)getAllEntities;
// Gets entities of the default type matching the predicate
- (NSMutableArray *)getEntitiesMatchingPredicate:(NSPredicate *)p;
// Gets entities of the default type matching the predicate string
- (NSMutableArray *)getEntitiesMatchingPredicateString: (NSString *)predicateString, ...;
// Get entities of the default type sorted by descriptor matching the predicate
- (NSMutableArray *)getEntitiesSortedBy:(NSSortDescriptor *) sortDescriptor
                      matchingPredicate:(NSPredicate *)predicate;
// Get entities of the specified type sorted by descriptor matching the predicate
- (NSMutableArray *)getEntities:(NSString *)entityName sortedBy:
(NSSortDescriptor *)sortDescriptor matchingPredicate:(NSPredicate *)predicate;
// Get entities of the specified type sorted by descriptor matching the predicate string
- (NSMutableArray *)getEntities:(NSString *)entityName sortedBy:
(NSSortDescriptor *)sortDescriptor matchingPredicateString:(NSString *)predicateString, ...;
// Saves changes to all entities managed by the object context
- (void)saveEntities;
// Register a related business controller object
// This causes them to use the same object context
- (void)registerRelatedObject:(KVAbstractDataController *)controllerObject;
- (void)performAutomaticLightweightMigration;

@end
