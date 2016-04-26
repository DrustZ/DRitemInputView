//
//  DRItemInputView.m
//  DRitemInputView
//
//  Created by 明瑞 on 16/4/22.
//  Copyright © 2016年 Mailtime. All rights reserved.
//

#import "DRItemInputView.h"

void changeViewHeightAndWidth(UIView * view, CGFloat height, CGFloat width){
    if (height < 0)
        height = view.frame.size.height;
    if (width < 0)
        width = view.frame.size.width;
    [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, width, height)];
}

/*
layout: 
    *--------------------------------------------*
    |left/top content_margin                     |
    |   *----------------------------------------*
    |   |  |<---label(textfield)-->||<-label->|  | row
    |   |  |<---label-->||<-label->||<-label-->| | row
    |   |  |<-label-->||<--     inputview    -->|| row
    *---*----------------------------------------*
        you can configure content's top/left margin 
        each label's margin-x(width)/y(height)
*/

/*
 label layout: 
 label space:
 *------------------------------------*     ----
 |*----------------*                  |
 ||  actual label  | (label_margin_x) |     row
 |*----------------*                  |
 |      (label_margin_y)              |     height
 *------------------------------------*     -----
 
 */


@interface DRItemInputView ()
{
    NSInteger maxrow;
    
    CGFloat initial_height;             //the init frame height(set by you) when displayed
    CGFloat max_label_width;
    CGFloat label_height;
    CGFloat label_border_width;
    CGFloat label_radius;
    CGFloat width_now;                  //the total width of content in the bottom line (without last input view)
    CGFloat height_now;                 //the total height of all contents
    CGFloat row_now;                    //total rows in the view
    CGFloat label_margin_x;
    CGFloat label_margin_y;
    CGFloat input_min_width;
    CGFloat content_margin_top;
    CGFloat content_margin_left;
    CGFloat label_pad_top;
    CGFloat label_pad_left;
    BOOL circleborder;
}

@property (nonatomic, strong) UIFont  * font;
@property (nonatomic, strong) UIColor * label_text_color;
@property (nonatomic, strong) UIColor * label_bg_color;
@property (nonatomic, strong) UIColor * label_border_color;
@property (nonatomic, strong) UIColor * sel_label_text_color;
@property (nonatomic, strong) UIColor * sel_label_bg_color;
@property (nonatomic, strong) UIColor * sel_label_border_color;
@property (nonatomic, strong) NSString * place_holder;
@property (nonatomic, strong) DRLabel * last_tapped_label;
@property (nonatomic, strong) NSMutableArray * label_array;
@end

@implementation DRItemInputView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        maxrow = 3;
        max_label_width = 0;
        label_height = 0;
        label_radius = 5;
        label_border_width = 0;
        _label_array = [NSMutableArray new];
        input_min_width = 50;

        label_margin_x = 7;
        label_margin_y = 7;
        label_pad_top = 1;
        label_pad_left = 3;
        content_margin_top = 4;
        content_margin_left = 4;
    
        row_now = 1;
        _textfield = [DRLabel new];
    }
    return self;
}

- (void)willMoveToWindow:(UIWindow *)newWindow{
    width_now = content_margin_left;
    height_now = content_margin_top;
    initial_height = self.frame.size.height;
    
    CGFloat biggest_width = self.frame.size.width - label_margin_x - content_margin_left;
    if (max_label_width == 0 || max_label_width > biggest_width)
        max_label_width = biggest_width;
    
    if (label_height == 0)
        [self calculateRowHeight];
    height_now  += label_height + label_margin_y;
    
    [_textfield setFrame:CGRectMake(content_margin_left, content_margin_top, self.frame.size.width-label_margin_x-content_margin_left, label_height)];
    [_textfield setTextAlignment:NSTextAlignmentLeft];
    [_textfield setPlaceholder:_place_holder];
    if (_label_text_color)
        [_textfield setTintColor:_label_text_color];
        
//    _textfield.layer.borderWidth = 1;
//    _textfield.layer.borderColor = [UIColor blackColor].CGColor;
    [self addSubview:_textfield];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped:)];
    [self addGestureRecognizer:tap];
}

