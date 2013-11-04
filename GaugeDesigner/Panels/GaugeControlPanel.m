//
//  GaugeControlPanel.m
//  GaugeDesigner
//
//  Copyright (c) 2013 Scott Logic. All rights reserved.
//

#import "GaugeControlPanel.h"
#import "CustomSlider.h"
#import "CustomControls.h"
#import "ColorPickerController.h"
#import "ViewController.h"

#import <ShinobiGauges/ShinobiGauges.h>

@implementation GaugeControlPanel
{
    //Controls
    CustomSlider *sliderStart;
    CustomSlider *sliderEnd;
    UISwitch *isFullCircle;
    CustomSlider *borderSlider;
    CustomSlider *borderFlatSlider;
    UISwitch *showGlass;
    UISwitch *horizontal;
    CustomSlider *cornerRadius;
    
    //Color boxes
    UIView *gaugeInnerBackgroundColor;
    UIView *gaugeOuterBackgroundColor;
    UIView *borderPrimary;
    UIView *borderSecondary;
    UIView *glassColor;

    UIPopoverController *popoverController;
    UIView *currentColorBox;
    ViewController *parentController;
}

- (id)initWithFrame:(CGRect)frame forController:(ViewController *)controller
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        parentController = controller;
        
        //Gauge range
        sliderStart = [[CustomSlider alloc] initWithTarget:self andCallback:@selector(setAngleStart:)];
        sliderEnd = [[CustomSlider alloc] initWithTarget:self andCallback:@selector(setAngleEnd:)];
        sliderStart.minimumValue = -M_PI + 0.001;
        sliderStart.maximumValue = M_PI;
        sliderEnd.minimumValue = -M_PI + 0.001;
        sliderEnd.maximumValue = M_PI;
        sliderStart.center = CGPointMake(385, 50);
        sliderEnd.center = CGPointMake(385, 80);
        gaugeInnerBackgroundColor = [CustomControls colorBoxWithType:COLORBOX_TICKTRACK_PRIMARY withTarget:self];
        gaugeOuterBackgroundColor = [CustomControls colorBoxWithType:COLORBOX_TICKTRACK_SECONDARY withTarget:self];
        [self addManagedSubview:[CustomControls viewWithTitle:@"Angle start:" control:sliderStart colorBox:gaugeInnerBackgroundColor]];
        [self addManagedSubview:[CustomControls viewWithTitle:@"Angle end:" control:sliderEnd colorBox:gaugeOuterBackgroundColor]];
        
        isFullCircle = [CustomControls switchWithTarget:self withCallback:@selector(setFullCircle:)];
        [self addManagedSubview:[CustomControls viewWithTitle:@"Full Circle:" control:isFullCircle colorBox:nil]];
        
        //Bevel
        borderSlider = [[CustomSlider alloc] initWithTarget:self andCallback:@selector(setBorderWidth:)];
        borderSlider.maximumValue = 30;
        borderPrimary =[CustomControls colorBoxWithType:COLORBOX_BORDER_PRIMARY withTarget:self];
        [self addManagedSubview:[CustomControls viewWithTitle:@"Bevel width:" control:borderSlider colorBox:borderPrimary]];
        
        borderFlatSlider = [[CustomSlider alloc] initWithTarget:self andCallback:@selector(setFlatness:)];
        borderSecondary = [CustomControls colorBoxWithType:COLORBOX_BORDER_SECONDARY withTarget:self];
        [self addManagedSubview:[CustomControls viewWithTitle:@"Bevel flatness:" control:borderFlatSlider colorBox:borderSecondary]];
        
        //Corner radius
        cornerRadius = [[CustomSlider alloc] initWithTarget:self andCallback:@selector(setCornerRadius:)];
        cornerRadius.maximumValue = 25;
        [self addManagedSubview:[CustomControls viewWithTitle:@"Corner Radius:" control:cornerRadius colorBox:nil]];
        
        //Glass Effect
        showGlass = [CustomControls switchWithTarget:self withCallback:@selector(setShowGlass:)];
        glassColor =[CustomControls colorBoxWithType:COLORBOX_GLASS withTarget:self];
        [self addManagedSubview:[CustomControls viewWithTitle:@"Glass Effect:" control:showGlass colorBox:glassColor]];

        //Orientation
        horizontal = [CustomControls switchWithTarget:self withCallback:@selector(setOrientation:)];
        [self addManagedSubview:[CustomControls viewWithTitle:@"Horizontal:" control:horizontal colorBox:nil]];
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
    if ([gauge isKindOfClass:[SGaugeRadial class]])
    {
        SGaugeRadial *radial = (SGaugeRadial*)gauge;
        sliderStart.value = radial.arcAngleStart;
        sliderEnd.value = radial.arcAngleEnd;
    }
    else
    {
        SGaugeLinear *linear = (SGaugeLinear*)gauge;
        horizontal.on = (linear.orientation == SGaugeLinearOrientationHorizontal);
    }
    
    isFullCircle.on = gauge.style.borderIsFullCircle;
    borderSlider.value = gauge.style.bevelWidth;
    borderFlatSlider.value = gauge.style.bevelFlatProportion;
    showGlass.on = gauge.style.showGlassEffect;
    cornerRadius.value = gauge.style.cornerRadius;
    
    gaugeInnerBackgroundColor.backgroundColor = gauge.style.innerBackgroundColor;
    gaugeOuterBackgroundColor.backgroundColor = gauge.style.outerBackgroundColor;
    borderPrimary.backgroundColor = gauge.style.bevelPrimaryColor;
    borderSecondary.backgroundColor = gauge.style.bevelSecondaryColor;
    glassColor.backgroundColor = gauge.style.glassColor;
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
        case COLORBOX_TICKTRACK_PRIMARY: parentController.gauge.style.innerBackgroundColor = colorPicker.selectedColor;
            break;
        case COLORBOX_TICKTRACK_SECONDARY: parentController.gauge.style.outerBackgroundColor = colorPicker.selectedColor;
            break;
        case COLORBOX_BASELINE: parentController.gauge.style.tickBaselineColor = colorPicker.selectedColor;
            break;
        case COLORBOX_BORDER_PRIMARY: parentController.gauge.style.bevelPrimaryColor = colorPicker.selectedColor;
            break;
        case COLORBOX_BORDER_SECONDARY: parentController.gauge.style.bevelSecondaryColor = colorPicker.selectedColor;
            break;
        case COLORBOX_GLASS: parentController.gauge.style.glassColor = colorPicker.selectedColor;
            break;
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

