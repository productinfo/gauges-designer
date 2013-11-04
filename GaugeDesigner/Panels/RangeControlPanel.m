//
//  RangeControlPanel.m
//  GaugeDesigner
//
//  Copyright (c) 2013 Scott Logic. All rights reserved.
//

#import "RangeControlPanel.h"
#import "CustomControls.h"
#import "CustomSlider.h"
#import "ViewController.h"
#import "ColorPickerController.h"

#import <ShinobiGauges/ShinobiGauges.h>

@implementation RangeControlPanel
{
    //QR sliders
    CustomSlider *qrInnerRadius;
    CustomSlider *qrOuterRadius;
    CustomSlider *qrBorderWidth;
    
    //Fill color sliders
    UISwitch *showFillColor;
    CustomSlider *fillInnerRadius;
    CustomSlider *fillOuterRadius;
    CustomSlider *fillBorderWidth;
    
    //Color box
    UIView *qrBorder;
    UIView *fillColor;
    UIView *fillBorder;

    UIPopoverController *popoverController;
    UIView *currentColorBox;
    ViewController *parentController;
}

- (id)initWithFrame:(CGRect)frame forController:(ViewController *)controller
{
    self = [super initWithFrame:frame];
    if (self) {
        parentController = controller;
        
        UISwitch *qrActive = [CustomControls switchWithTarget:self withCallback:@selector(setQualitativeRangeActive:)];
        [self addManagedSubview:[CustomControls viewWithTitle:@"Range Displayed:" control:qrActive colorBox:nil]];
        
        qrInnerRadius = [[CustomSlider alloc] initWithTarget:self andCallback:@selector(setQRInnerRadius:)];
        [self addManagedSubview:[CustomControls viewWithTitle:@"Inner Radius:" control:qrInnerRadius colorBox:nil]];
        
        qrOuterRadius = [[CustomSlider alloc] initWithTarget:self andCallback:@selector(setQROuterRadius:)];
        [self addManagedSubview:[CustomControls viewWithTitle:@"Outer Radius:" control:qrOuterRadius colorBox:nil]];
        
        qrBorderWidth = [[CustomSlider alloc] initWithTarget:self andCallback:@selector(setQRBorderWidth:)];
        qrBorderWidth.maximumValue = 30;
        qrBorder =[CustomControls colorBoxWithType:COLORBOX_RANGE_BORDER withTarget:self];
        [self addManagedSubview:[CustomControls viewWithTitle:@"Border Width:" control:qrBorderWidth colorBox:qrBorder]];
        
        showFillColor = [CustomControls switchWithTarget:self withCallback:@selector(setFillToValue:)];
        fillColor =[CustomControls colorBoxWithType:COLORBOX_FILL withTarget:self];
        [self addManagedSubview:[CustomControls viewWithTitle:@"Fill Color:" control:showFillColor colorBox:fillColor]];
        
        fillInnerRadius = [[CustomSlider alloc] initWithTarget:self andCallback:@selector(setFillInnerRadius:)];
        [self addManagedSubview:[CustomControls viewWithTitle:@"Inner Radius:" control:fillInnerRadius colorBox:nil]];
        
        fillOuterRadius = [[CustomSlider alloc] initWithTarget:self andCallback:@selector(setFillOuterRadius:)];
        [self addManagedSubview:[CustomControls viewWithTitle:@"Outer Radius:" control:fillOuterRadius colorBox:nil]];
        
        fillBorderWidth = [[CustomSlider alloc] initWithTarget:self andCallback:@selector(setFillBorderWidth:)];
        fillBorderWidth.maximumValue = 30;
        fillBorder =[CustomControls colorBoxWithType:COLORBOX_FILL_BORDER withTarget:self];
        [self addManagedSubview:[CustomControls viewWithTitle:@"Border Width:" control:fillBorderWidth colorBox:fillBorder]];
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
    //Qualitative Ranges
    qrBorderWidth.value = gauge.style.qualitativeRangeBorderWidth;
    qrInnerRadius.value = gauge.style.qualitativeInnerPosition;
    qrOuterRadius.value = gauge.style.qualitativeOuterPosition;
    
    qrBorder.backgroundColor = gauge.style.qualitativeRangeBorderColor;
    
    //Fill value
    showFillColor.on = gauge.style.fillToValue;
    fillBorderWidth.value = gauge.style.fillValueBorderWidth;
    fillInnerRadius.value = gauge.style.fillValueInnerRadius;
    fillOuterRadius.value = gauge.style.fillValueOuterRadius;
    fillColor.backgroundColor = gauge.style.fillValueColor;
    fillBorder.backgroundColor = gauge.style.fillValueBorderColor;
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
        case COLORBOX_RANGE_BORDER: parentController.gauge.style.qualitativeRangeBorderColor = colorPicker.selectedColor;
            break;
        case COLORBOX_FILL: parentController.gauge.style.fillValueColor = colorPicker.selectedColor;
            break;
        case COLORBOX_FILL_BORDER: parentController.gauge.style.fillValueBorderColor = colorPicker.selectedColor;
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

-(void)setQRInnerRadius:(UISlider *)sender
{
    parentController.gauge.style.qualitativeInnerPosition = sender.value;
}

-(void)setQROuterRadius:(UISlider *)sender
{
    parentController.gauge.style.qualitativeOuterPosition = sender.value;
}

-(void)setQRBorderWidth:(UISlider *)sender
{
    parentController.gauge.style.qualitativeRangeBorderWidth = sender.value;
}

-(void)setQualitativeRangeActive:(UISwitch *)sender
{
    if (sender.on)
    {
        parentController.gauge.qualitativeRanges = @[[SGaugeQualitativeRange rangeWithMinimum:@35 withMaximum:@60 withColor:[UIColor greenColor]],
                                             [SGaugeQualitativeRange rangeWithMinimum:@60 withMaximum:@75 withColor:[UIColor orangeColor]],
                                             [SGaugeQualitativeRange rangeWithMinimum:@75 withMaximum:nil withColor:[UIColor redColor]]];
    }
    else
    {
        parentController.gauge.qualitativeRanges = nil;
    }
}

-(void)setFillToValue:(UISwitch *)sender
{
    parentController.gauge.style.fillToValue = sender.on;
}

-(void)setFillInnerRadius:(UISlider *)sender
{
    parentController.gauge.style.fillValueInnerRadius = sender.value;
}

-(void)setFillOuterRadius:(UISlider *)sender
{
    parentController.gauge.style.fillValueOuterRadius = sender.value;
}

-(void)setFillBorderWidth:(UISlider *)sender
{
    parentController.gauge.style.fillValueBorderWidth = sender.value;
}

@end
