//
//  MRORMainViewController.m
//  MirrorMirror
//
//  Created by Andrew Ford on 1/10/13.
//  Copyright (c) 2013 Andrew Ford. All rights reserved.
//

#import "MRORMainViewController.h"
#import "MRORInfoViewController.h"
#import "MRORNavigationController.h"
#import "REFrostedViewController.h"
#import "IonIcons.h"

@interface MRORMainViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>


@property (nonatomic, retain) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) IBOutlet UIView *overlayView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet UIButton *tapButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *zoomButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *pauseButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *infoButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) NSMutableArray *capturedImages;
@property UIImagePickerController *picker;
@property BOOL *zoomOn;
@property BOOL *freezeOn;
@property BOOL *imageShow;
@property CGFloat *zoomOutValue;
@property CGFloat *zoomInValue;
@property AVCaptureVideoPreviewLayer *previewLayer;
@property AVCaptureSession *session;
@property UIImage *image;
@property UIColor *currentColor;
@property UIColor *disabledColor;
@property ADBannerView *bannerView;
@property BOOL *purchased;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;



@end

@implementation MRORMainViewController {}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.
    
    _bannerView = [[ADBannerView alloc] init];
    _bannerView.delegate = self;
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (!(_session)) {
        [self setupCameraSession];
    }

    // Reset
    [self resetFlags];
    [self resetButtonIcons];
    
    _currentColor = kColorBlue;
    _disabledColor = kColorGrey;
    
    
    [self showOverlay];
    
    // Check IAP is purchased
    _purchased = [[NSUserDefaults standardUserDefaults] boolForKey:kIAPRemoveAds];
    
    
    if (!_purchased) {
        // Show ads
        [self showAds];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Hide status bar
- (BOOL)prefersStatusBarHidden {
    return YES;
}

// Show overlay
- (void)showOverlay
{
    // Tool bar and freeze button
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"OverlayView"
                                                  owner:self
                                                options:nil]
                    objectAtIndex:0];
    
    UIImage *imageUpload = [IonIcons imageWithIcon:icon_ios7_upload_outline
                                         iconColor:_disabledColor
                                          iconSize:kTabBarIconSize
                                         imageSize:kTabBarIconImage];
    
    UIImage *imageZoom = [IonIcons imageWithIcon:icon_ios7_eye_outline
                                   iconColor:_currentColor
                                    iconSize:kTabBarIconSize
                                   imageSize:kTabBarIconImage];
    
    UIImage *imagePause = [IonIcons imageWithIcon:icon_ios7_pause_outline
                                        iconColor:_currentColor
                                         iconSize:kTabBarIconSize
                                        imageSize:kTabBarIconImage];
    
    UIImage *imageInfo = [IonIcons imageWithIcon:icon_ios7_information_outline
                                        iconColor:_currentColor
                                         iconSize:kTabBarIconSize
                                        imageSize:kTabBarIconImage];

    
    [_shareButton setTitle:@"Share"];
    [_shareButton setImage:imageUpload];
    
    [_pauseButton setImage:imagePause];
    
    [_zoomButton setImage:imageZoom];
    
    [_infoButton setImage:imageInfo];
    
    // Check phone screen size
    if ([self hasFourInchDisplay]) {
        view.frame = CGRectMake(0, 0, 320, 568);
    }
    
    [self.view addSubview:view];
    
    
}

// Show ads
- (void)showAds
{
    // Banner view
    [self.view addSubview:_bannerView];
}

// Reset flags
- (void)resetFlags
{
    _zoomOn = NO;
    _freezeOn = NO;
    _imageShow = NO;
    
    self.imageView.image = nil;

}

