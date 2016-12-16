//
//  ViewController.m
//  InternetChat
//
//  Created by Anton Orzes on 16/10/2016.
//  Copyright © 2016 Anton Orzes. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    
    __weak IBOutlet UITextView *textScroll;
    __weak IBOutlet UITextField *messageText;
    
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)sendMessage:(id)sender {
    NSString *a =[[UIDevice currentDevice] name];
    NSString *b =messageText.text;
    NSURL *url = [NSURL URLWithString:@"http://anton-orzes.from.hr/addChatMess.php"];
    //NSURL *url = [NSURL URLWithString:@"http://192.168.1.105:8888/addChatMessage.php"];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    
    NSDictionary *dictionary = @{@"user":a, @"declaration":b};
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary
                                                   options:kNilOptions error:&error];
    
    if (!error) {
        NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                                   fromData:data completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                                       // Handle response here
                                                                   }];
        
        [uploadTask resume];
    }
    messageText.text = @"";
}

- (IBAction)getNewData:(id)sender {
    NSString     *urlString = @"http://anton-orzes.from.hr/getChat.php?";
    NSURL        *url       = [NSURL URLWithString:urlString];
    NSURLRequest *request   = [NSURLRequest requestWithURL:url];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      // get data from php
                                      NSError *parseError = nil;
                                      NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&parseError];
                                      if (parseError) {
                                          NSLog(@"JSONObjectWithData error: %@", parseError);
                                          return;
                                      }else{
                                          [self dataFromServer:results];
                                      }
                                  }];
    
    [task resume];
}

- (void)dataFromServer:(NSDictionary *)results {
    NSString *s =@"";
    for (id object in results) {
        NSDictionary *currentObject = (NSDictionary*)object;
        NSString *rowID = [currentObject valueForKey:@"id"];
        NSString *rowName  = [currentObject valueForKey:@"name"];
        NSString *rowMessage  = [currentObject valueForKey:@"message"];
        NSString *rowDate  = [currentObject valueForKey:@"reg_date"];
        NSLog(@"id:%@ name:%@ message:%@ date:%@",rowID,rowName,rowMessage,rowDate);
        s = [s stringByAppendingString:[NSString stringWithFormat:@"%@. From:%@\n%@\n(%@)\n\n",rowID,rowName,rowMessage,rowDate]];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        textScroll.text = s;
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
