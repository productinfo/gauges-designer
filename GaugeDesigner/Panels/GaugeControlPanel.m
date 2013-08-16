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
        sliderStart = [[CustomSlider alloc] initWithTitle:@"Angle start" withTarget:self andCallback:@selector(setAngleStart:)];
        sliderEnd = [[CustomSlider alloc] initWithTitle:@"Angle stop" withTarget:self andCallback:@selector(setAngleEnd:)];
        sliderStart.minimumValue = -M_PI + 0.001;
        sliderStart.maximumValue = M_PI;
        sliderEnd.minimumValue = -M_PI + 0.001;
        sliderEnd.maximumValue = M_PI;
        sliderStart.center = CGPointMake(385, 50);
        sliderEnd.center = CGPointMake(385, 80);
        [self addSubview:sliderStart];
        [self addSubview:sliderEnd];
        
        [self addSubview:[CustomControls labelWithTitle:@"Full circle:" withOrigin:CGPointMake(75, 105)]];
        isFullCircle = [CustomControls switchWithOrigin:CGPointMake(230, 100) withTarget:self withCallback:@selector(setFullCircle:)];
        [self addSubview:isFullCircle];
        
        //Background
        [self addSubview:[CustomControls labelWithTitle:@"Background color:" withOrigin:CGPointMake(75, 140)]];
        gaugeInnerBackgroundColor =[CustomControls colorBoxWithCenter:CGPointMake(240, 150) withType:COLORBOX_TICKTRACK_PRIMARY withTarget:self];
        [self addSubview:gaugeInnerBackgroundColor];
        gaugeOuterBackgroundColor =[CustomControls colorBoxWithCenter:CGPointMake(280, 150) withType:COLORBOX_TICKTRACK_SECONDARY withTarget:self];
        [self addSubview:gaugeOuterBackgroundColor];
        
        //Bevel
        borderSlider = [[CustomSlider alloc] initWithTitle:@"Bevel width" withTarget:self andCallback:@selector(setBorderWidth:)];
        borderSlider.center = CGPointMake(385, 190);
        borderSlider.maximumValue = 30;
        [self addSubview:borderSlider];
        
        borderPrimary =[CustomControls colorBoxWithCenter:CGPointMake(710, 190) withType:COLORBOX_BORDER_PRIMARY withTarget:self];
        [self addSubview:borderPrimary];
        borderSecondary =[CustomControls colorBoxWithCenter:CGPointMake(740, 190) withType:COLORBOX_BORDER_SECONDARY withTarget:self];
        [self addSubview:borderSecondary];
        
        borderFlatSlider = [[CustomSlider alloc] initWithTitle:@"Bevel flatness" withTarget:self andCallback:@selector(setFlatness:)];
        borderFlatSlider.center = CGPointMake(385, 220);
        [self addSubview:borderFlatSlider];
        
        //Glass Effect
        [self addSubview:[CustomControls labelWithTitle:@"Glass Effect:" withOrigin:CGPointMake(75, 240)]];
        showGlass = [CustomControls switchWithOrigin:CGPointMake(270, 240) withTarget:self withCallback:@selector(setShowGlass:)];
        [self addSubview:showGlass];
        
        glassColor =[CustomControls colorBoxWithCenter:CGPointMake(240, 255) withType:COLORBOX_GLASS withTarget:self];
        [self addSubview:glassColor];
    }
    return self;
}

-(void)updateWithGauge:(SGauge *)gauge
{
    if ([gauge isKindOfClass:[SGaugeRadial class]])
    {
        SGaugeRadial *radial = (SGaugeRadial*)gauge;
        sliderStart.value = radial.arcAngleStart;
        sliderEnd.value = radial.arcAngleEnd;
    }
    isFullCircle.on = gauge.style.borderIsFullCircle;
    borderSlider.value = gauge.style.bevelWidth;
    borderFlatSlider.value = gauge.style.bevelFlatProportion;
    showGlass.on = gauge.style.showGlassEffect;
    
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

-(void)setShowGlass:(UISwitch *)sender
{
    parentController.gauge.style.showGlassEffect = sender.on;
}

@end
