//
//  DRItemInputView.h
//  DRitemInputView
//
//  Created by 明瑞 on 16/4/22.
//  Copyright © 2016年 Mailtime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRLabel.h"

@protocol DRItemInputViewDelegate <NSObject>
- (void)DRItemInputViewLabelTapped:(UITextField*)label atIndex:(NSInteger)idx;
- (void)DRItemInputViewSizeChanged;
@end

@interface DRItemInputView : UIScrollView

@property (nonatomic, strong) DRLabel * textfield;
@property (nonatomic, weak) id<DRItemInputViewDelegate> DRdelegate;

//be sure set following methods before showing the View if you want these traits
//or they will take place only after the method being called.
- (void)setMaxRow:(NSInteger)rows;

- (void)setMaxLabelWidth:(CGFloat)width;

- (void)setLabelMarginBottom:(CGFloat)margin_bottom Right:(CGFloat)margin_right;

- (void)setContentMarginTop:(CGFloat)margin_top Left:(CGFloat)margin_left;

- (void)setLabelInsetTop:(CGFloat)top left:(CGFloat)left;

- (void)setLabelFont:(UIFont*)font;

- (void)setLabelBorderAsCircle;

- (void)configureLabeltextColor:(UIColor*)tcolor CornerRadius:(CGFloat)radius boarderWidth:(CGFloat)width boarderColor:(UIColor*)bordercolor andBackgroundColor:(UIColor*)bgcolor;

- (void)configureLabelSelectedtextColor:(UIColor*)tcolor BoarderColor:(UIColor*)bordercolor andBackgroundColor:(UIColor*)bgcolor;

- (void)setPlaceHolder:(NSString*)placeholder;

//this method will give you the height of one row
//you can call this after all configurations
//and set the view's frame height referring to the value returned
- (CGFloat)calculateRowHeight;

//call these methods anytime after showing the view:)
- (void)deleteSelectedLabel;

- (void)deleteLabelAtIndex:(NSInteger)idx;

- (void)appendLabelwithTextFieldText;

- (void)appendLabelwithText:(NSString*)text;

- (void)appendLabelwithText:(NSString*)text backgroundColor:(UIColor*)color;

- (void)selectLastLabel;

- (void)changeLabelToSelecte:(NSInteger)idx;

- (void)changeLabelToUnselecte:(NSInteger)idx;

- (void)deselectAllLabel;

- (BOOL)hasSelectedLabel;

@end
