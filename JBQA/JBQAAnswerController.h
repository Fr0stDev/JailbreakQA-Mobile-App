//
//  JBQAAnswerController.h
//  JBQA
//
//  Created by Aditya KD on 30/08/12.
//  Copyright (c) 2012 Fr0st Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JBQAAnswerController : UIViewController <UITextViewDelegate, UIWebViewDelegate>
{
    NSString *_answerText;
    NSString  *_questionID;
    
    CGFloat animatedDistance;
}

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *submitButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) IBOutlet UIWebView *answerWebView;
@property (weak, nonatomic) IBOutlet UITextView *answerTextField;
@property (nonatomic) NSString *questionID;

- (void)submitAnswerWithText:(NSString *)answer forQuestion:(int)questionID;

@end