- (CGFloat)calculateRowHeight{
    //small trick to get correct height
    DRLabel * label = [DRLabel new];
    [self setLabel:label isInitialize:YES];
    [label setText:@"A"];
    [label sizeToFit];
    label_height = label.frame.size.height;
    label = nil;
    return label_height + content_margin_top + label_margin_y;
}

#pragma mark init configurations
- (void)setContentMarginTop:(CGFloat)margin_top Left:(CGFloat)margin_left{
    content_margin_top = margin_top;
    content_margin_left = margin_left;
}

- (void)setLabelMarginBottom:(CGFloat)margin_bottom Right:(CGFloat)margin_right{
    label_margin_x = margin_right;
    label_margin_y = margin_bottom;
}

- (void)setLabelInsetTop:(CGFloat)top left:(CGFloat)left{
    label_pad_left = left;
    label_pad_top = top;
}

- (void)setMaxRow:(NSInteger)rows{
    maxrow = rows;
}

- (void)setMaxLabelWidth:(CGFloat)width{
    max_label_width = width;
}

- (void)setLabelFont:(UIFont*)font{
    _font = font;
}

- (void)setLabelBorderAsCircle{
    circleborder = YES;
}

- (void)setPlaceHolder:(NSString*)placeholder{
    _place_holder = placeholder;
}

- (void)configureLabeltextColor:(UIColor*)tcolor CornerRadius:(CGFloat)radius boarderWidth:(CGFloat)width boarderColor:(UIColor*)bordercolor andBackgroundColor:(UIColor*)bgcolor{
    label_radius = radius;
    label_border_width = width;
    _label_text_color = tcolor;
    _label_border_color = bordercolor;
    _label_bg_color = bgcolor;
}

- (void)configureLabelSelectedtextColor:(UIColor*)tcolor BoarderColor:(UIColor*)bordercolor andBackgroundColor:(UIColor*)bgcolor{
    _sel_label_text_color = tcolor;
    _sel_label_border_color = bordercolor;
    _sel_label_bg_color = bgcolor;
}

#pragma mark delete method
- (void)deleteSelectedLabel{
    if (!_last_tapped_label) return;
    [self deleteLabelAtIndex:[self.label_array indexOfObject:_last_tapped_label]];
}

- (void)deleteLabelAtIndex:(NSInteger)idx{
    if (idx >= [_label_array count]) return;
    DRLabel * del_label = _label_array[idx];
    [_label_array removeObject:del_label];
    if (del_label == _last_tapped_label) _last_tapped_label = nil;
    
    __block CGPoint oldoffset = [self contentOffset];
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [del_label removeFromSuperview];
        
        CGFloat width_last = del_label.frame.origin.x;
        CGFloat height_last = del_label.frame.origin.y;
        for (NSInteger i = idx, len = _label_array.count; i < len; ++i){
            DRLabel * label = _label_array[i];
            CGFloat width = label.frame.size.width;
            CGFloat height = label.frame.size.height;
            //if we can put the next label in this blank
            if (width_last + width + label_margin_x <= self.frame.size.width){
                [label setCenter:CGPointMake(width_last+width/2, height_last+height/2)];
                width_last += width + label_margin_x;
            }
            else {
                height_last += label_height+label_margin_y;
                width_last = content_margin_left;
                [label setCenter:CGPointMake(width_last+width/2, height_last+height/2)];
                width_last += width + label_margin_x;
            }
        }
        width_now = width_last;
        height_now = height_last + label_height + label_margin_y;
        
        row_now = (height_now-content_margin_top) / (label_margin_y + label_height);
        [self resizeInputView];
        if (row_now < maxrow){
            changeViewHeightAndWidth(self, MAX(height_now,initial_height), -1);
            if (self.DRdelegate)
                [self.DRdelegate DRItemInputViewSizeChanged];
        }
        [self setContentSize:CGSizeMake(self.frame.size.width, height_now)];
        //after delete, the cursor will show
        [self.textfield becomeFirstResponder];
        //and return to the offset before delete
        if (row_now < maxrow)
            [self setContentOffset:CGPointZero];
        else{
            if (oldoffset.y + self.frame.size.height > self.contentSize.height)
                oldoffset = CGPointMake(0, self.contentSize.height - self.frame.size.height);
            [self setContentOffset:oldoffset animated:NO];
        }
    } completion:nil];
    
    if (_label_array.count == 0)
        [self.textfield setPlaceholder:_place_holder];
}

