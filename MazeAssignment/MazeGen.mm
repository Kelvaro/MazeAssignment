//
//  MazeGen.m
//  MazeAssignment
//
//  Created by BCIT Student on 2018-03-11.
//  Copyright © 2018 Johnny Kang. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "maze.h"
#import "MazeGen.h"

struct MazeClass{
    
    Maze Obj;
    
};

@implementation MazeGen

- (id) init
{
    self = [super init];
    mazeObj = new MazeClass;
    return self;
    
};

- (void) GenMaze:(int)rows cols:(int)cols{
    
    
    mazeObj->Obj = *new Maze(rows,cols);
    mazeObj->Obj.Create();
    
    /*
     
     
     for (int i=0; i< rows; i++) {
     maze[i] = (MazeCell *)calloc(cols, sizeof(MazeCell));
     for(int j=0; j<cols; j++) {
     if(maze[i][j].northWallPresent)
     RenderWall(north)
     if(maze[i][j].southWallPresent)
     RenderWall(south)
     if(maze[i][j].eastWallPresent)
     RenderWall(east)
     if(maze[i][j].westWallPresent)
     RenderWall(west)
     }
     }
     */
    
}





@end
