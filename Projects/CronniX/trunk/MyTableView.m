#import "MyTableView.h"

@implementation MyTableView

- (void)rightMouseDown: (NSEvent *)event {
    NSPoint p = [ self convertPoint: [ event locationInWindow ] fromView: nil ];
    int row = [ self rowAtPoint: p ];
    [ self selectRow: row byExtendingSelection: NO ];

    [ super rightMouseDown: event ];
}


@end
