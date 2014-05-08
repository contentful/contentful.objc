//
//  CDAInlineMapCell.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 06/05/14.
//
//

#import "CDAAssetPreviewCell.h"

@interface CDAInlineMapCell : CDAAssetPreviewCell

-(void)addAnnotationWithTitle:(NSString*)title location:(CLLocationCoordinate2D)location;

@end
