//
//  ViewController.m
//  MazeAssignment
//
//  Created by Johnny Kang on 2018-03-07.
//  Copyright © 2018 Johnny Kang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    Renderer *glesRenderer;
    
}
@property (strong, nonatomic) IBOutlet UIView *MapConsole;

@end

bool light;
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _MapConsole.hidden=true;
    glesRenderer = [[Renderer alloc] init];
    GLKView *view = (GLKView *)self.view;
    [glesRenderer setup:view];
    [glesRenderer loadModels];
    light = false;
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)update
{
    [glesRenderer update]; // ###
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [glesRenderer draw:rect]; // ###
}

- (IBAction)Movement:(id)sender {
    
}

- (IBAction)Flashlight:(id)sender {
    if(light){
        NSLog(@"Flashlight Off");
        light=false;

    }
    else{
        NSLog(@"Flashlight On");
        light=true;
    }
}

- (IBAction)MapConsoleTrigger:(id)sender { //two double tap
    
    _MapConsole.hidden=!_MapConsole.hidden;
    NSLog(@"double tap recognized!");
}

- (IBAction)ResetTrigger:(id)sender { //double tap
    NSLog(@"Reset Location");
}

@end
