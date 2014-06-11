//
//  UIView+Geometry.h
//  Slope
//
//  Created by Boris Bügling on 05.01.13.
//  Copyright (c) 2013 Boris Bügling. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CGPointMakeAfterView(view)          CGPointMake(CGRectGetMaxX(view.frame) + kMargin, view.y)
#define CGPointMakeUnderView(view)          CGPointMake(view.x, CGRectGetMaxY(view.frame) + kMargin)

#define CGRectMakeWithOrigin(x, y)          CGRectMake(x, y, 0.0, 0.0)
#define CGRectMakeWithSize(width, height)   CGRectMake(0.0, 0.0, width, height)

extern const CGFloat kMargin;

@interface UIView (Geometry)

@property (assign) CGSize size;
@property (assign) CGFloat width;
@property (assign) CGFloat height;

@property (assign) CGPoint origin;
@property (assign) CGFloat x;
@property (assign) CGFloat y;

-(void)centerFrameInView:(UIView*)view;
-(CGRect)maximumFrameWithOrigin:(CGPoint)origin;

@end
