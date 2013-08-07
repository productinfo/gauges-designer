//
//  ViewController.h
//  GaugeDesigner
//
//  Copyright (c) 2013 Scott Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SGauge;

@interface ViewController : UIViewController<UITabBarDelegate>

@property (weak, nonatomic) IBOutlet UIView *controlPanel;
@property (strong, nonatomic) SGauge *gauge;
@property (weak, nonatomic) IBOutlet UIView *placeholder;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labels;

- (IBAction)setTheme:(UISegmentedControl*)sender;
- (IBAction)setValue:(UISlider*)sender;
- (IBAction)setGaugeType:(UISegmentedControl *)sender;

@end
