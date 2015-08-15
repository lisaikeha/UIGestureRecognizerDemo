//
//  TILabel.h
//  EventHandleDemo
//
//  Created by lisaike on 15/8/12.
//  Copyright (c) 2015年 lisaike. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TIViewResizeView.h"

@interface TILabel : UILabel<TIViewResizeViewDelegate>

- (void)resizeLable;

@end
