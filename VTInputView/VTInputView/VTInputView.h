//
//  VTInputView.h
//  VTInputView
//
//  Created by Soliton-Mac on 1/4/17.
//  Copyright © 2017 VinhVu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, VTInputViewStyle) {
    Normal = 0,
    Login
};

typedef void(^VTInputViewActionCompleted)(void);

@protocol VTInputViewDelegate <NSObject>

@optional
- (void)touchSubmit;
- (void)touchCancel;
@end

@interface VTInputView : UIView<UITextFieldDelegate>

@property (strong, nonatomic) id<VTInputViewDelegate> delegate;

@property (strong, nonatomic) VTInputViewActionCompleted touchSubmitCompleted;
@property (strong, nonatomic) VTInputViewActionCompleted touchCancelCompleted;

//text
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* message;
@property (strong, nonatomic) NSString* submitButtonText;
@property (strong, nonatomic) NSString* cancelButtonText;

@property (strong, nonatomic) NSString* inputPlaceholderText;
@property (strong, nonatomic) NSString* securePlaceholderText;

//Textfield
@property (strong, nonatomic) UITextField* textInput;
@property (strong, nonatomic) UITextField* secureInput;

@property (assign, nonatomic) VTInputViewStyle style;

@property (assign, nonatomic) UIBlurEffectStyle blurEffectStyle;
@property (strong, nonatomic) UIVisualEffectView* visualEffectView;

@property (strong, nonatomic) NSMutableArray* elements;

@property (strong, nonatomic) UIView* backgroundView;

- (void)show;
- (void)hide;
@end
