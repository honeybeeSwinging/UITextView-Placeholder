//
//  ViewController.m
//  TextViewExtension
//
//  Created by jianglang on 2019/8/5.
//  Copyright © 2019 jianglang. All rights reserved.
//

#import "ViewController.h"
#import "UITextView+Placeholder.h"

@interface ViewController ()

@property (nonatomic,strong)UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(100, 100, 200, 200)];
    textView.backgroundColor = [UIColor purpleColor];
    textView.placeholder = @"Hello World";
    textView.placeholderColor = [UIColor whiteColor];
    [self.view addSubview:textView];
    self.textView = textView;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.textView.font = [UIFont systemFontOfSize:20];
}

@end
