//
//  UITextView+Placeholder.h
//
//  Created by jianglang on 2019/8/5.
//  Copyright © 2019 jianglang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextView (Placeholder)

@property (readonly,nonatomic,strong)UILabel *placeholderLabel;
@property (nullable,nonatomic,strong)UIColor *placeholderColor;
@property (nullable,nonatomic,copy)NSString *placeholder;
@property (nullable,nonatomic,copy)NSAttributedString *attributedPlaceholder;

@end

NS_ASSUME_NONNULL_END
