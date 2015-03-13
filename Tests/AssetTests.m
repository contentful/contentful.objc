//
//  AssetTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 27/03/14.
//
//

@import ImageIO;

#import "CDAResource+Private.h"
#import "ContentfulBaseTestCase.h"

@interface AssetTests : ContentfulBaseTestCase

@end

#pragma mark -

@implementation AssetTests

-(void)fetchImageAtURL:(NSURL*)imageURL
       completionBlock:(void (^)(UIImage* image, NSDictionary* properties))completionBlock {
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:imageURL] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        XCTAssertNotNil(data, @"");
        
        UIImage* image = [UIImage imageWithData:data];
        XCTAssertNotNil(image, @"");
        
        CGImageSourceRef imageSource =CGImageSourceCreateWithData((__bridge CFDataRef)(data), nil);
        NSDictionary* properties = CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(imageSource,
                                                                                        0, nil));
        CFRelease(imageSource);
        XCTAssertNotNil(properties, @"");
        
        if (completionBlock) {
            completionBlock(image, properties);
        }
    }];
}

-(void)fetchImageWithParametersFit:(CDAFitType)fit
                             focus:(NSString*)focus
                            radius:(CGFloat)radius
                        background:(NSString*)backgroundColor
                       progressive:(BOOL)progressive {
    StartBlock();

    [self.client fetchAssetWithIdentifier:@"nyancat" success:^(CDAResponse *response, CDAAsset *asset) {
        __block NSURL* imageURL = [asset imageURLWithSize:CGSizeZero
                                                  quality:CDAImageQualityOriginal
                                                   format:CDAImageFormatJPEG
                                                      fit:fit
                                                    focus:focus
                                                   radius:radius
                                               background:backgroundColor
                                              progressive:progressive];

        [self fetchImageAtURL:imageURL completionBlock:^(UIImage *image, NSDictionary* properties) {
            EndBlock();
        }];
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);

        EndBlock();
    }];

    WaitUntilBlockCompletes();
}

-(void)testChangeImageFitCrop {
    [self fetchImageWithParametersFit:CDAFitCrop
                                focus:nil
                               radius:CDARadiusNone
                           background:nil
                          progressive:false];
}

-(void)testChangeImageFitDefault {
    [self fetchImageWithParametersFit:CDAFitDefault
                                focus:nil
                               radius:CDARadiusNone
                           background:nil
                          progressive:false];
}

-(void)testChangeImageFitFill {
    [self fetchImageWithParametersFit:CDAFitFill
                                focus:nil
                               radius:CDARadiusNone
                           background:nil
                          progressive:false];
}

-(void)testChangeImageFitPad {
    [self fetchImageWithParametersFit:CDAFitPad
                                focus:nil
                               radius:CDARadiusNone
                           background:nil
                          progressive:false];
}

-(void)testChangeImageFitScale {
    [self fetchImageWithParametersFit:CDAFitScale
                                focus:nil
                               radius:CDARadiusNone
                           background:nil
                          progressive:false];
}

-(void)testChangeImageFitThumb {
    [self fetchImageWithParametersFit:CDAFitThumb
                                focus:nil
                               radius:CDARadiusNone
                           background:nil
                          progressive:false];
}

-(void)testChangeImageFocusRight {
    [self fetchImageWithParametersFit:CDAFitDefault
                                focus:@"right"
                               radius:CDARadiusNone
                           background:nil
                          progressive:false];
}

-(void)testChangeImageFocusTopRight {
    [self fetchImageWithParametersFit:CDAFitDefault
                                focus:@"top_right"
                               radius:CDARadiusNone
                           background:nil
                          progressive:false];
}

-(void)testChangeImageRadiusAny {
    [self fetchImageWithParametersFit:CDAFitDefault
                                focus:nil
                               radius:23.0
                           background:nil
                          progressive:false];
}

-(void)testChangeImageRadiusMax {
    [self fetchImageWithParametersFit:CDAFitDefault
                                focus:nil
                               radius:CDARadiusMaximum
                           background:nil
                          progressive:false];
}

-(void)testChangeImageFormatToJPEG {
    StartBlock();
    
    [self.client fetchAssetWithIdentifier:@"nyancat" success:^(CDAResponse *response, CDAAsset *asset) {
        __block NSURL* imageURL = [asset imageURLWithSize:CGSizeZero
                                                  quality:CDAImageQualityOriginal
                                                   format:CDAImageFormatJPEG];
        
        [self fetchImageAtURL:imageURL completionBlock:^(UIImage *image, NSDictionary* properties) {
            EndBlock();
        }];
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

-(void)testChangeImageFormatToPNG {
    StartBlock();
    
    [self.client fetchAssetWithIdentifier:@"nyancat" success:^(CDAResponse *response, CDAAsset *asset) {
        __block NSURL* imageURL = [asset imageURLWithSize:CGSizeZero
                                                  quality:CDAImageQualityOriginal
                                                   format:CDAImageFormatPNG];
        
        [self fetchImageAtURL:imageURL completionBlock:^(UIImage *image, NSDictionary* properties) {
            EndBlock();
        }];
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

-(void)testChangeImageQuality {
    StartBlock();
    
    [self.client fetchAssetWithIdentifier:@"nyancat" success:^(CDAResponse *response, CDAAsset *asset) {
        __block NSURL* imageURL = [asset imageURLWithSize:CGSizeZero
                                                  quality:0.5
                                                   format:CDAImageFormatJPEG];
        
        [self fetchImageAtURL:imageURL completionBlock:^(UIImage *image, NSDictionary* properties) {
            EndBlock();
        }];
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

-(void)testDoNotRequireClientPropertyForGeneratingURL {
    StartBlock();

    [self.client fetchAssetWithIdentifier:@"nyancat" success:^(CDAResponse *response, CDAAsset *asset) {
        NSURL* imageURL = [asset imageURLWithSize:CGSizeMake(50.0, 50.0)];

        asset.client = nil;
        NSURL* otherImageURL = [asset imageURLWithSize:CGSizeMake(50.0, 50.0)];

        XCTAssertEqualObjects(imageURL, otherImageURL);
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);

        EndBlock();
    }];

    WaitUntilBlockCompletes();
}

-(void)testResizeAsset {
    StartBlock();
    
    [self.client fetchAssetWithIdentifier:@"nyancat" success:^(CDAResponse *response, CDAAsset *asset) {
        __block NSURL* imageURL = [asset imageURLWithSize:CGSizeMake(50.0, 50.0)];
        
        [self fetchImageAtURL:imageURL completionBlock:^(UIImage *image, NSDictionary* props) {
            XCTAssertEqual(50.0f, image.size.width, @"");
            XCTAssertEqual(50.0f, image.size.height, @"");
            
            imageURL = [asset imageURLWithSize:CGSizeMake(asset.size.width * 3, asset.size.height * 3)];
            [self fetchImageAtURL:imageURL completionBlock:^(UIImage *image, NSDictionary* props) {
                XCTAssertEqual(asset.size.width, image.size.width, @"");
                XCTAssertEqual(asset.size.height, image.size.height, @"");
                
                imageURL = [asset imageURLWithSize:CGSizeMake(0.0, 0.0)];
                [self fetchImageAtURL:imageURL completionBlock:^(UIImage *image, NSDictionary* props) {
                    XCTAssertEqual(asset.size.width, image.size.width, @"");
                    XCTAssertEqual(asset.size.height, image.size.height, @"");
                    
                    EndBlock();
                }];
            }];
        }];
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

@end
