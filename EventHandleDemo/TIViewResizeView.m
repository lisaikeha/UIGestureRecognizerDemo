//
//  TIViewResizeView.m
//  EventHandleDemo
//
//  Created by lisaike on 15/8/8.
//  Copyright (c) 2015年 lisaike. All rights reserved.
//

#import "TIViewResizeView.h"

static int PrivateContext;
static CGFloat const M_PI_16 = M_PI_4/4.0;
static CGFloat const MIN_SIZE = 10;
static CGFloat const CONTROL_SIZE = 23;
static NSString *const SELF_KEYPATH_BOUNDS = @"bounds";
static NSString *const SELF_KEYPATH_ATTACHEDVIEW_BOUNDS = @"attachedView.bounds";

@interface TIViewResizeView ()

@property (nonatomic, strong) UIImageView *leftTopControl;
@property (nonatomic, strong) UIImageView *rightBottomControl;
@property (nonatomic, strong) UIView *attachedView;
@property (nonatomic, assign) CGFloat angle;

@end

@implementation TIViewResizeView

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame attachedView:nil];
}

- (instancetype)initWithAttachedView:(UIView *)view
{
    return [self initWithFrame:CGRectZero attachedView:view];
}

- (instancetype)initWithFrame:(CGRect)frame attachedView:(UIView *)view
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self addObserver:self forKeyPath:SELF_KEYPATH_BOUNDS
                  options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew |NSKeyValueObservingOptionOld
                  context:&PrivateContext];
        
        self.layer.borderColor = [[UIColor redColor] CGColor];
        self.userInteractionEnabled = YES;
        if(view)
        {
            self.attachedView = view;
            [self addObserver:self forKeyPath:SELF_KEYPATH_ATTACHEDVIEW_BOUNDS
                      options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                      context:&PrivateContext];
            [self addSubview:view];
        }
        self.showBorder = NO;
        self.showControls = NO;
        [self addSubview:self.rightBottomControl];
        [self addSubview:self.leftTopControl];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:SELF_KEYPATH_BOUNDS context:&PrivateContext];
    if(self.attachedView)
    {
        [self removeObserver:self forKeyPath:SELF_KEYPATH_ATTACHEDVIEW_BOUNDS context:&PrivateContext];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGPoint rightBottomPosition = [self convertPoint:point toView:self.rightBottomControl];
    CGPoint leftTopPosition = [self convertPoint:point toView:self.leftTopControl];
    if([self.rightBottomControl pointInside:rightBottomPosition withEvent:event] && !self.rightBottomControl.hidden)
    {
        return self.rightBottomControl;
    }
    else if([self.leftTopControl pointInside:leftTopPosition withEvent:event] && !self.leftTopControl.hidden)
    {
        return self.leftTopControl;
    }
    else
    {
        return [super hitTest:point withEvent:event];
    }
}

#pragma mark - right bottom control

- (void)rightBottomDragged:(UIPanGestureRecognizer *)recognizer
{
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
//            NSLog(@"begin");
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            NSAssert(CGRectGetWidth(self.bounds), @"width should have a positive value");
            NSAssert(CGRectGetHeight(self.bounds), @"height should have a positive value");
            CGPoint viewCenter = self.center;
            CGFloat originDist = hypotf(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
            CGFloat originAngle = acos(CGRectGetWidth(self.bounds) / 2 / originDist);
            CGPoint position = [recognizer locationInView:self.superview];
            CGFloat dynamicDist = hypot(position.x - viewCenter.x, position.y - viewCenter.y);
            // 计算缩放比
            CGFloat scale = dynamicDist / originDist;
            if(scale * self.bounds.size.width < MIN_SIZE || scale * self.bounds.size.height < MIN_SIZE)
            {
                if(scale * self.bounds.size.height < MIN_SIZE)
                {
                    scale = MIN_SIZE / self.bounds.size.height;
                }
                else
                {
                    scale = MIN_SIZE / self.bounds.size.width;
                }
            }
            // 计算角度
            CGFloat angle = atan2(position.y - viewCenter.y, position.x - viewCenter.x) - originAngle;
            if(fabs( angle - M_PI_2 ) < M_PI_16)
            {
                angle = M_PI_2;
            }
            else if (fabs( angle - M_PI ) < M_PI_16 || fabs(angle + M_PI) < M_PI_16)
            {
                angle = M_PI;
            }
            else if (fabs( angle + M_PI_2 ) < M_PI_16)
            {
                angle = - M_PI_2;
            }
            else if(fabs( angle ) < M_PI_16)
            {
                angle = 0;
            }
            if(self.attachedView
               && [self.attachedView conformsToProtocol:@protocol(TIViewResizeViewDelegate)]
               && [self.attachedView respondsToSelector:@selector(resizeView:changeToScale:changeToAngle:)])
            {
                [(id<TIViewResizeViewDelegate>)self.attachedView resizeView:self changeToScale:scale changeToAngle:angle];
            }
            else
            {
                // 默认布局更新
                CGRect newBounds = self.bounds;
                newBounds.size = CGSizeMake(self.bounds.size.width * scale, self.bounds.size.height * scale);
                self.bounds = newBounds;
                self.transform = CGAffineTransformMakeRotation(angle);
                self.angle = angle;
                // 如果有关联的view也更新
                if(self.attachedView)
                {
                    self.attachedView.bounds = newBounds;
                }
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
//            NSLog(@"ended with:%@", NSStringFromCGRect(self.bounds));
        }
            break;
        case UIGestureRecognizerStateCancelled:
        {
            NSLog(@"failed");
        }
            break;
        case UIGestureRecognizerStateFailed:
        {
            NSLog(@"failed");
        }
            break;
        case UIGestureRecognizerStatePossible:
        {
            NSLog(@"possible");
        }
            break;
        default:
            break;
    }
}

