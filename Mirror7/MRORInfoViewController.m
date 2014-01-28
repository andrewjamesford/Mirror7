//
//  MRORInfoViewController.m
//  MirrorMirror
//
//  Created by Andrew Ford on 2/10/13.
//  Copyright (c) 2013 Andrew Ford. All rights reserved.
//

#import "MRORInfoViewController.h"
#import "MRORMainViewController.h"
#import "REFrostedViewController.h"
#import "IonIcons.h"

@interface MRORInfoViewController ()

@property (weak, nonatomic) IBOutlet UIButton *btnRemoveAds;
@property (weak, nonatomic) IBOutlet UIButton *btnFollow;
@property (weak, nonatomic) IBOutlet UIButton *btnWebsite;
@property (weak, nonatomic) IBOutlet UIButton *btnEmail;
@property (weak, nonatomic) IBOutlet UIButton *btnRate;
@property (weak, nonatomic) IBOutlet UIButton *btnSignUp;
@property (weak, nonatomic) IBOutlet UIButton *btnLogo;

@property UIColor *currentColor;
@property UIColor *tableTextColor;
@property UIColor *tableIconColor;
@property UIColor *tableIconColorDisabled;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellWebsite;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellFollow;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellRemoveAds;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellEmail;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellRate;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellSignUp;

@property (weak, nonatomic) IBOutlet UITableView *tableInfo;

@property (weak, nonatomic) IBOutlet UIButton *btnClose;

@property BOOL *purchased;

@end

@implementation MRORInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _currentColor = kColorBlack;
    _tableTextColor = kColorBlack;
    _tableIconColor = kColorBlue;
    _tableIconColorDisabled = kColorGrey;
    _btnClose.tintColor = kColorBlue;
    
    
    _btnFollow.tintColor = _btnRemoveAds.tintColor = _btnWebsite.tintColor = _btnEmail.tintColor = _btnRate.tintColor = _btnSignUp.tintColor = _tableTextColor;
    
    UIImage *imageCart = [IonIcons imageWithIcon:icon_ios7_cart_outline
                                         iconColor:_tableIconColor
                                          iconSize:kTableIconSize
                                         imageSize:kTableIconShape ];
    
    
    UIImage *imageTwitter = [IonIcons imageWithIcon:icon_social_twitter_outline
                                       iconColor:_tableIconColor
                                        iconSize:kTableIconSize
                                       imageSize:kTableIconShape];
    
    UIImage *imageWeb = [IonIcons imageWithIcon:icon_ios7_world_outline
                                       iconColor:_tableIconColor
                                        iconSize:kTableIconSize
                                       imageSize:kTableIconShape];
    
    UIImage *imageEmail = [IonIcons imageWithIcon:icon_ios7_email_outline
                                      iconColor:_tableIconColor
                                       iconSize:kTableIconSize
                                      imageSize:kTableIconShape];
    
    UIImage *imageRate = [IonIcons imageWithIcon:icon_ios7_star_outline
                                        iconColor:_tableIconColor
                                         iconSize:kTableIconSize
                                        imageSize:kTableIconShape];
    
    UIImage *imagePlane = [IonIcons imageWithIcon:icon_ios7_paperplane_outline
                                       iconColor:_tableIconColor
                                        iconSize:kTableIconSize
                                       imageSize:kTableIconShape];

    // Check IAP is purchased
    _purchased = [[NSUserDefaults standardUserDefaults] boolForKey:kIAPRemoveAds];
    
    if (_purchased) {
        [_btnRemoveAds setTitle:@"Ads have been removed" forState:normal];
        imageCart = [IonIcons imageWithIcon:icon_ios7_cart_outline
                                   iconColor:_tableIconColorDisabled
                                    iconSize:kTableIconSize
                                   imageSize:kTableIconShape ];
    }
    
    [_btnFollow setImage:imageTwitter forState:normal];
    [_btnRemoveAds setImage:imageCart forState:normal];
    [_btnWebsite setImage:imageWeb forState:normal];
    [_btnEmail setImage:imageEmail forState:normal];
    [_btnRate setImage:imageRate forState:normal];
    [_btnSignUp setImage:imagePlane forState:normal];
    
}

#pragma mark - Populate table
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) return _cellFollow;
    if (indexPath.row == 1) return _cellWebsite;
    if (indexPath.row == 2) return _cellRemoveAds;
// Show table options
//    if (indexPath.row == 1) return _cellEmail;
//    if (indexPath.row == 4) return _cellRate;
//    if (indexPath.row == 5) return _cellSignUp;
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (IBAction)logoTap:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://taperiffic.com"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)closeButton:(id)sender {
    // Hide the info controller
    [self.frostedViewController hideMenuViewController];
}

#pragma mark - Table button actions

- (IBAction)followTwitter:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://twitter.com/taperiffic"]];
}

- (IBAction)websiteTaperiffic:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://taperiffic.com"]];
}

- (IBAction)rateThisApp:(id)sender {
    NSString * theUrl = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id={YOUR APP ID}&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:theUrl]];
}

- (IBAction)emailTaperiffic:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"mailto:?to=hello@taperiffic.com"]];
}

- (IBAction)removeAds:(id)sender {
    // Remove Ads clicked
    if (!_purchased) {
        // Check if user has purchased remove ads
    }
    else {
        // Alert view
        [[[UIAlertView alloc] initWithTitle:@"Ads Removed"
                                    message:@"Thank you you have already purchased ad removal"
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
    }
}

- (IBAction)signUp:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://taperiffic.com#signup"]];
}

@end
