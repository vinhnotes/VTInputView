//
//  VTInputView.m
//  VTInputView
//
//  Created by Soliton-Mac on 1/4/17.
//  Copyright © 2017 VinhVu. All rights reserved.
//

#import "VTInputView.h"

#define KEYBOARD_ANIMATION_DURATION     0.3f
#define MINIMUM_SCROLL_FRACTION         0.2f
#define MAXIMUM_SCROLL_FRACTION         0.8f
#define PORTRAIT_KEYBOARD_HEIGHT        216
#define LANDSCAPE_KEYBOARD_HEIGHT       162


@interface VTInputView()<CAAnimationDelegate>
@property (nonatomic, assign) float animatedDistance;

@end

@implementation VTInputView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
- (void)show{
    self.alpha = 0;
    self.backgroundView.alpha = 0;
    [self setupView];
    
    CGRect frame = self.frame;
    CGFloat y = frame.origin.y;
    frame.origin.y = 0;
    self.frame = frame;
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.textInput becomeFirstResponder];
        CGRect frame = self.frame;
        frame.origin.y = y;
        self.frame = frame;
        self.alpha = 1;
        self.backgroundView.alpha = 1;
    }];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    UIWindow* window = [UIApplication sharedApplication].windows.firstObject;
    self.backgroundView = [[UIView alloc] initWithFrame:window.frame];
    self.backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.backgroundView addGestureRecognizer:singleFingerTap];
    
    [window addSubview:self.backgroundView];
    
    [window addSubview:self];
    [window bringSubviewToFront:self];
}

- (void)deviceOrientationDidChange{
    [self resetFrame:YES];
}
- (void)resetFrame: (BOOL)animated{
    CGFloat topMargin = (self.style == Login) ? 0.0f : 45.0f;
    UIWindow* window = [UIApplication sharedApplication].windows.firstObject;
    if (animated){
        [UIView animateWithDuration:0.3 animations:^{
            self.center = CGPointMake(window.center.x, window.center.y - topMargin);
        }];
    } else {
        self.center = CGPointMake(window.center.x, window.center.y - topMargin);
    }
    
    self.backgroundView.frame = window.bounds;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer{
    [self hide];
}
- (void)hide{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.frame;
        frame.origin.y = 0;
        self.frame = frame;
        self.alpha=0;
        self.backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [self endEditing:YES];
        [self removeFromSuperview];
        [self.backgroundView removeFromSuperview];
    }];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}
- (void)setupView{
    self.elements = [[NSMutableArray alloc] init];
    self.layer.cornerRadius = 4.0f;
    self.layer.masksToBounds = YES;
    
    self.visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:self.blurEffectStyle?self.blurEffectStyle:UIBlurEffectStyleExtraLight]];
    
    //Constants
    CGFloat padding = 20.0f;
    CGFloat width = self.frame.size.width - padding*2;
    
    //Labels
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, padding, width, 20)];
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.text = self.title;
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor darkTextColor]];
    [self.visualEffectView.contentView addSubview:titleLabel];
    
    //TextFields
    switch (self.style) {
        case Normal:
            self.textInput = [[UITextField alloc] initWithFrame:CGRectMake(padding, titleLabel.frame.origin.y + titleLabel.frame.size.height + padding / 1.5, width, 35)];
            [self.textInput setTextAlignment:NSTextAlignmentLeft];
            [self.textInput setTextColor:[UIColor darkTextColor]];
            [self.textInput setPlaceholder:self.inputPlaceholderText.length>0?self.inputPlaceholderText:@"soliton keymanager"];
            [self.elements addObject:self.textInput];
            break;
        case Login:
            self.textInput = [[UITextField alloc] initWithFrame:CGRectMake(padding, titleLabel.frame.origin.y + titleLabel.frame.size.height + padding / 1.5, width, 35)];
            [self.textInput setTextAlignment:NSTextAlignmentLeft];
            [self.textInput setTextColor:[UIColor darkTextColor]];
            [self.textInput setPlaceholder:self.inputPlaceholderText.length>0?self.inputPlaceholderText:@"soliton keymanager"];
            [self.elements addObject:self.textInput];
            
            //Password Field
            self.secureInput = [[UITextField alloc] initWithFrame:CGRectMake(padding, self.textInput.frame.origin.y + self.textInput.frame.size.height + padding / 2, width, 35)];
            [self.secureInput setTextAlignment:NSTextAlignmentLeft];
            [self.secureInput setTextColor:[UIColor darkTextColor]];
            [self.secureInput setPlaceholder:self.securePlaceholderText.length>0?self.securePlaceholderText:@"password"];
            self.secureInput.secureTextEntry = YES;
            
            [self.elements addObject:self.secureInput];
            
            CGRect extendedFrame = self.frame;
            extendedFrame.size.height += 20;
            self.frame = extendedFrame;
            break;
        default:
            break;
    }
    for (UITextField* element in self.elements){
        element.delegate = self;
        element.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1].CGColor;
        element.layer.borderWidth = 0.5f;
        element.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        [self.visualEffectView.contentView addSubview:element];
    }
    
    //Buttons
    CGFloat buttonHeight = 45.0f;
    CGFloat buttonWidth = self.frame.size.width/2;
    
    UIButton* cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.frame.size.height - buttonHeight, buttonWidth, buttonHeight)];
    [cancelButton setTitle:self.cancelButtonText.length>0?self.cancelButtonText:@"Cancel" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [cancelButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    cancelButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
    cancelButton.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.1].CGColor;
    cancelButton.layer.borderWidth = 1.0f;
    [self.visualEffectView.contentView addSubview:cancelButton];
    
    UIButton* submitButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonWidth, self.frame.size.height - buttonHeight, buttonWidth, buttonHeight)];
    [submitButton setTitle:self.submitButtonText.length>0?self.submitButtonText:@"OK" forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(submitButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    submitButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:0.2];
    [submitButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [submitButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    submitButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
    submitButton.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.1].CGColor;
    submitButton.layer.borderWidth = 1.0f;
    [self.visualEffectView.contentView addSubview:submitButton];
    
    self.visualEffectView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self addSubview:self.visualEffectView];
}
- (void)cancelButtonTapped{
    if (self.delegate && [self.delegate respondsToSelector:@selector(touchCancel)]){
        [self.delegate touchCancel];
    }
    if (self.touchCancelCompleted){
        self.touchCancelCompleted();
    }
    [self hide];
}
- (void)submitButtonTapped{
    if (self.delegate && [self.delegate respondsToSelector:@selector(touchSubmit)]){
        [self.delegate touchSubmit];
    }
    if (self.touchSubmitCompleted){
        self.touchSubmitCompleted();
    }
    [self hide];
}



-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self endEditing:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSInteger index = [self.elements indexOfObject:textField];
    if (index < self.elements.count - 1) {
        UITextField *nextField = [self.elements objectAtIndex:index + 1];
        [nextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    //    UIInterfaceOrientation orientation =  [[UIApplication sharedApplication] statusBarOrientation];
    CGRect textFieldRect = [self.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [self.window convertRect:self.bounds fromView:self];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
    midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
    (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    self.animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    CGRect viewFrame = self.frame;
    viewFrame.origin.y -= self.animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self setFrame:viewFrame];
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    CGRect viewFrame = self.frame;
    viewFrame.origin.y += self.animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self setFrame:viewFrame];
    [UIView commitAnimations];
}
@end
