//
//  CustomControls.m
//  GaugeDesigner
//
//  Copyright (c) 2013 Scott Logic. All rights reserved.
//

#import "CustomControls.h"
#import <QuartzCore/QuartzCore.h>

@implementation CustomControls

+(UIView*)colorBoxWithCenter:(CGPoint)center withType:(int)type withTarget:(id)target
{
    UIView *colorBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    colorBox.backgroundColor = [UIColor clearColor];
    colorBox.layer.borderWidth = 1;
    colorBox.center = center;
    colorBox.tag = type;
    
    //Add a tap gesture recogniser
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:@selector(tappedColorBox:)];
    [colorBox addGestureRecognizer:tap];
    
    return colorBox;
}

+(UILabel*)labelWithTitle:(NSString*)title withOrigin:(CGPoint)origin
{
    UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(origin.x, origin.y, 0, 0)];
    newLabel.text = title;
    newLabel.backgroundColor = [UIColor clearColor];
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

+(UISwitch*)switchWithOrigin:(CGPoint)origin withTarget:(id)target withCallback:(SEL)callback
{
    UISwitch *customSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(origin.x, origin.y, 40, 25)];
    [customSwitch addTarget:target action:callback forControlEvents:UIControlEventValueChanged];
    return customSwitch;
}

@end
