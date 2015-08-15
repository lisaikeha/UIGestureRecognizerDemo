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

    [self.view addSubview:self.addButton];
    [self.view addSubview:self.textView];
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
    [self.array[0] setAttributedText:[text copy]];
    [self.array[0] resizeLable];
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"取消");
}

#pragma mark - touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    NSLog(@"begin");
    NSMutableArray *subviews = [NSMutableArray array];
    for(UIView *view in self.view.subviews)
    {
        CGPoint point = [view convertPoint:[touch locationInView:self.view] fromView:self.view];
        if([view pointInside:point withEvent:event])
        {
            [subviews addObject:view];
        }
    }
    if(subviews.count == 0)
    {
    
    }
    else if (subviews.count == 1)
    {
        [self.view bringSubviewToFront:[subviews firstObject]];
    }
    else
    {
        UIView *front = [subviews lastObject];
        UIView *secondFront = [subviews objectAtIndex:[subviews indexOfObject:front] - 1];
        [self.view sendSubviewToBack:front];
        [self.view bringSubviewToFront:secondFront];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"move");
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"end");
    UITouch *touch = [touches anyObject];
    if(touch.tapCount == 2)
    {
        NSLog(@"两次");
        self.textView.hidden = NO;
        [self.textView becomeFirstResponder];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"cancel");

}

#pragma mark - delegate

- (void)editorTextViewDidClickButton:(TIEditorTextView *)editorTextView
{
    if(!editorTextView.text || !editorTextView.text.length)
    {
        [self.array[0] removeFromSuperview];
        [self.array removeObjectAtIndex:0];
    }
    else
    {
        TILabel *label = (TILabel *)[self.array[0] attachedView];

        NSDictionary *attribute = [[label attributedText] attributesAtIndex:0 effectiveRange:NULL];
        NSAttributedString *text = [[NSAttributedString alloc] initWithString:editorTextView.text attributes:attribute];
        [label setAttributedText:text];
        [label resizeLable];
    }
    
    self.textView.text = @"双击修改";
    [self.textView resignFirstResponder];
    self.textView.hidden = YES;
}

#pragma mark - button actions

- (void)addOneLabel
{
//    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"隐约雷鸣\n阴霾天空\n但盼雨来\n能留你在此地"];
//    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"是啊\n啊啊\n啊啊\n氨基\n酸的\n你妹"];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"双击修改"];

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
    label.backgroundColor = [UIColor yellowColor];
//    label.attributedText = text;
    label.text = @"隐约雷鸣\n阴霾天空\n但盼雨来\n能留你在此地";
    label.font = [UIFont fontWithName:@"HYHeiLiZhiTiJ" size:31];
    label.numberOfLines = 0;
    [label resizeLable];
    TIViewResizeView *resizeView = [[TIViewResizeView alloc] initWithAttachedView:label];
//    [self.view addSubview:label];
    [self.view addSubview:resizeView];
    [self.array addObject:resizeView];
}

#pragma mark - getter

- (UIButton *)addButton
{
    if(!_addButton)
    {
        _addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [_addButton addTarget:self action:@selector(addOneLabel) forControlEvents:UIControlEventTouchUpInside];
        _addButton.center = CGPointMake(30, 30);
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
        _textView.hidden = YES;
        _textView.editorDelegate = self;
    }
    return _textView;
}

@end
