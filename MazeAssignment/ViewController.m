//
//  ViewController.m
//  MazeAssignment
//
//  Created by Johnny Kang on 2018-03-07.
//  Copyright © 2018 Johnny Kang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIView *MapConsole;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _MapConsole.hidden=true;
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Movement:(id)sender {
    
}

- (IBAction)Flashlight:(id)sender {
    NSLog(@"Flashlight On");
}

- (IBAction)MapConsoleTrigger:(id)sender { //two double tap
    
    _MapConsole.hidden=!_MapConsole.hidden;
    NSLog(@"double tap recognized!");
}

- (IBAction)ResetTrigger:(id)sender { //double tap
    NSLog(@"Reset Location");
}

@end
