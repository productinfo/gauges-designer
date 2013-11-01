//
//  CustomControls.m
//  GaugeDesigner
//
//  Copyright (c) 2013 Scott Logic. All rights reserved.
//

#import "CustomControls.h"
#import <QuartzCore/QuartzCore.h>

@implementation CustomControls

+(UIView*)colorBoxWithType:(int)type withTarget:(id)target
{
    UIView *colorBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
    colorBox.backgroundColor = [UIColor clearColor];
    colorBox.tag = type;
    colorBox.layer.borderWidth = 1;
    colorBox.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    //Add a tap gesture recogniser
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:@selector(tappedColorBox:)];
    [colorBox addGestureRecognizer:tap];
    
    return colorBox;
}

+(UILabel*)labelWithTitle:(NSString*)title withOrigin:(CGPoint)origin
{
    UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(origin.x, origin.y, 0, 0)];
    newLabel.text = title;
    [newLabel sizeToFit];
    return newLabel;
}

+(UIButton*)buttonWithTitle:(NSString*)title withCenter:(CGPoint)center withTarget:(id)target withCallback:(SEL)callback
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:target action:callback forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    button.center = center;
    return button;
}

+(UISwitch*)switchWithTarget:(id)target withCallback:(SEL)callback
{
    UISwitch *customSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 40, 25)];
    [customSwitch addTarget:target action:callback forControlEvents:UIControlEventValueChanged];
    return customSwitch;
}

+(UIView*)viewWithTitle:(NSString*)title control:(UIView*)control colorBox:(UIView*)colorBox
{
    UIView *wrapperView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 40)];
    
    //Add label
    UILabel *label = [self labelWithTitle:title withOrigin:CGPointMake(75, 5)];
    [wrapperView addSubview:label];
    
    //Add control
    CGRect controlFrame = control.frame;
    controlFrame.origin = CGPointMake(220, 20 - control.bounds.size.height/2);
    control.frame = controlFrame;
    [wrapperView addSubview:control];
    
    //Add colorbox
    if (colorBox)
    {
        colorBox.center = CGPointMake(700, 20);
        [wrapperView addSubview:colorBox];
    }
    
    return wrapperView;
}

@end