-(void)setAngleStart:(UISlider*)sender
{
    if ([parentController.gauge isKindOfClass:[SGaugeRadial class]])
        [parentController.gauge setValue:@(sender.value) forKey:@"arcAngleStart"];
}

-(void)setAngleEnd:(UISlider*)sender
{
    if ([parentController.gauge isKindOfClass:[SGaugeRadial class]])
        [parentController.gauge setValue:@(sender.value) forKey:@"arcAngleEnd"];
}

-(void)setFullCircle:(UISwitch*)sender
{
    parentController.gauge.style.borderIsFullCircle = sender.on;
}

-(void)setBorderWidth:(UISlider *)sender
{
    parentController.gauge.style.bevelWidth = sender.value;
}

-(void)setFlatness:(UISlider *)sender
{
    parentController.gauge.style.bevelFlatProportion = sender.value;
}

-(void)setCornerRadius:(UISlider *)sender
{
    parentController.gauge.style.cornerRadius = sender.value;
}

-(void)setShowGlass:(UISwitch *)sender
{
    parentController.gauge.style.showGlassEffect = sender.on;
}

-(void)setOrientation:(UISwitch *)sender
{
    SGaugeLinearOrientation value = (sender.on) ? SGaugeLinearOrientationHorizontal : SGaugeLinearOrientationVertical;
    
    if ([parentController.gauge isKindOfClass:[SGaugeLinear class]])
    {
        CGRect bounds = (value == SGaugeLinearOrientationHorizontal) ? CGRectMake(0, 0, 300, 50) : CGRectMake(0, 0, 50, 300);
        parentController.gauge.axis.frame = bounds;
        parentController.gauge.bounds = bounds;
        [parentController.gauge setValue:@(value) forKey:@"orientation"];
    }}

@end