// Reset button icons
- (void)resetButtonIcons {
    UIImage *imageUpload = [IonIcons imageWithIcon:icon_ios7_upload_outline
                                         iconColor:_disabledColor
                                          iconSize:kTabBarIconSize
                                         imageSize:kTabBarIconImage];
    
    UIImage *imageZoom = [IonIcons imageWithIcon:icon_ios7_eye_outline
                                       iconColor:_currentColor
                                        iconSize:kTabBarIconSize
                                       imageSize:kTabBarIconImage];
    
    UIImage *imagePause = [IonIcons imageWithIcon:icon_ios7_pause_outline
                                        iconColor:_currentColor
                                         iconSize:kTabBarIconSize
                                        imageSize:kTabBarIconImage];
    
    [_shareButton setImage:imageUpload];
    [_pauseButton setImage:imagePause];
    [_zoomButton setImage:imageZoom];
}

// Is phone 4 inch display
- (BOOL)hasFourInchDisplay {
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568.0);
}

#pragma mark - AVCapture

// Iterate over device inputs to grab front camera
- (AVCaptureDevice *)frontCamera {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionFront) {
            return device;
        }
    }
    return nil;
}

// Setup session to caputre camera
- (void)setupCameraSession
{
    
    // Session
    _session = [AVCaptureSession new];
    [_session setSessionPreset:AVCaptureSessionPresetPhoto];
    
    // Capture device
    AVCaptureDevice *inputDevice = [self frontCamera];
    NSError *error;
    
    // Device input
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice
                                                                              error:&error];
	if ( [_session canAddInput:deviceInput] )
		[_session addInput:deviceInput];
    
    // Preview
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    [_previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
    
    CALayer *rootLayer = [[self view] layer];
	[rootLayer setMasksToBounds:YES];
    
    // Set size and keep aspect ratio
    _previewLayer.frame = self.view.bounds;
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [rootLayer insertSublayer:_previewLayer atIndex:1];
    
    // Set ouput as JPEG
    _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [_stillImageOutput setOutputSettings:outputSettings];
    [_session addOutput:_stillImageOutput];
    
    [_session startRunning];
}

// Play a sound
- (void)playSound
{
    AVAudioPlayer *audioPlayer;
    NSString *audioPath = [[NSBundle mainBundle] pathForResource:@"ding1"
                                                          ofType:@"mp3"];
    
    NSURL *audioURL = [NSURL fileURLWithPath:audioPath];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL
                                                         error:nil];
    [audioPlayer play];
}

// Scale and rotate image
- (UIImage*)scaleAndRotateImage:(UIImage*) image {

	int kMaxResolution = 1136; // Or whatever
    
	CGImageRef imgRef = image.CGImage;
    
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
    
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
	if (width > kMaxResolution || height > kMaxResolution) {
		CGFloat ratio = width/height;
		if (ratio > 1) {
			bounds.size.width = kMaxResolution;
			bounds.size.height = bounds.size.width / ratio;
		}
		else {
			bounds.size.height = kMaxResolution;
			bounds.size.width = bounds.size.height * ratio;
		}
	}
    
	CGFloat scaleRatio = bounds.size.width / width;
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
	CGFloat boundHeight;
	UIImageOrientation orient = image.imageOrientation;
	switch(orient) {
            
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
            
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
            
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
            
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
            
		case UIImageOrientationLeftMirrored: //EXIF = 5
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
            
		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
            
		case UIImageOrientationRightMirrored: //EXIF = 7
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
            
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
            
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
	}
    
	UIGraphicsBeginImageContext(bounds.size);
    
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -height, 0);
	}
	else {
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -height);
	}
    
	CGContextConcatCTM(context, transform);
    
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
	return imageCopy;
}


