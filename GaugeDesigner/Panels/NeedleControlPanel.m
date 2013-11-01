//
//  NeedleControlPanel.m
//  GaugeDesigner
//
//  Copyright (c) 2013 Scott Logic. All rights reserved.
//

#import "NeedleControlPanel.h"
#import "CustomSlider.h"
#import "CustomControls.h"
#import "ViewController.h"
#import "ColorPickerController.h"

#import <ShinobiGauges/ShinobiGauges.h>

@implementation NeedleControlPanel
{
    //Needle sliders
    CustomSlider *needleLength;
    CustomSlider *needleWidth;
    CustomSlider *needleBorderWidth;
    CustomSlider *knobRadius;
    CustomSlider *knobBorderWidth;
    
    //Needle colorboxes
    UIView *needleColor;
    UIView *needleBorderColor;
    UIView *knobColor;
    UIView *knobBorderColor;
    
    UIPopoverController *popoverController;
    UIView *currentColorBox;
    ViewController *parentController;
}
- (id)initWithFrame:(CGRect)frame forController:(ViewController *)controller
{
    self = [super initWithFrame:frame];
    if (self) {
        parentController = controller;
        
        //Needle arrow
        needleLength = [[CustomSlider alloc] initWithTarget:self andCallback:@selector(setNeedleLength:)];
        needleColor =[CustomControls colorBoxWithType:COLORBOX_NEEDLE withTarget:self];
        [self addManagedSubview:[CustomControls viewWithTitle:@"Needle Length:" control:needleLength colorBox:needleColor]];
        
        needleWidth = [[CustomSlider alloc] initWithTarget:self andCallback:@selector(setNeedleWidth:)];
        needleWidth.maximumValue = 50;
        [self addManagedSubview:[CustomControls viewWithTitle:@"Needle Width:" control:needleWidth colorBox:nil]];
        
        needleBorderWidth = [[CustomSlider alloc] initWithTarget:self andCallback:@selector(setNeedleBorderWidth:)];
        needleBorderWidth.maximumValue = 50;
        needleBorderColor =[CustomControls colorBoxWithType:COLORBOX_NEEDLE_BORDER withTarget:self];
        [self addManagedSubview:[CustomControls viewWithTitle:@"Needle Border:" control:needleBorderWidth colorBox:needleBorderColor]];
        
        //Needle knob
        knobRadius = [[CustomSlider alloc] initWithTarget:self andCallback:@selector(setKnobRadius:)];
        knobRadius.maximumValue = 50;
        knobColor =[CustomControls colorBoxWithType:COLORBOX_KNOB withTarget:self];
        [self addManagedSubview:[CustomControls viewWithTitle:@"Knob Radius:" control:knobRadius colorBox:knobColor]];
        
        knobBorderWidth = [[CustomSlider alloc] initWithTarget:self andCallback:@selector(setKnobBorderWidth:)];
        knobBorderWidth.maximumValue = 50;
        knobBorderColor =[CustomControls colorBoxWithType:COLORBOX_KNOB_BORDER withTarget:self];
        [self addManagedSubview:[CustomControls viewWithTitle:@"Knob Border:" control:knobBorderWidth colorBox:knobBorderColor]];
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
    needleLength.value = gauge.style.needleLength;
    needleWidth.value = gauge.style.needleWidth;
    knobRadius.value = gauge.style.knobRadius;
    needleBorderWidth.value = gauge.style.needleBorderWidth;
    knobBorderWidth.value = gauge.style.knobBorderWidth;
    
    needleColor.backgroundColor = gauge.style.needleColor;
    needleBorderColor.backgroundColor = gauge.style.needleBorderColor;
    knobColor.backgroundColor = gauge.style.knobColor;
    knobBorderColor.backgroundColor = gauge.style.knobBorderColor;

}

#pragma mark - Color picker callbacks

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
        case COLORBOX_NEEDLE: parentController.gauge.style.needleColor = colorPicker.selectedColor;
            break;
        case COLORBOX_NEEDLE_BORDER: parentController.gauge.style.needleBorderColor = colorPicker.selectedColor;
            break;
        case COLORBOX_KNOB: parentController.gauge.style.knobColor = colorPicker.selectedColor;
            break;
        case COLORBOX_KNOB_BORDER: parentController.gauge.style.knobBorderColor = colorPicker.selectedColor;
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

-(void)setNeedleLength:(UISlider*)sender
{
    parentController.gauge.style.needleLength = sender.value;
}

-(void)setNeedleWidth:(UISlider*)sender
{
    parentController.gauge.style.needleWidth = sender.value;
}

-(void)setNeedleBorderWidth:(UISlider*)sender
{
    parentController.gauge.style.needleBorderWidth = sender.value;
}

-(void)setKnobRadius:(UISlider*)sender
{
    parentController.gauge.style.knobRadius = sender.value;
}

-(void)setKnobBorderWidth:(UISlider*)sender
{
    parentController.gauge.style.knobBorderWidth = sender.value;
}

@end