#pragma mark append method
- (void)appendLabelwithTextFieldText{
    [self appendLabelwithText:self.textfield.text];
}

- (void)appendLabelwithText:(NSString*)text{
    [self appendLabelwithText:text backgroundColor:nil];
}

- (void)appendLabelwithText:(NSString*)text backgroundColor:(UIColor*)color{
    if (text.length <= 0) return;
    self.textfield.placeholder = nil;
    
    //alloc a new label
    DRLabel * label = [DRLabel new];
    label.labelmode = true;
    
    //get the size
    [self setLabel:label isInitialize:YES];
    [label setText:text];
    [label sizeToFit];
    
    label.enabled = NO;
    label.userInteractionEnabled = NO;
    [label setTintColor:[UIColor clearColor]];
    
    if (_textfield.delegate)
        label.delegate = _textfield.delegate;
    
    if (label.frame.size.width > max_label_width)
        [label setFrame:CGRectMake(0, 0, max_label_width, label.frame.size.height)];
    
    NSInteger rowBefore = row_now, rowAdded = 0;
    //check label overflow
    CGFloat centerx = 0, centery = 0;
    if (width_now + label_margin_x + label.frame.size.width > self.frame.size.width){
        row_now += 1;
        rowAdded += 1;
        //start a new row
        centerx = content_margin_left + label.frame.size.width/2;
        centery = height_now + label.frame.size.height/2;
        height_now += label.frame.size.height + label_margin_y;
        width_now = content_margin_left + label_margin_x + label.frame.size.width;
    }
    else {
        centery = height_now - label_margin_y - label.frame.size.height/2;
        centerx = width_now + label.frame.size.width/2;
        width_now += label_margin_x + label.frame.size.width;
    }
    [label setCenter:CGPointMake(centerx, centery)];
    [self.label_array addObject:label];

    //display animation
    //first we need to adjust scroll view's frame
    if (width_now + input_min_width > self.frame.size.width){
        rowAdded += 1;
    }
    if (rowBefore < maxrow && rowAdded > 0){
        CGFloat changeHeight = (rowBefore + rowAdded) > maxrow ? maxrow * (label_margin_y + label_height) : (rowAdded + rowBefore) * (label_margin_y + label_height);
        changeHeight += content_margin_top;
        if (changeHeight > self.frame.size.height){
            changeViewHeightAndWidth(self, changeHeight, -1);
            if (self.DRdelegate)
                [self.DRdelegate DRItemInputViewSizeChanged];
        }
    }
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self resizeInputView];
        [self addSubview:label];
        if (rowBefore+rowAdded > maxrow && rowAdded > 0){
            [self setContentSize:CGSizeMake(self.frame.size.width, height_now)];
            [self scrollToBottom];
        }
    } completion:nil];
}

#pragma mark label settings
//set initial style of the label, if initial == false, we also hide the keyboard
- (void)setLabel:(DRLabel*)label isInitialize:(BOOL)initial{
    [label setTextAlignment:NSTextAlignmentCenter];
    if (_label_text_color)
        [label setTextColor:_label_text_color];
    else [label setTextColor:[UIColor blackColor]];
    
    if (_label_bg_color)
        [label setBackgroundColor:_label_bg_color];
    else [label setBackgroundColor:[UIColor whiteColor]];
    
    if (_label_border_color)
        [label.layer setBorderColor:_label_border_color.CGColor];
    else [label.layer setBorderColor:[UIColor blackColor].CGColor];
    
    if (!initial){
        [label resignFirstResponder];
        [label setUserInteractionEnabled:NO];
        [label setEnabled:NO];
        return;
    }
    
    [label configureLabelPadding:label_pad_top left:label_pad_left];
    if (_font)
        [label setFont:_font];
    if (label_border_width > 0)
        [label.layer setBorderWidth:label_border_width];
    if (circleborder)
        [label.layer setCornerRadius:label_height/2];
    else if (label_radius > 0)
        [label.layer setCornerRadius:label_radius];
}