#pragma mark - Freeze screen
// Toggle Freeze Screen
- (IBAction)toggleFreezeScreen:(id)sender
{
    //[self playSound];
    
    if (!(_zoomOn))
    {
        // Check bool for image showing
        if (!(_imageShow))
        {
            [self freezeScreen];
            
            // Set icon to play
            UIImage *imagePlay = [IonIcons imageWithIcon:icon_ios7_play_outline
                                                iconColor:_currentColor
                                                 iconSize:kTabBarIconSize
                                                imageSize:kTabBarIconImage];
            [_pauseButton setImage:imagePlay];
            
            UIImage *imageUpload = [IonIcons imageWithIcon:icon_ios7_upload_outline
                                                 iconColor:_currentColor
                                                  iconSize:kTabBarIconSize
                                                 imageSize:kTabBarIconImage];
            
            [_shareButton setImage:imageUpload];
            
            // Set icon to zoom off
            UIImage *imageZoomOff = [IonIcons imageWithIcon:icon_ios7_eye_outline
                                                  iconColor:_disabledColor
                                                   iconSize:kTabBarIconSize
                                                  imageSize:kTabBarIconImage];
            [_zoomButton setImage:imageZoomOff];

            _freezeOn = YES;
            
        }
        else {
           // Clear image and reset bool flag
           self.imageView.image = nil;
           _imageShow = NO;
            
            // Set icon to pause
            UIImage *imagePause = [IonIcons imageWithIcon:icon_ios7_pause_outline
                                                iconColor:_currentColor
                                                 iconSize:kTabBarIconSize
                                                imageSize:kTabBarIconImage];
            [_pauseButton setImage:imagePause];
            

            UIImage *imageUpload = [IonIcons imageWithIcon:icon_ios7_upload_outline
                                                 iconColor:_disabledColor
                                                  iconSize:kTabBarIconSize
                                                 imageSize:kTabBarIconImage];
            
            [_shareButton setImage:imageUpload];
            
            // Set icon to zoom off
            UIImage *imageZoomOn = [IonIcons imageWithIcon:icon_ios7_eye_outline
                                                  iconColor:_currentColor
                                                   iconSize:kTabBarIconSize
                                                  imageSize:kTabBarIconImage];
            [_zoomButton setImage:imageZoomOn];
            
            _freezeOn = NO;
            
        }
    }
    
}
// Freeze screen
- (void)freezeScreen {
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in _stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection)
        {
            break;
        }
    }
    
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                   completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         CFDictionaryRef exifAttachments = CMGetAttachment( imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
         if (exifAttachments)
         {
             // Do something with the attachments.
         }
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         _image = [[UIImage alloc] initWithData:imageData];
         
         UIImage *flip = [UIImage imageWithCGImage:_image.CGImage
                                             scale:_image.scale
                                       orientation:UIImageOrientationLeftMirrored];
         
         
     
         self.imageView.frame = self.view.bounds;
         self.imageView.image = flip;
         
                  
         _imageShow = YES;

     }];
}

#pragma mark - Zoom
// Set zoom scale
- (void)zoom:(int)Scale {
    CATransform3D transform = CATransform3DIdentity;
    float zDistance = 850;
    transform.m34 = 1.0 / -zDistance;
    transform = CATransform3DScale(transform, Scale, Scale, 0.0);
    [_previewLayer setTransform:transform];
}

// Toggle Zoom
- (IBAction)toggleZoom:(id)sender {

    if (!(_freezeOn)) {
        // Check zoom on
        if (_zoomOn) {
            _zoomOn = NO;
            
            [self zoom:1];
            
            // Set icon to zoom off
            UIImage *imageZoomOff = [IonIcons imageWithIcon:icon_ios7_eye_outline
                                                iconColor:_currentColor
                                                 iconSize:kTabBarIconSize
                                                imageSize:kTabBarIconImage];
            [_zoomButton setImage:imageZoomOff];
            
            // Show freeze enabled
            UIImage *imageFreezeEnabled = [IonIcons imageWithIcon:icon_ios7_pause_outline
                                                 iconColor:_currentColor
                                                  iconSize:kTabBarIconSize
                                                 imageSize:kTabBarIconImage];
            [_pauseButton setImage:imageFreezeEnabled];

            
        }
        else {
            _zoomOn = YES;
            
            [self zoom:2];
            
            // Set icon to zoom on
            UIImage *imageZoomOn = [IonIcons imageWithIcon:icon_ios7_eye
                                                 iconColor:_currentColor
                                                  iconSize:kTabBarIconSize
                                                 imageSize:kTabBarIconImage];
            [_zoomButton setImage:imageZoomOn];
            
            // Show freeze disabled
            UIImage *imageFreezeDisabled = [IonIcons imageWithIcon:icon_ios7_pause_outline
                                                 iconColor:_disabledColor
                                                  iconSize:kTabBarIconSize
                                                 imageSize:kTabBarIconImage];
            [_pauseButton setImage:imageFreezeDisabled];

        }
    }
}


