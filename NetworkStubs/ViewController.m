//
//  ViewController.m
//  NetworkStubs
//
//  Created by Tim on 11/05/14.
//  Copyright (c) 2014 Charismatic Megafauna Ltd. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "OHHTTPStubs.h"

@interface ViewController ()
@property (nonatomic, weak) IBOutlet UIButton *downloadButton;
@property (nonatomic, weak) IBOutlet UILabel *arrivalTime;
@property (nonatomic, weak) IBOutlet UILabel *departureTime;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *departureSpinner;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *arrivalSpinner;
@property (nonatomic, weak) NSTimer *spinnerTimer;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.path isEqualToString:@"/v1/connections"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [[OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(@"response.json",nil)
                                                 statusCode:200 headers:@{@"Content-Type":@"text/json"}]
                requestTime:4.0 responseTime:1.0];
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)didTapDownloadButton:(id)sender {
    
    NSURL *url = [NSURL URLWithString:@"http://transport.opendata.ch/v1/connections?from=008503055&to=008503051&limit=1"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        
        NSArray *connections = [responseDictionary objectForKey:@"connections"];
        
        NSDictionary *resultsDictionary = [connections objectAtIndex:0];
        
        NSDictionary *fromData = [resultsDictionary objectForKey:@"from"];
        NSDictionary *toData = [resultsDictionary objectForKey:@"to"];

        NSDateFormatter *longFormatter = [[NSDateFormatter alloc] init];
        [longFormatter setDateFormat:@"YYYY-MM-dd'T'HH:mm:ssZZZZZ"];            // 2014-05-11T18:53:00+0200

        NSDateFormatter *shortFormatter = [[NSDateFormatter alloc] init];
        [shortFormatter setDateFormat:@"HH:mm"];
        
        NSString *departureTime = [fromData objectForKey:@"departure"];
        NSString *arrivalTime = [toData objectForKey:@"arrival"];

        NSDate *depTime = [longFormatter dateFromString:departureTime];
        NSDate *arrTime = [longFormatter dateFromString:arrivalTime];
        
        NSString *cleanArrTime = [shortFormatter stringFromDate:arrTime];
        NSString *cleanDepTime = [shortFormatter stringFromDate:depTime];
      
        [self.departureSpinner setAlpha:0.0f];
        [self.arrivalSpinner setAlpha:0.0f];
        [self.departureSpinner stopAnimating];
        [self.arrivalSpinner stopAnimating];
        
        [self.departureTime setText:cleanDepTime];
        [self.arrivalTime setText:cleanArrTime];

        [self.spinnerTimer invalidate];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Failed :(");
        
    }];
    
    [operation start];
    
    [self.departureTime setText:@""];
    [self.arrivalTime setText:@""];
    
    [self.departureSpinner setAlpha:1.0f];
    [self.arrivalSpinner setAlpha:1.0f];
    [self.departureSpinner startAnimating];
    [self.arrivalSpinner startAnimating];
    
    self.spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(changeSpinnerColour) userInfo:nil repeats:NO];
    
}

-(void)changeSpinnerColour {
    
    [self.arrivalSpinner setColor:[UIColor redColor]];
    [self.departureSpinner setColor:[UIColor redColor]];
    
}

@end