//set selected style of the label
- (void)setSelectedLabel:(DRLabel*)label{
   
    if (_sel_label_text_color)
        [label setTextColor:_sel_label_text_color];
    if (_sel_label_bg_color)
        [label setBackgroundColor:_sel_label_bg_color];
    if (_sel_label_border_color)
        [label.layer setBorderColor:_sel_label_border_color.CGColor];
    
    [self.textfield resignFirstResponder];
    [label setUserInteractionEnabled:YES];
    [label setEnabled:YES];
    [label becomeFirstResponder];
}

//resize the input textfield
- (void)resizeInputView{
    //check input textfield overflow
    if (width_now + input_min_width > self.frame.size.width){
        row_now ++;
        width_now = content_margin_left;
        [_textfield setFrame:CGRectMake(width_now, height_now, self.frame.size.width-width_now, label_height)];
        height_now += label_height + label_margin_y;
    } else {
        [_textfield setFrame:CGRectMake(width_now, height_now - label_height - label_margin_y, self.frame.size.width-width_now, label_height)];
    }
}

- (void)scrollToBottom {
    [self scrollRectToVisible:CGRectMake(self.contentSize.width - 1,self.contentSize.height - 1, 1, 1) animated:YES];
}

- (void)labelTapped:(UIGestureRecognizer*)recognizer{
    CGPoint loc = [recognizer locationInView:self];
    for (NSInteger i = 0, cnt = _label_array.count; i < cnt; ++i){
        DRLabel * label = _label_array[i];
        if (CGRectContainsPoint(label.frame, loc)){
            if (_last_tapped_label == label) return;
            if (self.DRdelegate)
                [self.DRdelegate DRItemInputViewLabelTapped:label atIndex:i];
            if (_last_tapped_label)
                [self setLabel:_last_tapped_label isInitialize:NO];
            _last_tapped_label = label;
            [self setSelectedLabel:label];
        }
    }
}

#pragma mark select method
- (void)selectLastLabel{
    if (_label_array.count)
        [self changeLabelToSelecte:_label_array.count-1];
}

- (void)changeLabelToSelecte:(NSInteger)idx{
    if (idx >= _label_array.count) return;
    DRLabel * label = _label_array[idx];
    if (_last_tapped_label != label && _last_tapped_label){
        [self setLabel:_last_tapped_label isInitialize:NO];
    }
    _last_tapped_label = label;
    [self setSelectedLabel:label];
}

#pragma mark deselect method
- (void)deselectAllLabel{
    if (_last_tapped_label){
        [self setLabel:_last_tapped_label isInitialize:NO];
        _last_tapped_label = nil;
        [_last_tapped_label resignFirstResponder];
        [_last_tapped_label setUserInteractionEnabled:NO];
        [_last_tapped_label setEnabled:NO];
        [self.textfield becomeFirstResponder];
    }
}

- (void)changeLabelToUnselecte:(NSInteger)idx{
    if (idx >= _label_array.count) return;
    DRLabel * label = _label_array[idx];
    if (_last_tapped_label)
        [self setLabel:_last_tapped_label isInitialize:NO];
    _last_tapped_label = nil;
    [self setLabel:label isInitialize:NO];
    [label resignFirstResponder];
    [label setUserInteractionEnabled:NO];
    [label setEnabled:NO];
    [self.textfield becomeFirstResponder];
}

- (BOOL)hasSelectedLabel{
    return (_last_tapped_label != NULL);
}

@end
