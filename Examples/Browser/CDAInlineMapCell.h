//
//  CDAInlineMapCell.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 06/05/14.
//
//

#import <UIKit/UIKit.h>

@interface CDAInlineMapCell : UITableViewCell

-(void)addAnnotationWithTitle:(NSString*)title location:(CLLocationCoordinate2D)location;

@end
