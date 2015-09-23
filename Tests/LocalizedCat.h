//
//  LocalizedCat.h
//  
//  Created by Boris Bügling on 22/09/15.
//
//

@import CoreData;
@import Foundation;

#import <ContentfulDeliveryAPI/CDALocalizablePersistedEntry.h>

@class Asset;

@interface LocalizedCat : CDALocalizablePersistedEntry

@property (nonatomic, retain) Asset *picture;

@end
