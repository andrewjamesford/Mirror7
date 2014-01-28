//
//  MRORMainViewController.h
//  MirrorMirror
//
//  Created by Andrew Ford on 1/10/13.
//  Copyright (c) 2013 Andrew Ford. All rights reserved.
//

#import "MRORInfoViewController.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreMedia/CoreMedia.h>
#import <ImageIO/CGImageProperties.h>
#import "iAd/ADBannerView.h"

@interface MRORMainViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, ADBannerViewDelegate>



@end
