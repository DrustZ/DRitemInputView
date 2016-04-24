//
//  ViewController.m
//  DRitemInputView
//
//  Created by 明瑞 on 16/4/22.
//  Copyright © 2016年 Mailtime. All rights reserved.
//

#import "ViewController.h"
#import "DRItemInputView.h"

#define LIGHTBLUE [UIColor colorWithRed:93.0f/255 green:155.0f/255 blue:236.0f/255 alpha:1]

@interface ViewController () <DRItemInputViewDelegate, UITextFieldDelegate, DRLabelDelegate>
@property (weak, nonatomic) IBOutlet UITextField *delete_text;
@property (nonatomic, strong) DRItemInputView * drview;
@end

@implementation ViewController
@synthesize drview;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    // Do any additional setup after loading the view, typically from a nib.
    drview = [[DRItemInputView alloc] initWithFrame:CGRectMake(20, 40, [UIScreen mainScreen].bounds.size.width-40, 50)];
    [drview setPlaceHolder:@"  Input Item Name"];
    [drview configureLabelSelectedtextColor:[UIColor whiteColor] BoarderColor:LIGHTBLUE andBackgroundColor:LIGHTBLUE];
    [drview configureLabeltextColor:LIGHTBLUE CornerRadius:20 boarderWidth:1 boarderColor:LIGHTBLUE andBackgroundColor:[UIColor whiteColor]];
    [drview setLabelBorderAsCircle];
//    drview.layer.borderColor = [UIColor blueColor].CGColor;
//    drview.layer.borderWidth = 1;
    
    [drview setBackgroundColor:[UIColor whiteColor]];
    drview.DRdelegate = self;
    drview.textfield.delegate = self;
    drview.textfield.LabelDelegate = self;
    
    [drview setContentSize:CGSizeMake(drview.bounds.size.width, drview.bounds.size.height)];
    [self.view addSubview:drview];
}

- (IBAction)addBtnPressed:(id)sender {
    [drview appendLabelwithTextFieldText];
}

- (IBAction)deleteBtnPressed:(id)sender {
    [drview deleteLabelAtIndex:[_delete_text.text intValue]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)DRItemInputViewLabelTapped:(DRLabel *)label atIndex:(NSInteger)idx{
}

- (void)DRItemInputViewSizeChanged{
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == drview.textfield){
        if ([drview hasSelectedLabel])
            [drview deselectAllLabel];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == drview.textfield){
        if ([string  isEqual:@"\n"]){
            [drview appendLabelwithTextFieldText];
            [textField setText:nil];
            return false;
        }
        return true;
    }
    else {
        if (string.length == 0)
            [drview deleteSelectedLabel];
    }
    return false;
}

- (void)textFieldDidDelete:(DRLabel*)label{
    if (label.text.length == 0){
        [drview selectLastLabel];
    }
}

@end
