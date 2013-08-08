//
//  ControlPanel.h
//  GaugeDesigner
//
//  Copyright (c) 2013 Scott Logic. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SGauge;
@protocol ColorPickerDelegate;
@class ViewController;

enum COLORBOX_TYPE {
    COLORBOX_MAJOR_TICK = 0,
    COLORBOX_MINOR_TICK,
    COLORBOX_TICK_LABEL,
    COLORBOX_NEEDLE,
    COLORBOX_NEEDLE_BORDER,
    COLORBOX_KNOB,
    COLORBOX_KNOB_BORDER,
    COLORBOX_TICKTRACK_PRIMARY,
    COLORBOX_TICKTRACK_SECONDARY,
    COLORBOX_BASELINE,
    COLORBOX_BORDER_PRIMARY,
    COLORBOX_BORDER_SECONDARY,
    COLORBOX_GLASS,
    COLORBOX_RANGE_BORDER
};

@protocol ControlPanel <ColorPickerDelegate>

-(void)updateWithGauge:(SGauge*)gauge;
-(void)tappedColorBox:(UITapGestureRecognizer*)sender;

-(id)initWithFrame:(CGRect)frame forController:(ViewController*)controller;

@end
