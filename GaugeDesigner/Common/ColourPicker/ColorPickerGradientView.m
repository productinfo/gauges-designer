//
//  GradientView.m
//  ColorPicker
//
//  Created by Matthew Eagar on 9/23/11.
//  Copyright 2011 ThinkFlood Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy 
//  of this software and associated documentation files (the "Software"), to deal 
//  in the Software without restriction, including without limitation the rights 
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
//  copies of the Software, and to permit persons to whom the Software is furnished 
//  to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all 
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
//  SOFTWARE.

#import "ColorPickerGradientView.h"

#pragma mark Constants

#define COLOR_COMPONENT_RED_INDEX 0
#define COLOR_COMPONENT_GREEN_INDEX 1
#define COLOR_COMPONENT_BLUE_INDEX 2
#define COLOR_COMPONENT_ALPHA_INDEX 3

#define COLOR_COMPONENT_COUNT 4

#define GRADIENT_DRAWING_OPTIONS_NONE 0

#pragma mark -
#pragma mark Implementation

@implementation ColorPickerGradientView

#pragma mark -
#pragma mark Properties

@dynamic colors;

- (NSArray *)colors {
    return _colors;
}

- (void)setColors:(NSArray *)colors {
    if (colors == _colors) {
        // continue
    }
    else if (colors.count > 1) {
        if (_colors) {
            _colors = nil;
            CGGradientRelease(_gradient);
        }
        
        _colors = [colors copy];
        
        CGFloat *gradientColors = [self componentsFromColors:colors];
        CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
        
        _gradient = CGGradientCreateWithColorComponents(rgbColorSpace, 
                                                        gradientColors, 
                                                        NULL, 
                                                        colors.count);
        
        CGColorSpaceRelease(rgbColorSpace);
        
        [self setNeedsDisplay];
    }
}

-(CGFloat*)componentsFromColors:(NSArray*)colors
{
    CGFloat *components = calloc(sizeof(CGFloat), 4 * colors.count + 1);
    for (int i = 0; i < colors.count; i++)
    {
        UIColor *color = [colors objectAtIndex:i];
        CGColorSpaceRef colorspace = CGColorGetColorSpace(color.CGColor);
        
        float red = 0;
        float green = 0;
        float blue = 0;
        float alpha = 0;
        
        CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(colorspace);
        [self parseColor:color forColorSpaceModel:colorSpaceModel withRed:&red withGreen:&green withBlue:&blue withAlpha:&alpha];
        
        components[i*4] = red;
        components[i*4 + 1] = green;
        components[i*4 + 2] = blue;
        components[i*4 + 3] = alpha;
    }
    
    return components;
}

//The assumption is all componentsFromColors: are returned as RGB colorspace. Occasionally, we need to convert into the correct space
-(void)parseColor:(UIColor*)color forColorSpaceModel:(CGColorSpaceModel)model withRed:(float*)red withGreen:(float*)green withBlue:(float*)blue withAlpha:(float*)alpha
{
    switch (model)
    {
        case kCGColorSpaceModelRGB:
            [color getRed:red green:green blue:blue alpha:alpha];
            break;
        case kCGColorSpaceModelMonochrome:
        {
            float white;
            [color getWhite:&white alpha:alpha];
            *red = white;
            *green = white;
            *blue = white;
            break;
        }
            
        default:
            NSLog(@"New colorspace model encountered: %d. No implementation to deal with this", model);
            break;
    }
}

#pragma mark -
#pragma mark Initializers

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _colors = nil;
        _gradient = nil;
    }
    
    return self;
}

#pragma mark -
#pragma mark Overrides

- (void)dealloc {
    if (_colors) {
        _colors = nil;
        CGGradientRelease(_gradient);
    }
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);

    CGRect viewBounds = self.bounds;
    CGContextClipToRect(context, viewBounds);
	
	CGPoint startPoint = CGPointMake(0.0f, 0.0f);
	CGPoint endPoint = CGPointMake(viewBounds.size.width, 0.0f);
	CGContextDrawLinearGradient(context, 
                                _gradient, 
                                startPoint, 
                                endPoint, 
                                GRADIENT_DRAWING_OPTIONS_NONE);
	CGContextRestoreGState(context);
	CGContextSaveGState(context);
    
    [super drawRect:rect];
}

@end
