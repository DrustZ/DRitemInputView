//
//  DRLabel.h
//  DRitemInputView
//
//  Created by 明瑞 on 16/4/24.
//  Copyright © 2016年 Mailtime. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DRLabel;

@protocol DRLabelDelegate <NSObject>
@optional
- (void)textFieldDidDelete:(DRLabel*)label;
- (void)longPressStarted:(DRLabel*)label;
- (void)longPressFinished:(DRLabel*)label;
@end

@interface DRLabel : UITextField <UITextFieldDelegate>

@property (nonatomic, weak) id<DRLabelDelegate> LabelDelegate;
@property (nonatomic, assign) BOOL labelmode;
- (void)configureLabelPadding:(CGFloat)top left:(CGFloat)left;

@end
