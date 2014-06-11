//
//  UIView+Geometry.m
//  Slope
//
//  Created by Boris Bügling on 05.01.13.
//  Copyright (c) 2013 Boris Bügling. All rights reserved.
//

#import "UIView+Geometry.h"

const CGFloat kMargin = 10.0;

@implementation UIView (Geometry)

-(void)centerFrameInView:(UIView *)view {
    self.x = (view.width - self.width) / 2.0;
    self.y = (view.height - self.height) / 2.0;
}

-(CGRect)maximumFrameWithOrigin:(CGPoint)origin {
    return CGRectMake(origin.x, origin.y, [self remainingWidthAtX:origin.x], [self remainingHeightAtY:origin.y]);
}

-(CGFloat)remainingHeightAtY:(CGFloat)y {
    return self.height - y - kMargin;
}

-(CGFloat)remainingWidthAtX:(CGFloat)x {
    return self.width - x - kMargin;
}

#pragma mark -

-(void)setHeight:(CGFloat)height {
    self.frame = CGRectMake(self.x, self.y, self.width, height);
}

-(void)setOrigin:(CGPoint)origin {
    self.frame = CGRectMake(origin.x, origin.y, self.width, self.height);
}

-(void)setSize:(CGSize)size {
    self.frame = CGRectMake(self.x, self.y, size.width, size.height);
}

-(void)setWidth:(CGFloat)width {
    self.frame = CGRectMake(self.x, self.y, width, self.height);
}

-(void)setX:(CGFloat)x {
    self.frame = CGRectMake(x, self.y, self.width, self.height);
}

-(void)setY:(CGFloat)y {
    self.frame = CGRectMake(self.x, y, self.width, self.height);
}

#pragma mark -

-(CGFloat)height {
    return self.frame.size.height;
}

-(CGPoint)origin {
    return self.frame.origin;
}

-(CGSize)size {
    return self.frame.size;
}

-(CGFloat)width {
    return self.frame.size.width;
}

-(CGFloat)x {
    return self.frame.origin.x;
}

-(CGFloat)y {
    return self.frame.origin.y;
}

@end
