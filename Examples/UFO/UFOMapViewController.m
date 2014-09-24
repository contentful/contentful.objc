//
//  UFOMapViewController.m
//  UFO Example
//
//  Created by Boris Bügling on 11.11.13.
//  Copyright (c) 2013 Boris Bügling. All rights reserved.
//

@import MapKit;

#import "UFOMapViewController.h"
#import "UFOSighting.h"

@interface UFOMapViewController () <MKMapViewDelegate, UISearchBarDelegate>

@property NSRegularExpression* currentRegex;
@property MKMapView* mapView;
@property UISearchBar* searchBar;
@property UITextView* textView;

@end

#pragma mark -

@implementation UFOMapViewController

-(void)addItemsToMapView {
    if (self.items) {
        [self.mapView removeAnnotations:self.mapView.annotations];
        
        for (UFOSighting* item in self.items) {
            if (item.title) {
                [self.mapView addAnnotation:item];
            }
        }
        
        [self.mapView selectAnnotation:[self.mapView.annotations firstObject] animated:YES];
    }
}

-(id)init {
    self = [super init];
    if (self) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", nil)
                                                                                 style:UIBarButtonItemStyleBordered
                                                                                target:self
                                                                                action:@selector(nextTapped)];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Search", nil)
                                                                                  style:UIBarButtonItemStyleBordered
                                                                                 target:self
                                                                                 action:@selector(searchTapped:)];
        
        self.title = NSLocalizedString(@"UFO Sightings", nil);
    }
    return self;
}

-(void)nextTapped {
    NSUInteger currentIndex = [self.mapView.annotations indexOfObject:[[self.mapView selectedAnnotations] firstObject]];
    currentIndex++;
    
    if (currentIndex < self.mapView.annotations.count) {
        [self.mapView selectAnnotation:self.mapView.annotations[currentIndex] animated:YES];
    } else {
        [self.mapView selectAnnotation:[self.mapView.annotations firstObject] animated:YES];
    }
}

-(void)searchTapped:(UIBarButtonItem*)item {
    item.enabled = NO;
    
    if (self.searchBar) {
        [UIView animateWithDuration:1.0 animations:^{
            CGRect frame = self.searchBar.frame;
            frame.origin.y = -44.0;
            self.searchBar.frame = frame;
        } completion:^(BOOL finished) {
            [self.searchBar removeFromSuperview];
            self.searchBar = nil;
            item.enabled = YES;
            
            self.currentRegex = nil;
            [self.mapView removeAnnotations:self.mapView.annotations];
            for (UFOSighting* item in self.items) {
                if (item.title) {
                    [self.mapView addAnnotation:item];
                }
            }
            
            [self.mapView selectAnnotation:[self.mapView.annotations firstObject] animated:YES];
        }];
        
        return;
    }
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, -44.0, self.view.frame.size.width, 44.0)];
    self.searchBar.delegate = self;
    [self.view addSubview:self.searchBar];
    
    [UIView animateWithDuration:1.0 animations:^{
        CGRect frame = self.searchBar.frame;
        frame.origin.y = 60.0;
        self.searchBar.frame = frame;
    } completion:^(BOOL finished) {
        item.enabled = YES;
    }];
}

-(void)setItems:(NSArray *)items {
    if (_items == items) {
        return;
    }
    
    _items = items;
    
    [self addItemsToMapView];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    [self addItemsToMapView];
}

#pragma mark - MKMapView delegate methods

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    CGRect frame = self.view.frame;
    frame.origin.y = (frame.size.height / 2) + 50.0;
    frame.size.height -= frame.origin.y;
    
    UFOSighting* sighting = (UFOSighting*)view.annotation;
    [mapView setCenterCoordinate:sighting.coordinate animated:YES];
    
    [self.textView removeFromSuperview];
    
    self.textView = [[UITextView alloc] initWithFrame:frame];
    self.textView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    self.textView.editable = NO;
    
    if (self.searchBar) {
        NSMutableAttributedString* attributedText = [[NSMutableAttributedString alloc]
                                                     initWithString:sighting.sightingDescription
                                                     attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:18.0],
                                                                   NSForegroundColorAttributeName: [UIColor whiteColor] }];
        
        for (NSTextCheckingResult* match in [self.currentRegex matchesInString:sighting.sightingDescription options:0 range:NSMakeRange(0, sighting.sightingDescription.length)]) {
            [attributedText addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:match.range];
        }
        
        self.textView.attributedText = attributedText;
    } else {
        self.textView.font = [UIFont systemFontOfSize:18.0];
        self.textView.text = sighting.sightingDescription;
        self.textView.textColor = [UIColor whiteColor];
    }
    
    [self.view addSubview:self.textView];
    
    NSInteger index = [self.mapView.annotations indexOfObject:view.annotation] + 1;
    self.title = [NSString stringWithFormat:@"%ld of %lu sightings", (long)index, (unsigned long)self.mapView.annotations.count];
}

#pragma mark - UISearchBar delegate methods

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    NSString* pattern = [searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@"|"];
    self.currentRegex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                  options:NSRegularExpressionCaseInsensitive
                                                                    error:nil];
    
    for (UFOSighting* item in self.items) {
        if (!item.title) {
            continue;
        }
        
        if ([self.currentRegex matchesInString:item.title options:0 range:NSMakeRange(0, item.title.length)].count > 0 || [self.currentRegex matchesInString:item.sightingDescription options:0 range:NSMakeRange(0, item.sightingDescription.length)].count > 0) {
            if ([self.mapView.annotations indexOfObject:item] == NSNotFound) {
                [self.mapView addAnnotation:item];
            }
            continue;
        }
        
        [self.mapView removeAnnotation:item];
    }
    
    if (self.mapView.annotations.count == 0) {
        [self.textView removeFromSuperview];
        self.title = NSLocalizedString(@"UFO Sightings", nil);
        return;
    }
    
    [self.mapView selectAnnotation:[self.mapView.annotations firstObject] animated:YES];
}

@end
