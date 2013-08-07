//
//  AxisControlPanel.m
//  GaugeDesigner
//
//  Copyright (c) 2013 Scott Logic. All rights reserved.
//

#import "AxisControlPanel.h"
#import "CustomSlider.h"
#import "CustomControls.h"
#import "ViewController.h"
#import "ColorPickerController.h"

#import <ShinobiGauges/ShinobiGauges.h>

@implementation AxisControlPanel
{
    //Axis sliders
    CustomSlider *majorTickLength;
    CustomSlider *minorTickLength;
    CustomSlider *majorTickFrequency;
    CustomSlider *minorTickFrequency;
    CustomSlider *tickLabelOffset;
    CustomSlider *baselineWidth;
    CustomSlider *baselineOffset;
    UISwitch *labelsRotate;
    UISwitch *showTicks;
    UISegmentedControl *tickAlign;
    
    //Color boxes
    UIView *majorTickColor;
    UIView *minorTickColor;
    UIView *tickLabelColor;
    UIView *baselineColor;

    UIPopoverController *popoverController;
    UIView *currentColorBox;
    ViewController *parentController;
}

- (id)initWithFrame:(CGRect)frame forController:(ViewController *)controller
{
    self = [super initWithFrame:frame];
    if (self) {
        parentController = controller;

        // Tick marks
        majorTickFrequency = [[CustomSlider alloc] initWithTitle:@"Major frequency" withTarget:self andCallback:@selector(setMajorFrequency:)];
        majorTickFrequency.center = CGPointMake(385, 50);
        majorTickFrequency.maximumValue = 100;
        [self addSubview:majorTickFrequency];
        
        majorTickColor =[CustomControls colorBoxWithCenter:CGPointMake(720, 50) withType:COLORBOX_MAJOR_TICK withTarget:self];
        [self addSubview:majorTickColor];
        
        minorTickFrequency = [[CustomSlider alloc] initWithTitle:@"Minor frequency" withTarget:self andCallback:@selector(setMinorFrequency:)];
        minorTickFrequency.center = CGPointMake(385, 80);
        minorTickFrequency.maximumValue = 100;
        [self addSubview:minorTickFrequency];
        
        minorTickColor = [CustomControls colorBoxWithCenter:CGPointMake(720, 80) withType:COLORBOX_MINOR_TICK withTarget:self];
        [self addSubview:minorTickColor];
        
        majorTickLength = [[CustomSlider alloc] initWithTitle:@"Major ticksize" withTarget:self andCallback:@selector(setMajorTickSize:)];
        majorTickLength.center = CGPointMake(385, 110);
        majorTickLength.maximumValue = 50;
        [self addSubview:majorTickLength];
        
        minorTickLength = [[CustomSlider alloc] initWithTitle:@"Minor ticksize" withTarget:self andCallback:@selector(setMinorTickSize:)];
        minorTickLength.center = CGPointMake(385, 140);
        minorTickLength.maximumValue = 50;
        [self addSubview:minorTickLength];
        
        //Tick Labels
        tickLabelOffset = [[CustomSlider alloc] initWithTitle:@"Tick label offset" withTarget:self andCallback:@selector(setTickLabelOffset:)];
        tickLabelOffset.center = CGPointMake(385, 170);
        tickLabelOffset.minimumValue = -100;
        tickLabelOffset.maximumValue = 100;
        [self addSubview:tickLabelOffset];
        
        tickLabelColor =[CustomControls colorBoxWithCenter:CGPointMake(720, 170) withType:COLORBOX_TICK_LABEL withTarget:self];
        [self addSubview:tickLabelColor];
        
        //Baseline
        baselineWidth = [[CustomSlider alloc] initWithTitle:@"Baseline width" withTarget:self andCallback:@selector(setBaselineWidth:)];
        baselineWidth.center = CGPointMake(385, 200);
        baselineWidth.maximumValue = 20;
        [self addSubview:baselineWidth];
        
        baselineColor =[CustomControls colorBoxWithCenter:CGPointMake(720, 200) withType:COLORBOX_BASELINE withTarget:self];
        [self addSubview:baselineColor];
        
        baselineOffset = [[CustomSlider alloc] initWithTitle:@"Baseline offset" withTarget:self andCallback:@selector(setBaselineOffset:)];
        baselineOffset.center = CGPointMake(385, 230);
        baselineOffset.minimumValue = -100;
        baselineOffset.maximumValue = 100;
        [self addSubview:baselineOffset];
        
        [self addSubview:[CustomControls labelWithTitle:@"Rotate Labels:" withOrigin:CGPointMake(75, 252)]];
        labelsRotate = [CustomControls switchWithOrigin:CGPointMake(230, 250) withTarget:self withCallback:@selector(setLabelsRotate:)];
        [self addSubview:labelsRotate];
        
        [self addSubview:[CustomControls labelWithTitle:@"Show Ticklabels:" withOrigin:CGPointMake(400, 252)]];
        showTicks = [CustomControls switchWithOrigin:CGPointMake(560, 250) withTarget:self withCallback:@selector(setShowTickLabels:)];
        [self addSubview:showTicks];
        
        [self addSubview:[CustomControls labelWithTitle:@"Tick Alignment:" withOrigin:CGPointMake(75, 292)]];
        tickAlign = [[UISegmentedControl alloc] initWithItems:@[@"Top", @"Center", @"Bottom"]];
        tickAlign.center = CGPointMake(350, 310);
        [tickAlign addTarget:self action:@selector(setTickAlignment:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:tickAlign];
    }
    return self;
}

-(void)updateWithGauge:(SGauge *)gauge
{
    majorTickFrequency.value = gauge.axis.majorTickFrequency;
    minorTickFrequency.value = gauge.axis.minorTickFrequency;
    majorTickLength.value = gauge.style.majorTickSize.height;
    minorTickLength.value = gauge.style.minorTickSize.height;
    tickLabelOffset.value = gauge.style.tickLabelOffset;
    baselineOffset.value = gauge.style.tickBaselineOffset;
    baselineWidth.value = gauge.style.tickBaselineWidth;
    labelsRotate.on = gauge.style.tickLabelsRotate;
    showTicks.on = gauge.style.showTickLabels;
    tickAlign.selectedSegmentIndex = 0;
    
    majorTickColor.backgroundColor = gauge.style.majorTickColor;
    minorTickColor.backgroundColor = gauge.style.minorTickColor;
    tickLabelColor.backgroundColor = gauge.style.tickLabelColor;
    baselineColor.backgroundColor = gauge.style.tickBaselineColor;
}

#pragma mark - Color popup callbacks

-(void)tappedColorBox:(UITapGestureRecognizer*)sender;
{
    currentColorBox = sender.view;
    
    CGRect popoverOriginRect = sender.view.frame;
    [self displayColorPickerWithTitle:@"Color Picker" initialColor:sender.view.backgroundColor popoverOriginRect:popoverOriginRect];
}

- (void)displayColorPickerWithTitle:(NSString*)title initialColor:(UIColor*)color popoverOriginRect:(CGRect)rect
{
    ColorPickerController *colorPickerController = [[ColorPickerController alloc] initWithColor:color andTitle:title];
    colorPickerController.delegate = self;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:colorPickerController];
    popoverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
    [popoverController setPopoverContentSize:CGSizeMake(600, 600)];
    [popoverController presentPopoverFromRect:rect inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(void)colorPickerSaved:(ColorPickerController *)colorPicker
{
    currentColorBox.backgroundColor = colorPicker.selectedColor;
    switch (currentColorBox.tag)
    {
        case COLORBOX_MAJOR_TICK: parentController.gauge.style.majorTickColor = colorPicker.selectedColor;
            break;
        case COLORBOX_MINOR_TICK: parentController.gauge.style.minorTickColor = colorPicker.selectedColor;
            break;
        case COLORBOX_BASELINE: parentController.gauge.style.tickBaselineColor = colorPicker.selectedColor;
            break;
        case COLORBOX_TICK_LABEL: parentController.gauge.style.tickLabelColor = colorPicker.selectedColor;
            break;
    }
    [popoverController dismissPopoverAnimated:NO];
}

-(void)colorPickerCancelled:(ColorPickerController *)controller
{
    currentColorBox = nil;
    [popoverController dismissPopoverAnimated:NO];
}

#pragma mark - Control callbacks

-(void)setMajorFrequency:(UISlider*)sender
{
    parentController.gauge.axis.majorTickFrequency = roundf(sender.value);
}

-(void)setMinorFrequency:(UISlider*)sender
{
    parentController.gauge.axis.minorTickFrequency = roundf(sender.value);
}

-(void)setMajorTickSize:(UISlider*)sender
{
    parentController.gauge.style.majorTickSize = CGSizeMake(2, sender.value);
}

-(void)setMinorTickSize:(UISlider*)sender
{
    parentController.gauge.style.minorTickSize = CGSizeMake(1, sender.value);
}

-(void)setTickLabelOffset:(UISlider*)sender
{
    parentController.gauge.style.tickLabelOffset = sender.value;
}

-(void)setBaselineWidth:(UISlider*)sender
{
    parentController.gauge.style.tickBaselineWidth = sender.value;
}

-(void)setBaselineOffset:(UISlider*)sender
{
    parentController.gauge.style.tickBaselineOffset = sender.value;
}

-(void)setLabelsRotate:(UISwitch*)sender
{
    parentController.gauge.style.tickLabelsRotate = sender.on;
}

-(void)setShowTickLabels:(UISwitch*)sender
{
    parentController.gauge.style.showTickLabels = sender.on;
}

-(void)setTickAlignment:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex)
    {
        case 0: parentController.gauge.style.tickMarkAlignment = SGaugeTickAlignTop;
            break;
        case 1: parentController.gauge.style.tickMarkAlignment = SGaugeTickAlignCenter;
            break;
        case 2: parentController.gauge.style.tickMarkAlignment = SGaugeTickAlignBottom;
            break;
    }
}
@end
