//
//  TIEditorTextView.m
//  EventHandleDemo
//
//  Created by lisaike on 15/8/14.
//  Copyright (c) 2015年 lisaike. All rights reserved.
//

#import "TIEditorTextView.h"

static CGFloat const BUTTON_SIZE = 25;

@interface TIEditorTextView ()

@property (nonatomic, strong) UIButton *button;

@end

@implementation TIEditorTextView

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        _button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, BUTTON_SIZE, BUTTON_SIZE)];
        _button.center = CGPointMake(CGRectGetWidth(frame) - BUTTON_SIZE, CGRectGetHeight(frame) / 2);
        _button.backgroundColor = [UIColor yellowColor];
        _button.layer.cornerRadius = BUTTON_SIZE / 2;
        [_button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
        self.backgroundColor = [UIColor colorWithWhite:0.95 alpha:0.5];
        [self addSubview:_button];
    }
    return self;
}

#pragma mark - button action

- (void)buttonAction
{
    if(self.editorDelegate && [self.editorDelegate respondsToSelector:@selector(editorTextViewDidClickButton:)])
    {
        [self.editorDelegate editorTextViewDidClickButton:self];
    }
}


@end
