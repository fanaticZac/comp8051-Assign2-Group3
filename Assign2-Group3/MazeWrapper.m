//
//  MazeWrapper.m
//  Assign2-Group3
//
//  Created by user on 2/25/24.
//

#include "MazeWrapper.h"
#include "Maze.h"

@interface MazeWrapper ()

@property (nonatomic, assign) Maze *maze;
@property (nonatomic, assign) int rows;
@property (nonatomic, assign) int columns;

@end

@implementation MazeWrapper

- (instancetype)initWithRows:(int)rows columns:(int)columns {
    self = [super init];
    if (self) {
        _maze = new Maze(rows, columns);
        _rows = rows;
        _columns = columns;
    }
    return self;
}

- (void)dealloc {
    delete _maze;
}

- (void)createMaze {
    _maze->Create();
}

- (BOOL)isWallPresentAtRow:(int)row column:(int)column direction:(int)direction {
    MazeCell cell = _maze->GetCell(row, column);
    switch (direction) {
        case dirNORTH:
            return cell.northWallPresent;
        case dirEAST:
            return cell.eastWallPresent;
        case dirSOUTH:
            return cell.southWallPresent;
        case dirWEST:
            return cell.westWallPresent;
        default:
            return YES; // Invalid direction
    }
}

@end
