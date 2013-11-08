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
    CustomSlider *paddingAroundAxis;
    UISwitch *labelsRotate;
    UISwitch *showTicks;
    UISegmentedControl *tickAlign;
    
    //Axis Mirroring
    UISwitch *mirrorBaseline;
    UISwitch *mirrorLabels;
    UISwitch *mirrorTicks;
    
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
        majorTickFrequency = [[CustomSlider alloc] initWithTarget:self andCallback:@selector(setMajorFrequency:)];
        majorTickFrequency.maximumValue = 100;
        majorTickColor = [CustomControls colorBoxWithType:COLORBOX_MAJOR_TICK withTarget:self];
        [self addManagedSubview:[CustomControls viewWithTitle:@"Major Frequency:" control:majorTickFrequency colorBox:majorTickColor]];
        
        minorTickFrequency = [[CustomSlider alloc] initWithTarget:self andCallback:@selector(setMinorFrequency:)];
        minorTickFrequency.maximumValue = 100;
        minorTickColor = [CustomControls colorBoxWithType:COLORBOX_MINOR_TICK withTarget:self];
        [self addManagedSubview:[CustomControls viewWithTitle:@"Minor Frequency:" control:minorTickFrequency colorBox:minorTickColor]];
        
        majorTickLength = [[CustomSlider alloc] initWithTarget:self andCallback:@selector(setMajorTickSize:)];
        majorTickLength.maximumValue = 50;
        [self addManagedSubview:[CustomControls viewWithTitle:@"Minor Ticksize:" control:majorTickLength colorBox:nil]];
        
        minorTickLength = [[CustomSlider alloc] initWithTarget:self andCallback:@selector(setMinorTickSize:)];
        minorTickLength.maximumValue = 50;
        [self addManagedSubview:[CustomControls viewWithTitle:@"Minor Ticksize:" control:minorTickLength colorBox:nil]];
        
        //Tick Labels
        tickLabelOffset = [[CustomSlider alloc] initWithTarget:self andCallback:@selector(setTickLabelOffset:)];
        tickLabelOffset.minimumValue = -100;
        tickLabelOffset.maximumValue = 100;
        tickLabelColor = [CustomControls colorBoxWithType:COLORBOX_TICK_LABEL withTarget:self];
        [self addManagedSubview:[CustomControls viewWithTitle:@"Tick Label Offset:" control:tickLabelOffset colorBox:tickLabelColor]];
        
        paddingAroundAxis = [[CustomSlider alloc] initWithTarget:self andCallback:@selector(setPaddingAroundAxis:)];
        paddingAroundAxis.maximumValue = 100;
        [self addManagedSubview:[CustomControls viewWithTitle:@"Label padding" control:paddingAroundAxis colorBox:nil]];
        
        //Baseline
        baselineWidth = [[CustomSlider alloc] initWithTarget:self andCallback:@selector(setBaselineWidth:)];
        baselineWidth.maximumValue = 20;
        baselineColor = [CustomControls colorBoxWithType:COLORBOX_BASELINE withTarget:self];
        [self addManagedSubview:[CustomControls viewWithTitle:@"Baseline Width:" control:baselineWidth colorBox:baselineColor]];
        
        baselineOffset = [[CustomSlider alloc] initWithTarget:self andCallback:@selector(setBaselineOffset:)];
        baselineOffset.minimumValue = 0;
        baselineOffset.maximumValue = 2;
        [self addManagedSubview:[CustomControls viewWithTitle:@"Baseline Offset:" control:baselineOffset colorBox:nil]];
        
        labelsRotate = [CustomControls switchWithTarget:self withCallback:@selector(setLabelsRotate:)];
        [self addManagedSubview:[CustomControls viewWithTitle:@"Rotate Labels:" control:labelsRotate colorBox:nil]];
        
        showTicks = [CustomControls switchWithTarget:self withCallback:@selector(setShowTickLabels:)];
        [self addManagedSubview:[CustomControls viewWithTitle:@"Show Ticklabels:" control:showTicks colorBox:nil]];
        
        tickAlign = [[UISegmentedControl alloc] initWithItems:@[@"Top", @"Center", @"Bottom"]];
        [tickAlign addTarget:self action:@selector(setTickAlignment:) forControlEvents:UIControlEventValueChanged];
        [self addManagedSubview:[CustomControls viewWithTitle:@"Tick Alignment:" control:tickAlign colorBox:nil]];
        
        mirrorLabels = [CustomControls switchWithTarget:self withCallback:@selector(setMirrorLabels:)];
        [self addManagedSubview:[CustomControls viewWithTitle:@"Mirror Labels:" control:mirrorLabels colorBox:nil]];
        
        mirrorTicks = [CustomControls switchWithTarget:self withCallback:@selector(setMirrorTicks:)];
        [self addManagedSubview:[CustomControls viewWithTitle:@"Mirror Ticks:" control:mirrorTicks colorBox:nil]];
        
        mirrorBaseline = [CustomControls switchWithTarget:self withCallback:@selector(setMirrorBaseline:)];
        [self addManagedSubview:[CustomControls viewWithTitle:@"Mirror Baseline:" control:mirrorBaseline colorBox:nil]];
    }
    return self;
}

