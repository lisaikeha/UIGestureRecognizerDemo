//
//  ViewController.m
//  EventHandleDemo
//
//  Created by lisaike on 15/8/7.
//  Copyright (c) 2015年 lisaike. All rights reserved.
//

#import "ViewController.h"
#import <CoreText/CoreText.h>
#import "UILabel+VerticalAlignment.h"

#import <objc/runtime.h>
// views
#import "TIViewResizeView.h"
#import "TILabel.h"
#import "TIEditorTextView.h"

@interface ViewController ()<TIEditorTextViewDelegate>

@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) TIEditorTextView *textView;
@property (nonatomic, strong) UIView *editingView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewController : %@",self);
    [self fontRegistTest];

    [self addGestureRecognizer];
    [self.view addSubview:self.addButton];
}

#pragma mark - font register

- (BOOL)registerFont:(NSURL *)fontUrl
{
    NSData *dynamicFontData = [NSData dataWithContentsOfURL:fontUrl];
    if (!dynamicFontData)
    {
        return NO;
    }
    BOOL succeed = YES;
    CFErrorRef error;
    CGDataProviderRef providerRef = CGDataProviderCreateWithCFData((__bridge CFDataRef)dynamicFontData);
    CGFontRef font = CGFontCreateWithDataProvider(providerRef);
    if (! CTFontManagerRegisterGraphicsFont(font, &error))
    {
        //注册失败
        CFStringRef errorDescription = CFErrorCopyDescription(error);
        NSLog(@"Failed to load font: %@", errorDescription);
        succeed = NO;
        CFRelease(errorDescription);
    }
    CFRelease(font);
    CFRelease(providerRef);
    return succeed;
}

- (BOOL)isFontDownloaded:(NSString *)fontName
{
    UIFont* aFont = [UIFont fontWithName:fontName size:12.0];
    BOOL isDownloaded = (aFont && ([aFont.fontName compare:fontName] == NSOrderedSame || [aFont.familyName compare:fontName] == NSOrderedSame));
    return isDownloaded;
}

- (void)fontRegistTest
{
    NSLog(@"%@", @([self isFontDownloaded:@"HYHeiLiZhiTiJ"]));
    NSBundle *bundle = [NSBundle mainBundle];
    NSURL *url = [bundle URLForResource:@"HYHeiLiZhiTiJ" withExtension:@".ttf"];
    NSDate *startTime = [NSDate date];
    if([self registerFont:url])
    {
        NSLog(@"regist success");
    }
    else
    {
        NSLog(@"regist failed");
    }
    NSLog(@"%@", @([[NSDate date] timeIntervalSinceDate:startTime]));
    NSLog(@"%@", @([self isFontDownloaded:@"HYHeiLiZhiTiJ"]));
}

#pragma mark - 摇一摇

- (BOOL)canBecomeFirstResponder
{
    return YES;// default is NO
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"开始摇动手机");
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"停止");
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"隐约雷鸣\n阴霾天空\n但盼雨来\n能留你在此地哈T_T"];
    [text addAttribute:NSKernAttributeName value:@(0) range:(NSRange){0, text.length}];
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineHeightMultiple = 1.0;
    paragraph.alignment = NSTextAlignmentCenter;
    [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HYHeiLiZhiTiJ" size:25] range:(NSRange){0, text.length}];
    NSShadow *shadow = [NSShadow new];
    shadow.shadowColor = [UIColor darkGrayColor];
    shadow.shadowOffset = CGSizeMake(0, 0);
    shadow.shadowBlurRadius = 3;
    TILabel *label = (TILabel *)[self.array[0] attachedView];
    [label setAttributedText:[text copy]];
    [label resizeLable];
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"取消");
}

#pragma mark - gesture

