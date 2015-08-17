//
//  TILabel.m
//  EventHandleDemo
//
//  Created by lisaike on 15/8/12.
//  Copyright (c) 2015年 lisaike. All rights reserved.
//

#import "TILabel.h"

static CGFloat const MIN_FONTSIZE = 12;

@interface TILabel ()
@end

@implementation TILabel

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.numberOfLines = 0;
    }
    return self;
}

#pragma mark - delegates

- (void)resizeView:(TIViewResizeView *)resizeView changeToScale:(CGFloat)scale changeToAngle:(CGFloat)angle
{
    //手势所产生的变化
    CGRect newBounds = resizeView.bounds;
    newBounds.size = CGSizeMake(newBounds.size.width * scale, newBounds.size.height * scale);
    resizeView.transform = CGAffineTransformMakeRotation(angle);
    if([resizeView.attachedView isEqual:self])
    {
        if([resizeView.attachedView isKindOfClass:[TILabel class]])
        {
            TILabel *textLabel = (TILabel *)resizeView.attachedView;
            CGRect boundsNeeded = [textLabel.attributedText boundingRectWithSize:CGSizeMake(DBL_MAX, DBL_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
            UIFont *newFont = [[textLabel.attributedText attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL] copy];
            CGFloat fontSize = newFont.pointSize;
            CGFloat newFontSize = round(fontSize) + 1;
            newFont = [newFont fontWithSize:newFontSize];
            NSMutableAttributedString *newText = [textLabel.attributedText mutableCopy];
            [newText removeAttribute:NSFontAttributeName range:NSMakeRange(0, newText.length)];
            [newText addAttribute:NSFontAttributeName value:newFont range:NSMakeRange(0, newText.length)];
            CGRect newBoundsNeeded = [newText boundingRectWithSize:CGSizeMake(DBL_MAX, DBL_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
            
            CGFloat deltaUnit = CGRectGetWidth(newBoundsNeeded) - CGRectGetWidth(boundsNeeded);
            CGFloat interval = CGRectGetWidth(newBounds) - CGRectGetWidth(boundsNeeded);
            CGFloat deltaMulti = floor(interval / deltaUnit);
            newFont = [newFont fontWithSize:fontSize + deltaMulti];
            if(newFont.pointSize < MIN_FONTSIZE)
            {
                return;
            }
            [newText removeAttribute:NSFontAttributeName range:NSMakeRange(0, newText.length)];
            [newText addAttribute:NSFontAttributeName value:newFont range:NSMakeRange(0, newText.length)];
            textLabel.attributedText = newText;
            [textLabel resizeLable];
        }
        else
        {
            resizeView.attachedView.bounds = newBounds;
        }
    }
}

#pragma mark - draw text

- (void)drawTextInRect:(CGRect)rect
{
//    NSLog(@"draw rect:%@", NSStringFromCGRect(rect));
//    [super drawTextInRect:CGRectInset(rect, 2, 2)];
    [super drawTextInRect:rect];
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    CGRect rect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    NSAttributedString *string = self.attributedText;
    NSNumber *kern = [string attribute:NSKernAttributeName atIndex:0 effectiveRange:NULL];
    if(kern)
    {
        rect.origin.x = ( bounds.size.width - (rect.size.width - [kern integerValue]) ) / 2;
    }
    UIFont *font = [string attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
    NSParagraphStyle *paragraph = [string attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:NULL];
    if(font)
    {
        CGFloat lineSpace = 0.0;
        if(paragraph)
        {
            lineSpace = font.lineHeight * (paragraph.lineHeightMultiple - 1) + paragraph.lineSpacing;
        }
        rect.origin.y -= lineSpace / 2;
    }
    
//    NSLog(@"bounds : %@", NSStringFromCGRect(bounds));
//    NSLog(@"text rect for bounds : %@", NSStringFromCGRect(rect));
    return rect;
}

#pragma mark - public

- (void)resizeLable
{
    CGRect newBounds = [self.attributedText boundingRectWithSize:CGSizeMake(DBL_MAX, DBL_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    self.bounds = newBounds;
}

#pragma mark - setter

- (void)setText:(NSString *)text
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text ? : @"" attributes:@{NSFontAttributeName : self.font ? :[UIFont systemFontOfSize:17],
                                                                                                                      NSForegroundColorAttributeName : self.textColor ? : [UIColor blackColor]}];
    self.attributedText = attributedString;
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    [self setText:self.text];
}

- (void)setTextColor:(UIColor *)textColor
{
    [super setTextColor:textColor];
    [self setText:self.text];
}

@end