-(void)addManagedSubview:(UIView*)subview
{
    subview.center = CGPointMake(384, 40 + self.subviews.count * 35);
    [self addSubview:subview];
}

-(void)updateWithGauge:(SGauge *)gauge
{
    majorTickFrequency.value = gauge.axis.majorTickFrequency;
    minorTickFrequency.value = gauge.axis.minorTickFrequency;
    majorTickLength.value = gauge.style.majorTickSize.height;
    minorTickLength.value = gauge.style.minorTickSize.height;
    tickLabelOffset.value = gauge.style.tickLabelOffsetFromBaseline;
    baselineOffset.value = gauge.style.tickBaselinePosition;
    baselineWidth.value = gauge.style.tickBaselineWidth;
    labelsRotate.on = gauge.style.tickLabelsRotate;
    showTicks.on = gauge.style.showTickLabels;
    tickAlign.selectedSegmentIndex = 0;
    paddingAroundAxis.value = gauge.style.axisPadding;
    
    //Mirroring
    mirrorLabels.on = gauge.style.axisMirrorBehavior & SGaugeTickMirrorTicklabels;
    mirrorBaseline.on = gauge.style.axisMirrorBehavior & SGaugeTickMirrorBaseline;
    mirrorTicks.on = gauge.style.axisMirrorBehavior & SGaugeTickMirrorTickmarks;
    
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
    parentController.gauge.style.tickLabelOffsetFromBaseline = sender.value;
}

-(void)setPaddingAroundAxis:(UISlider*)sender
{
    parentController.gauge.style.axisPadding = sender.value;
}

-(void)setBaselineWidth:(UISlider*)sender
{
    parentController.gauge.style.tickBaselineWidth = sender.value;
}

-(void)setBaselineOffset:(UISlider*)sender
{
    parentController.gauge.style.tickBaselinePosition = sender.value;
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

-(void)setMirrorTicks:(UISwitch*)sender
{
    if (sender.on)
    {
        parentController.gauge.style.axisMirrorBehavior |= SGaugeTickMirrorTickmarks;
    }
    else
    {
        parentController.gauge.style.axisMirrorBehavior &= ~SGaugeTickMirrorTickmarks;
    }
}

-(void)setMirrorLabels:(UISwitch*)sender
{
    if (sender.on)
    {
        parentController.gauge.style.axisMirrorBehavior |= SGaugeTickMirrorTicklabels;
    }
    else
    {
        parentController.gauge.style.axisMirrorBehavior &= ~SGaugeTickMirrorTicklabels;
    }
}

-(void)setMirrorBaseline:(UISwitch*)sender
{
    if (sender.on)
    {
        parentController.gauge.style.axisMirrorBehavior |= SGaugeTickMirrorBaseline;
    }
    else
    {
        parentController.gauge.style.axisMirrorBehavior &= ~SGaugeTickMirrorBaseline;
    }
}
@end
