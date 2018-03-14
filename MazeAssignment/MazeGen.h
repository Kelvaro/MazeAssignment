//
//  MazeGen.h
//  MazeAssignment
//
//  Created by BCIT Student on 2018-03-11.
//  Copyright © 2018 Johnny Kang. All rights reserved.
//

#ifndef MazeGen_h
#define MazeGen_h

struct MazeClass;

typedef struct{
    
    bool N,S,W,E;
    
} Cell;

@interface MazeGen : NSObject
{
    struct MazeClass * mazeObj;
    
    
    
}


- (void) GenMaze:(int)rows cols:(int)cols;
-(Cell) GetCell:(int)row col:(int)col;

@end

#endif /* MazeGen_h */
