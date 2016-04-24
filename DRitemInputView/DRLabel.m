//
//  DRLabel.m
//  DRitemInputView
//
//  Created by 明瑞 on 16/4/24.
//  Copyright © 2016年 Mailtime. All rights reserved.
//

#import "DRLabel.h"
@interface DRLabel()
{
    CGFloat padding_top, padding_left;
}
@property (nonatomic, strong) UILongPressGestureRecognizer * longpress;
@end


@implementation DRLabel

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        padding_left = padding_top = 0;
        [self setAutocorrectionType:UITextAutocorrectionTypeNo];
    }
    return self;
}

- (void)configureLabelPadding:(CGFloat)top left:(CGFloat)left{
    padding_left = left;
    padding_top = top;
}

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, padding_left, padding_top);
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, padding_left, padding_top);
}

-(void)deleteBackward;
{
    if (self.text.length == 0)
        if ([_LabelDelegate respondsToSelector:@selector(textFieldDidDelete:)]){
            [_LabelDelegate textFieldDidDelete:self];
        }
    [super deleteBackward];
    
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(select:) ||
        action == @selector(selectAll:) ||
        action == @selector(copy:) ||
        action == @selector(paste:))
        if (_labelmode)
            return NO;
    return [super canPerformAction:action withSender:sender];
}

- (void)setLabelmode:(BOOL)labelmode{
    _labelmode = labelmode;
    if (labelmode){
        _longpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
        _longpress.minimumPressDuration = 0.9f;
        _longpress.numberOfTapsRequired = 0;
        
        //if it's label mode, we should cancel all the default gesture recognizers for UITextField
        for (UIGestureRecognizer * gesture in self.gestureRecognizers)
             [self removeGestureRecognizer:gesture];
        
        [self addGestureRecognizer:_longpress];
    }
}

- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer{
    //if it's label mode, we should cancel all the default gesture recognizers for UITextField
    if (_labelmode){
        if (gestureRecognizer != _longpress)
            return;
    }
    [super addGestureRecognizer:gestureRecognizer];
}

-(void)longPressed:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (!self.LabelDelegate) return;
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        [self.LabelDelegate longPressStarted:self];
    }
    else if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        [self.LabelDelegate longPressFinished:self];
    }
}

@end
