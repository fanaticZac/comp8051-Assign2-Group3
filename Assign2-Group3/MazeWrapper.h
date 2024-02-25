//
//  MazeWrapper.h
//  Assign2-Group3
//
//  Created by user on 2/25/24.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CompassDirection) {
    dNORTH = 0,
    dEAST,
    dSOUTH,
    dWEST
};

@interface MazeWrapper : NSObject

@property (nonatomic, readonly) int rows;
@property (nonatomic, readonly) int columns;

- (instancetype)initWithRows:(int)rows columns:(int)columns;
- (void)createMaze;
- (BOOL)isWallPresentAtRow:(int)row column:(int)column direction:(int)direction;

@end
