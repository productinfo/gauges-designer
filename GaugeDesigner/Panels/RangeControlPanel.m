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
    
    //Color box
    UIView *qrBorder;

    UIPopoverController *popoverController;
    UIView *currentColorBox;
    ViewController *parentController;
}

- (id)initWithFrame:(CGRect)frame forController:(ViewController *)controller
{
    self = [super initWithFrame:frame];
    if (self) {
        parentController = controller;
        
        [self addSubview:[CustomControls labelWithTitle:@"Qualitative Range:" withOrigin:CGPointMake(75, 42)]];
        [self addSubview:[CustomControls switchWithOrigin:CGPointMake(230, 40) withTarget:self withCallback:@selector(setQualitativeRangeActive:)]];
        
        qrInnerRadius = [[CustomSlider alloc] initWithTitle:@"Inner radius" withTarget:self andCallback:@selector(setQRInnerRadius:)];
        qrInnerRadius.center = CGPointMake(385, 80);
        [self addSubview:qrInnerRadius];
        
        qrOuterRadius = [[CustomSlider alloc] initWithTitle:@"Outer radius" withTarget:self andCallback:@selector(setQROuterRadius:)];
        qrOuterRadius.center = CGPointMake(385, 110);
        [self addSubview:qrOuterRadius];
        
        qrBorderWidth = [[CustomSlider alloc] initWithTitle:@"Border width" withTarget:self andCallback:@selector(setQRBorderWidth:)];
        qrBorderWidth.center = CGPointMake(385, 140);
        qrBorderWidth.maximumValue = 30;
        [self addSubview:qrBorderWidth];
        
        qrBorder = [CustomControls colorBoxWithCenter:CGPointMake(720, 140) withType:COLORBOX_RANGE_BORDER withTarget:self];
        [self addSubview:qrBorder];
        
        [self addSubview:[CustomControls labelWithTitle:@"Color active:" withOrigin:CGPointMake(75, 172)]];
        [self addSubview:[CustomControls switchWithOrigin:CGPointMake(230, 170) withTarget:self withCallback:@selector(setColorActive:)]];
    }
    return self;
}

-(void)updateWithGauge:(SGauge *)gauge
{
    qrBorderWidth.value = gauge.style.qualitativeRangeBorderWidth;
    qrInnerRadius.value = gauge.style.qualitativeInnerRadius;
    qrOuterRadius.value = gauge.style.qualitativeOuterRadius;
    
    qrBorder.backgroundColor = gauge.style.qualitativeRangeBorderColor;
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
    parentController.gauge.style.qualitativeInnerRadius = sender.value;
}

-(void)setQROuterRadius:(UISlider *)sender
{
    parentController.gauge.style.qualitativeOuterRadius = sender.value;
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

-(void)setColorActive:(UISwitch *)sender
{
    parentController.gauge.colorActiveSegment = sender.on;
}

@end
