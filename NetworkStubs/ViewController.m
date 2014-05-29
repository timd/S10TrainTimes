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
@property (nonatomic, weak) IBOutlet UISegmentedControl *failureControl;

@property (nonatomic) BOOL shouldStubNetwork;
@property (nonatomic) BOOL shouldStubNetworkFailure;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.arrivalSpinner setColor:[UIColor blackColor]];
    [self.departureSpinner setColor:[UIColor blackColor]];
    
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
    
    [self.failureControl setEnabled:NO];

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
        [self.arrivalSpinner setColor:[UIColor blackColor]];
        [self.departureSpinner setColor:[UIColor blackColor]];
        
        [self.departureTime setText:cleanDepTime];
        [self.arrivalTime setText:cleanArrTime];

        [self.spinnerTimer invalidate];
        
        [self.failureControl setEnabled:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network problems"
                                                        message:@"There was a problem retrieving the data from the network."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
        
        [self.departureSpinner setAlpha:0.0f];
        [self.arrivalSpinner setAlpha:0.0f];
        [self.departureSpinner stopAnimating];
        [self.arrivalSpinner stopAnimating];
        [self.arrivalSpinner setColor:[UIColor blackColor]];
        [self.departureSpinner setColor:[UIColor blackColor]];
        
        [self.departureTime setText:@""];
        [self.arrivalTime setText:@""];
        
        [self.failureControl setEnabled:YES];
        
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

-(void)configureNetworkSimulation {

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        
        //return [request.URL.path isEqualToString:@"/v1/connections"];
        return (self.shouldStubNetwork == YES);
        
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        
        if (self.shouldStubNetworkFailure) {
            
            return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain
                                                                              code:kCFURLErrorNotConnectedToInternet
                                                                          userInfo:nil]];
        }
        
        return [[OHHTTPStubsResponse responseWithFileAtPath:
                 OHPathForFileInBundle(@"response.json",nil)
                                                 statusCode:200 headers:@{@"Content-Type":@"text/json"}] requestTime:6.0
                responseTime:1.0];
    }];

}

-(IBAction)didChangeFailControlValue:(id)sender {
    
    UISegmentedControl *failureControl = (UISegmentedControl *)sender;
    
    switch (failureControl.selectedSegmentIndex) {
        case 0:
            // Normal network
            self.shouldStubNetwork = NO;
            self.shouldStubNetworkFailure = NO;
            [self.arrivalSpinner setColor:[UIColor blackColor]];
            [self.departureSpinner setColor:[UIColor blackColor]];
            break;

        case 1:
            // Slow network
            self.shouldStubNetwork = YES;
            self.shouldStubNetworkFailure = NO;
            break;

        case 2:
            // Failing network
            self.shouldStubNetwork = YES;
            self.shouldStubNetworkFailure = YES;
            break;

        default:
            break;
    }
    
    [self configureNetworkSimulation];
    
}

@end