#pragma mark - Toggle Popover info view
- (IBAction)togglePopover:(id)sender
{

    [self.frostedViewController presentMenuViewController];
}

#pragma mark - Share
// Share photo
- (void)sharePhoto
{

    NSArray *items = [NSArray arrayWithObjects:
                      _image, nil];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items
                                                                                         applicationActivities:nil];
    
    activityViewController.excludedActivityTypes =   @[UIActivityTypePostToWeibo,
                                                       UIActivityTypeAssignToContact,
                                                       UIActivityTypePostToVimeo,
                                                       UIActivityTypeAddToReadingList,
                                                       UIActivityTypePostToTencentWeibo];
    
    [activityViewController setCompletionHandler:^(NSString *activityType, BOOL completed) {
        
        // Set the completed flag as a string
        NSString *completedFlag = @"";
        if (completed) {
            completedFlag = @"1";
        }
        else {
            completedFlag = @"0";

        }
        
        NSString *activityTypeString = @"";
        
        if([activityType isEqualToString: UIActivityTypeMail])
            activityTypeString = @"Mail";
        
        if([activityType isEqualToString: UIActivityTypeMessage])
            activityTypeString = @"Message";
        
        if([activityType isEqualToString: UIActivityTypePostToTwitter])
            activityTypeString = @"Twitter";
        
        if([activityType isEqualToString: UIActivityTypePostToFacebook])
            activityTypeString = @"Facebook";
        
        if([activityType isEqualToString: UIActivityTypeSaveToCameraRoll])
            activityTypeString = @"Save to camera roll";
        
        
        // Create dictionary to pass to analytics
        NSDictionary *dimensions = @{
                                     // Activity type
                                     @"activityType": activityTypeString,
                                     // Did the user complete the activity?
                                     @"completed": completedFlag
                                     };
        
        // Make call to analytics of action taken
        
        // Reset flags
        [self resetFlags];
        
        // Reset buttons
        [self resetButtonIcons];
    }];
    
    
    [self presentViewController:activityViewController
                       animated:YES
                     completion:nil];

}
- (IBAction)clickShareButton:(id)sender
{
    if (_freezeOn) {
        [self sharePhoto];
    }
}


#pragma mark Layout Animated
- (void)layoutAnimated:(BOOL)animated
{
    CGRect contentFrame = self.view.bounds;
    
    // all we need to do is ask the banner for a size that fits into the layout area we are using
    CGSize sizeForBanner = [_bannerView sizeThatFits:contentFrame.size];
    
    // compute the ad banner frame
    CGRect bannerFrame = _bannerView.frame;
    if (_bannerView.bannerLoaded) {
        
        // bring the ad into view
        contentFrame.size.height -= sizeForBanner.height;   // shrink down content frame to fit the banner below it
        bannerFrame.origin.y = contentFrame.size.height;
        bannerFrame.size.height = sizeForBanner.height;
        bannerFrame.size.width = sizeForBanner.width;
        
        // if the ad is available and loaded, shrink down the content frame to fit the banner below it,
        // we do this by modifying the vertical bottom constraint constant to equal the banner's height
        //
        NSLayoutConstraint *verticalTopConstraint = self.topConstraint;
        verticalTopConstraint.constant = sizeForBanner.height;
        [self.view layoutSubviews];
        
    } else {
        // hide the banner off screen further off the bottom
        bannerFrame.origin.y = contentFrame.size.height;
    }
    
    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{

        _bannerView.frame = bannerFrame;
    }];
}

#pragma mark Ad Banner
- (void) bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!_purchased) {
        _bannerView.hidden = FALSE;
    }
}

- (void) bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"Ad didFailToReceiveAdWithError %@", error);
    
    _bannerView.hidden = TRUE;
    
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    NSLog(@"Banner view is beginning an ad action");
    // pause audio...
    
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    NSLog(@"Banner view is finishing an ad action");
    // resume audio ...
}



@end
