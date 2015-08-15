//
//  TIViewResizeView.h
//  EventHandleDemo
//
//  Created by lisaike on 15/8/8.
//  Copyright (c) 2015年 lisaike. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TIViewResizeView;
@protocol TIViewResizeViewDelegate <NSObject>

- (void)resizeView:(TIViewResizeView *)resizeView
     changeToScale:(CGFloat)scale
     changeToAngle:(CGFloat)angle;

@end

@interface TIViewResizeView : UIView

@property (nonatomic, assign, readonly) CGFloat angle;
@property (nonatomic, strong, readonly) UIView *attachedView;

- (instancetype)initWithFrame:(CGRect)frame attachedView:(UIView *)view;

- (instancetype)initWithAttachedView:(UIView *)view;

@end
