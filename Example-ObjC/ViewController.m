//
//  ViewController.m
//  Example-ObjC
//
//  Created by Indragie Karunaratne on 4/20/19.
//  Copyright © 2019 Indragie Karunaratne. All rights reserved.
//

#import "ViewController.h"

@import InAppViewDebugger;

@implementation ViewController

- (void)loadView
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = UIColor.cyanColor;
    view.frame = UIScreen.mainScreen.bounds;
    
    CGRect slice, remainder;
    CGRectDivide(view.bounds, &slice, &remainder, CGRectGetWidth(view.bounds) / 2.0, CGRectMinXEdge);
    UIView *view1 = [[UIView alloc] init];
    view1.backgroundColor = UIColor.yellowColor;
    view1.frame = slice;
    
    UIView *view2 = [[UIView alloc] init];
    view2.backgroundColor = UIColor.purpleColor;
    view2.frame = remainder;
    
    [view addSubview:view1];
    [view addSubview:view2];
    
    CGRect slice1, remainder1;
    CGRectDivide(view1.bounds, &slice1, &remainder1, CGRectGetHeight(view1.bounds) / 2.0, CGRectMinYEdge);
    UIView *view3 = [[UIView alloc] init];
    view3.backgroundColor = UIColor.blueColor;
    view3.frame = slice1;
    
    UIView *overlay = [[UIView alloc] init];
    overlay.backgroundColor = UIColor.brownColor;
    overlay.frame = UIEdgeInsetsInsetRect(view3.bounds, UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0));
    [view3 addSubview:overlay];
    
    UIView *view4 = [[UIView alloc] init];
    view4.backgroundColor = UIColor.orangeColor;
    view4.frame = remainder1;
    
    [view1 addSubview:view3];
    [view1 addSubview:view4];
    
    CGRect slice2, remainder2;
    CGRectDivide(view2.bounds, &slice2, &remainder2, CGRectGetHeight(view2.bounds) / 2.0, CGRectMinYEdge);
    UIView *view5 = [[UIView alloc] init];
    view5.backgroundColor = UIColor.redColor;
    view5.frame = slice2;
    
    UIView *view6 = [[UIView alloc] init];
    view6.backgroundColor = UIColor.greenColor;
    view6.frame = remainder2;
    
    [view2 addSubview:view5];
    [view2 addSubview:view6];
    
    self.view = view;
}

- (IBAction)snapshot:(UIBarButtonItem *)sender
{
    [InAppViewDebugger present];
}

@end
