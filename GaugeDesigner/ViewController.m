//
//  ViewController.m
//  GaugeDesigner
//
//  Copyright (c) 2013 Scott Logic. All rights reserved.
//

#import "ViewController.h"

#import "ControlPanel.h"

#import "GaugeControlPanel.h"
#import "AxisControlPanel.h"
#import "NeedleControlPanel.h"
#import "RangeControlPanel.h"
#import "CustomSlider.h"

#import <ShinobiGauges/ShinobiGauges.h>
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()
{
    UIView<ControlPanel> *gaugeControl;
    UIView<ControlPanel> *axisControl;
    UIView<ControlPanel> *needleControl;
    UIView<ControlPanel> *rangeControl;
    
    UIView<ControlPanel> *currentView;
    
    CustomSlider *valueSlider;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [ShinobiGauges setTrialKey:@""]; // Add trial key here
    
    self.gauge = [[SGaugeRadial alloc] initWithFrame:CGRectMake(0, 0, 300, 300) fromMinimum:@0 toMaximum:@100];
    [self.placeholder addSubview:self.gauge];
    
    gaugeControl = [[GaugeControlPanel alloc] initWithFrame:_controlPanel.bounds forController:self];
    axisControl = [[AxisControlPanel alloc] initWithFrame:_controlPanel.bounds forController:self];
    needleControl = [[NeedleControlPanel alloc] initWithFrame:_controlPanel.bounds forController:self];
    rangeControl = [[RangeControlPanel alloc] initWithFrame:_controlPanel.bounds forController:self];

    currentView = gaugeControl;
    [self.controlPanel addSubview:currentView];
    self.controlPanel.backgroundColor = [UIColor colorWithRed:243.0/256 green:240.0/256 blue:1 alpha:1];
    self.controlPanel.layer.shadowRadius = 2.f;
    self.controlPanel.layer.shadowOffset = CGSizeMake(0, -3);
    self.controlPanel.layer.shadowOpacity = 0.5;
    self.controlPanel.layer.shadowColor = [UIColor blackColor].CGColor;
    [currentView updateWithGauge:self.gauge];
    
    //Set first item as selected
    [self.tabBar setSelectedItem:[self.tabBar.items firstObject]];
}

- (void)viewDidUnload {
    [self setControlPanel:nil];
    [self setPlaceholder:nil];
    [self setLabels:nil];
    [super viewDidUnload];
}

-(IBAction)setValue:(UISlider*)sender
{
    self.gauge.value = sender.value;
}

- (IBAction)setGaugeType:(UISegmentedControl *)sender {
    //Clean up placeholder
    [self.gauge removeFromSuperview];
    
    //Save custom values
    SGaugeStyle *style = [self.gauge.style copy];
    float value = self.gauge.value;
    NSArray *ranges = self.gauge.qualitativeRanges;
    
    //Create new gauge
    switch (sender.selectedSegmentIndex)
    {
        case 0: //Radial
            self.gauge = [[SGaugeRadial alloc] initWithFrame:CGRectMake(0, 0, 300, 300) fromMinimum:@0 toMaximum:@100];
            break;
        case 1: //Linear
            self.gauge = [[SGaugeLinear alloc] initWithFrame:CGRectMake(0, 100, 300, 50) fromMinimum:@0 toMaximum:@100];
            break;
    }
    
    [self.placeholder addSubview:self.gauge];
    
    //Restore values
    self.gauge.style = style;
    self.gauge.value = value;
    self.gauge.qualitativeRanges = ranges;
    
    [currentView updateWithGauge:self.gauge];
}

-(IBAction)setTheme:(UISegmentedControl*)sender {
    switch (sender.selectedSegmentIndex)
    {
        case 0: //Light Style
            self.gauge.style = [SGaugeLightStyle new];
            [self setBackgroundColor:[UIColor blackColor]];
            break;
        case 1: //Dark Style
            self.gauge.style = [SGaugeDarkStyle new];
            [self setBackgroundColor:[UIColor whiteColor]];
            break;
        case 2: //Dashboard Style
            self.gauge.style = [SGaugeDashboardStyle new];
            [self setBackgroundColor:[UIColor whiteColor]];
    }
    
    [currentView updateWithGauge:self.gauge];
}

-(void)setBackgroundColor:(UIColor*)backgroundColor
{
    UIColor *textColor = (backgroundColor == [UIColor whiteColor]) ? [UIColor blackColor] : [UIColor whiteColor];
    
    for (UILabel *label in _labels)
        label.textColor = textColor;
    
    self.view.backgroundColor = backgroundColor;
}

#pragma mark - Tab Bar Delegate methods

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    //Remove current control panels
    for (UIView *subview in [_controlPanel.subviews copy])
        [subview removeFromSuperview];
    
    if ([item.title isEqualToString:@"Gauge"])
        currentView = gaugeControl;
    else if ([item.title isEqualToString:@"Axis"])
        currentView = axisControl;
    else if ([item.title isEqualToString:@"Needle"])
        currentView = needleControl;
    else if ([item.title isEqualToString:@"Range"])
        currentView = rangeControl;
    
    [_controlPanel addSubview:currentView];
    [currentView updateWithGauge:self.gauge];
}

@end