- (void)leftTopTapped:(UITapGestureRecognizer *)recognizer
{
    [self removeFromSuperview];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if(context == &PrivateContext)
    {
        if([keyPath isEqual:SELF_KEYPATH_BOUNDS])
        {
            if(![change[NSKeyValueChangeNewKey] isKindOfClass:[NSValue class]])
            {
                return;
            }
            if([change[NSKeyValueChangeOldKey] isKindOfClass:[NSValue class]] && CGRectEqualToRect([change[NSKeyValueChangeNewKey] CGRectValue], [change[NSKeyValueChangeOldKey] CGRectValue]))
            {
                return;
            }
            CGRect newBounds = [change[NSKeyValueChangeNewKey] CGRectValue];
            self.rightBottomControl.center = CGPointMake(newBounds.size.width, newBounds.size.height);
            self.leftTopControl.center = CGPointMake(0, 0);
            if(self.attachedView)
            {
                self.attachedView.center = CGPointMake(newBounds.size.width / 2, newBounds.size.height / 2);
            }
        }
        else if ([keyPath isEqualToString:SELF_KEYPATH_ATTACHEDVIEW_BOUNDS])
        {
            if(![change[NSKeyValueChangeNewKey] isKindOfClass:[NSValue class]])
            {
                return;
            }
            if([change[NSKeyValueChangeOldKey] isKindOfClass:[NSValue class]] && CGRectEqualToRect([change[NSKeyValueChangeNewKey] CGRectValue], [change[NSKeyValueChangeOldKey] CGRectValue]))
            {
                return;
            }
            CGRect rect = [change[NSKeyValueChangeNewKey] CGRectValue];
            rect.size.width += 10;
            rect.size.height += 10;
            self.bounds = rect;
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - getter

- (UIView *)rightBottomControl
{
    if(!_rightBottomControl)
    {
        _rightBottomControl = [[UIImageView alloc] init];
        _rightBottomControl.backgroundColor = [UIColor greenColor];
        _rightBottomControl.bounds = CGRectMake(0, 0, CONTROL_SIZE, CONTROL_SIZE);
        _rightBottomControl.layer.cornerRadius = CONTROL_SIZE / 2;
        [_rightBottomControl addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(rightBottomDragged:)]];
    }
    return _rightBottomControl;
}

- (UIImageView *)leftTopControl
{
    if(!_leftTopControl)
    {
        _leftTopControl = [[UIImageView alloc] init];
        _leftTopControl.backgroundColor = [UIColor purpleColor];
        _leftTopControl.bounds = CGRectMake(0, 0, CONTROL_SIZE, CONTROL_SIZE);
        _leftTopControl.layer.cornerRadius = CONTROL_SIZE / 2;
        [_leftTopControl addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftTopTapped:)]];
    }
    return _leftTopControl;
}

#pragma mark - setter

- (void)setShowControls:(BOOL)showControls
{
    if(showControls)
    {
        self.rightBottomControl.hidden = NO;
        self.leftTopControl.hidden = NO;
    }
    else
    {
        self.rightBottomControl.hidden = YES;
        self.leftTopControl.hidden = YES;
    }
    _showControls = showControls;
}

- (void)setShowBorder:(BOOL)showBorder
{
    if(showBorder)
    {
        self.layer.borderWidth = 1.0;
    }
    else
    {
        self.layer.borderWidth = 0;
    }
    _showBorder = showBorder;
}

@end