- (void)addGestureRecognizer
{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleTap];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.view addGestureRecognizer:pan];
    
    //dependency
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    NSArray *subviews = [self resizeViewsAtPoint:[recognizer locationInView:self.view] ofSuperView:self.view];
    if(subviews.count == 0)
    {
        self.editingView = nil;
    }
    else
    {
        if(self.editingView)
        {
            if (subviews.count == 1)
            {
                [self.view bringSubviewToFront:[subviews firstObject]];
                self.editingView = [subviews firstObject];
            }
            else
            {
                UIView *front = [subviews lastObject];
                UIView *secondFront = [subviews objectAtIndex:[subviews indexOfObject:front] - 1];
                [self.view sendSubviewToBack:front];
                [self.view bringSubviewToFront:secondFront];
                self.editingView = secondFront;
            }
        }
        else
        {
            self.editingView = [subviews lastObject];
            [self.view bringSubviewToFront:self.editingView];
        }
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
    NSArray *subviews = [self resizeViewsAtPoint:[recognizer locationInView:self.view] ofSuperView:self.view];
    TIViewResizeView *target;
    for(NSInteger index = subviews.count - 1 ; index >= 0 ; index --)
    {
        TIViewResizeView *resizeView = [subviews objectAtIndex:index];
        if([resizeView.attachedView isKindOfClass:[TILabel class]])
        {
            target = resizeView;
            break;
        }
    }
    if(target)
    {
        TILabel *label = (TILabel *)target.attachedView;
        UIFont *font = [label.attributedText attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
        self.textView.font = font;
        if([label.attributedText.string isEqual:@"双击修改"])
        {
            self.textView.text = @"";
        }
        else
        {
            self.textView.text = label.attributedText.string;
        }
        self.editingView = target;
        [self startEditingText];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    if(recognizer.state == UIGestureRecognizerStateBegan)
    {
        NSLog(@"begin");

        NSArray *subviews = [self resizeViewsAtPoint:[recognizer locationInView:self.view] ofSuperView:self.view];
        if(subviews.count == 0)
        {
            self.editingView = nil;
            objc_setAssociatedObject(recognizer, @"beginCenter", nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        else
        {
            self.editingView = [subviews lastObject];
            [self.view bringSubviewToFront:self.editingView];
            NSValue *beginCenter = [NSValue valueWithCGPoint:self.editingView.center];
            objc_setAssociatedObject(recognizer, @"beginCenter", beginCenter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint change = [recognizer translationInView:self.view];
        if(self.editingView)
        {
            CGPoint beginCenter = [objc_getAssociatedObject(recognizer, @"beginCenter") CGPointValue];
            CGPoint myCenter = beginCenter;
            myCenter.x += change.x;
            myCenter.y += change.y;
            self.editingView.center = myCenter;
        }
    }
}

#pragma mark - delegate

- (void)editorTextViewDidClickButton:(TIEditorTextView *)editorTextView
{
    if(!editorTextView.text || !editorTextView.text.length)
    {
        if(self.editingView)
        {
            [self.editingView removeFromSuperview];
        }
        if([self.array containsObject:self.editingView])
        {
            [self.array removeObject:self.editingView];
        }
    }
    else
    {
        TIViewResizeView *view = (TIViewResizeView *)self.editingView;
        if(view && [view.attachedView isKindOfClass:[TILabel class]])
        {
            TILabel *label = (TILabel *)view.attachedView;
            NSDictionary *attribute = [[label attributedText] attributesAtIndex:0 effectiveRange:NULL];
            NSAttributedString *text = [[NSAttributedString alloc] initWithString:editorTextView.text attributes:attribute];
            [label setAttributedText:text];
            [label resizeLable];
        }
    }
    [self endEditingText];
}

#pragma mark - button actions

- (void)addOneLabel
{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"隐约雷鸣\n阴霾天空\n但盼雨来\n能留你在此地"];
//    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"是啊\n啊啊\n啊啊\n氨基\n酸的\n你妹"];
//    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"双击修改"];

    [text addAttribute:NSKernAttributeName value:@(10) range:(NSRange){0, text.length}];
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineHeightMultiple = 1.0;
    paragraph.alignment = NSTextAlignmentCenter;
    [text addAttribute:NSParagraphStyleAttributeName value:[paragraph copy] range:(NSRange){0, text.length}];
    [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HYHeiLiZhiTiJ" size:31] range:(NSRange){0, text.length}];
    [text addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, text.length)];
    NSShadow *shadow = [NSShadow new];
    shadow.shadowColor = [UIColor darkGrayColor];
    shadow.shadowOffset = CGSizeMake(0, 0);
    shadow.shadowBlurRadius = 3;
    [text addAttribute:NSShadowAttributeName value:shadow range:(NSRange){0, text.length}];
    CGRect bound = [text boundingRectWithSize:CGSizeMake(DBL_MAX, DBL_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    bound.origin = CGPointMake(0, 50);
    TILabel *label = [[TILabel alloc] initWithFrame:CGRectZero];
    label.attributedText = text;
    [label resizeLable];
    TIViewResizeView *resizeView = [[TIViewResizeView alloc] initWithAttachedView:label];
    [self.view addSubview:resizeView];
    [self.array addObject:resizeView];
}

#pragma mark - private

- (NSArray *)resizeViewsAtPoint:(CGPoint)point ofSuperView:(UIView *)superView
{
    NSMutableArray *subviews = [NSMutableArray array];
    for(UIView *view in superView.subviews)
    {
        CGPoint insidePoint = [view convertPoint:point fromView:superView];
        if([view pointInside:insidePoint withEvent:nil] && [view isKindOfClass:[TIViewResizeView class]])
        {
            [subviews addObject:view];
        }
    }
    return [subviews copy];
}

- (void)startEditingText
{
    [self.view addSubview:self.textView];
    [self.textView becomeFirstResponder];
}

- (void)endEditingText
{
    self.textView.text = @"";
    [self.textView resignFirstResponder];
    [self.textView removeFromSuperview];
}

#pragma mark - getter

- (UIButton *)addButton
{
    if(!_addButton)
    {
        _addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [_addButton addTarget:self action:@selector(addOneLabel) forControlEvents:UIControlEventTouchUpInside];
        _addButton.center = CGPointMake(345, 30);
    }
    return _addButton;
}

- (NSMutableArray *)array
{
    if(!_array)
    {
        _array = [NSMutableArray array];
    }
    return _array;
}

- (TIEditorTextView *)textView
{
    if(!_textView)
    {
        _textView = [[TIEditorTextView alloc] initWithFrame:CGRectMake(0, 200, CGRectGetWidth(self.view.bounds), 200)];
        _textView.editorDelegate = self;
    }
    return _textView;
}

#pragma mark - setter

- (void)setEditingView:(UIView *)editingView
{
    if(_editingView)
    {
        [(TIViewResizeView *)_editingView setShowBorder:NO];
        [(TIViewResizeView *)_editingView setShowControls:NO];
    }
    if(editingView)
    {
        [(TIViewResizeView *)editingView setShowBorder:YES];
        [(TIViewResizeView *)editingView setShowControls:YES];
    }
    _editingView = editingView;
}

@end
