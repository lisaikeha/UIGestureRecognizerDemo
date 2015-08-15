//
//  TIEditorTextView.h
//  EventHandleDemo
//
//  Created by lisaike on 15/8/14.
//  Copyright (c) 2015年 lisaike. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TIEditorTextView;
@protocol TIEditorTextViewDelegate <UITextViewDelegate>

- (void)editorTextViewDidClickButton:(TIEditorTextView *)editorTextView;

@end

@interface TIEditorTextView : UITextView

@property (nonatomic, assign) id<TIEditorTextViewDelegate> editorDelegate;

@end
