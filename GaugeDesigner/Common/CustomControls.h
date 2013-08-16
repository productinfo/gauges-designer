//
//  CustomControls.h
//  GaugeDesigner
//
//  Copyright (c) 2013 Scott Logic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomControls : NSObject

+(UIView*)colorBoxWithCenter:(CGPoint)center withType:(int)type withTarget:(id)target;
+(UILabel*)labelWithTitle:(NSString*)title withOrigin:(CGPoint)origin;
+(UIButton*)buttonWithTitle:(NSString*)title withCenter:(CGPoint)center withTarget:(id)target withCallback:(SEL)callback;
+(UISwitch*)switchWithOrigin:(CGPoint)origin withTarget:(id)target withCallback:(SEL)callback;

@end
