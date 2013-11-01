//
//  CustomControls.h
//  GaugeDesigner
//
//  Copyright (c) 2013 Scott Logic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomControls : NSObject

+(UIView*)colorBoxWithType:(int)type withTarget:(id)target;
+(UILabel*)labelWithTitle:(NSString*)title withOrigin:(CGPoint)origin;
+(UIButton*)buttonWithTitle:(NSString*)title withCenter:(CGPoint)center withTarget:(id)target withCallback:(SEL)callback;
+(UISwitch*)switchWithTarget:(id)target withCallback:(SEL)callback;
+(UIView*)viewWithTitle:(NSString*)title control:(UIView*)control colorBox:(UIView*)colorBox;

@end
