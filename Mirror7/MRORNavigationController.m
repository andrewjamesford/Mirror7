//
//  MRORNavigationController.m
//  MirrorMirror
//
//  Created by Andrew Ford on 13/11/13.
//  Copyright (c) 2013 Andrew Ford. All rights reserved.
//

#import "MRORNavigationController.h"
#import "MRORInfoViewController.h"
#import "REFrostedViewController.h"

@interface MRORNavigationController ()

@property (strong, readwrite, nonatomic) MRORInfoViewController *menuViewController;

@end

@implementation MRORNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)]];
}

- (void)showMenu
{
    [self.frostedViewController presentMenuViewController];
}

#pragma mark -
#pragma mark Gesture recognizer

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
    [self.frostedViewController panGestureRecognized:sender];
}

@end
