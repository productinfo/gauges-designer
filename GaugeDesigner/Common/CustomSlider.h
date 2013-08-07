//
//  CustomSlider.h
//  GaugeDesigner
//
//  Copyright (c) 2013 Scott Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomSlider : UIView

@property (nonatomic, assign) float value;
@property (nonatomic, assign) float minimumValue;
@property (nonatomic, assign) float maximumValue;

-(id)initWithTitle:(NSString*)title withTarget:(id)target andCallback:(SEL)callbackFunc;

@end
