//
//  UITextView+Placeholder.m
//
//  Created by jianglang on 2019/8/5.
//  Copyright © 2019 jianglang. All rights reserved.
//

#import "UITextView+Placeholder.h"
#import <objc/runtime.h>

@implementation UITextView (Placeholder)

+ (void)load{
    Method oldDealloc = class_getInstanceMethod([self class], NSSelectorFromString(@"dealloc"));
    Method newDealloc = class_getInstanceMethod([self class], sel_registerName("jl_dealloc"));
    method_exchangeImplementations(oldDealloc, newDealloc);
}

#pragma mark - LifeCycle

- (void)jl_dealloc{
    for (NSString *key in [UITextView getObserveKeyArr]) {
        @try {
            //主要目的防止崩溃
            [self removeObserver:self forKeyPath:key];
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    }
    objc_removeAssociatedObjects(@"placeholderLabel");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self jl_dealloc];
}

#pragma mark - NotificationEvent

- (void)textDidChangeNotification:(NSNotification *)sender{
    [self updatePlaceholderLabelFrame];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"font"]){
        self.placeholderLabel.font = self.font;
    }else if ([keyPath isEqualToString:@"textAlignment"]){
        self.placeholderLabel.textAlignment = self.textAlignment;
    }else if ([keyPath isEqualToString:@"attributedText"]){
        //可能是字体大小发生变化,placeholderLabel的font保持和textView的font一致，除非自己定义了attributedPlaceholder
        self.placeholderLabel.font = self.font;
    }
    [self updatePlaceholderLabelFrame];
}

#pragma mark - Private

- (NSString *)placeholder{
    return self.placeholderLabel.text;
}

- (void)setPlaceholder:(NSString *)placeholder{
    self.placeholderLabel.text = placeholder;
    [self updatePlaceholderLabelFrame];
}

- (NSAttributedString *)attributedPlaceholder{
    return self.placeholderLabel.attributedText;
}

- (void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder{
    self.placeholderLabel.attributedText = attributedPlaceholder;
    [self updatePlaceholderLabelFrame];
}

- (UIColor *)placeholderColor{
    return self.placeholderLabel.textColor;
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor{
    self.placeholderLabel.textColor = placeholderColor;
}

- (void)updatePlaceholderLabelFrame{
    
    if (self.text.length != 0) {
        self.placeholderLabel.hidden = YES;
        return;
    }
    
    self.placeholderLabel.hidden = NO;
    
    //负责更新布局
    UIEdgeInsets textContainerInset;
    CGFloat leftRightMargin;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        textContainerInset = self.textContainerInset;
        leftRightMargin = self.textContainer.lineFragmentPadding;
    }else{
        textContainerInset = UIEdgeInsetsMake(8, 0, 8, 0);
        leftRightMargin = 5;
    }
    textContainerInset.left += leftRightMargin;
    textContainerInset.right += leftRightMargin;
    
    CGFloat placeholderLabelX = textContainerInset.left;
    CGFloat placeholderLabelY = textContainerInset.top;
    CGFloat placeholderLabelW = self.frame.size.width - placeholderLabelX - textContainerInset.right;
    CGFloat placeholderLabelEstimateH = self.frame.size.height - placeholderLabelY - textContainerInset.bottom;
    CGFloat placeholderLabelH = [self.placeholderLabel sizeThatFits:CGSizeMake(placeholderLabelW, placeholderLabelEstimateH)].height;
    self.placeholderLabel.frame = CGRectMake(placeholderLabelX, placeholderLabelY, placeholderLabelW, placeholderLabelH);
}

#pragma mark - LazyLoad

- (UILabel *)placeholderLabel{
    UILabel *placeholderLabel = objc_getAssociatedObject(self, @"placeholderLabel");
    if (!placeholderLabel) {
        placeholderLabel = [[UILabel alloc] init];
        placeholderLabel.numberOfLines = 0;
        placeholderLabel.textColor = [UITextView defaultColor];
        placeholderLabel.font = [UITextView defaultFont];
        placeholderLabel.hidden = YES;
        objc_setAssociatedObject(self, @"placeholderLabel", placeholderLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChangeNotification:) name:UITextViewTextDidChangeNotification object:nil];
        for (NSString *key in [UITextView getObserveKeyArr]) {
            [self addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:nil];
        }
        [self insertSubview:self.placeholderLabel atIndex:0];
    }
    return placeholderLabel;
}

+ (NSArray *)getObserveKeyArr{
    return @[@"attributedText",
             @"bounds",
             @"font",
             @"frame",
             @"textAlignment",
             @"textContainerInset"];
}

+ (UIColor *)defaultColor{
    static UIColor *color = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        UITextField *textField = [[UITextField alloc] init];
        textField.placeholder = @" ";
        //系统的textField的placeholder是懒加载
        color = [textField valueForKeyPath:@"_placeholderLabel.textColor"];
    });
    return color;
}

+ (UIFont *)defaultFont{
    static UIFont *font = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        UITextView *textView = [[UITextView alloc] init];
        textView.text = @" ";
        //系统的textView的font是懒加载
        font = textView.font;
    });
    return font;
}

@end
