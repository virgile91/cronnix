#import <Cocoa/Cocoa.h>


/*!
	@class envVariablesNibController
	@abstract 
	@discussion 
*/
@interface envVariablesNibController : NSObject {
/*! @var window description */
    IBOutlet NSPanel  *window;
/*! @var btRemove description */
    IBOutlet id btRemove;
/*! @var envTable description */
    IBOutlet id envTable;
/*! @var envArray description */
    NSMutableArray    *envArray;
/*! @var toolbar description */
    NSToolbar *toolbar;
/*! @var items description */
    NSMutableDictionary *items;
}

// class methods
/*!
	@method sharedInstance
	@abstract 
	@discussion 
	@result 
*/
+ (envVariablesNibController *)sharedInstance;
/*!
	@method showWindow
	@abstract 
	@discussion 
	@result 
*/
+ (void)showWindow;
/*!
	@method hideWindow
	@abstract 
	@discussion 
	@result 
*/
+ (void)hideWindow;

// accessors
/*!
	@method envArray
	@abstract 
	@discussion 
	@result 
*/
- (NSArray *)envArray;

- (void)setEnvArray: (NSArray *)aVal;


/*!
	@method window
	@abstract 
	@discussion 
	@result 
*/
- (NSPanel *)window;
/*!
	@method toolbar
	@abstract 
	@discussion 
	@result 
*/
- (NSToolbar *)toolbar;

// workers
/*!
	@method showWindow
	@abstract 
	@discussion 
	@result 
*/
- (void)showWindow;
/*!
	@method hideWindow
	@abstract 
	@discussion 
	@result 
*/
- (void)hideWindow;
/*!
	@method addEnv
	@abstract 
	@discussion 
	@result 
*/
- (void)addEnv:(NSString *)env withValue:(NSString *)value;
/*!
	@method removeAllObjects
	@abstract 
	@discussion 
	@result 
*/
- (void)removeAllObjects;
/*!
	@method reloadData
	@abstract 
	@discussion 
	@result 
*/
- (void)reloadData;

- (int)selectedRow;

- (void)addLine;

- (void)newLine; // identical to addLine

- (void)removeLine;

- (void)duplicateLine;

- (void)clear;

// ib actions
/*!
	@method hideWindow
	@abstract 
	@discussion 
	@result 
*/
- (IBAction)hideWindow:(id)sender;
/*!
	@method addLine
	@abstract 
	@discussion 
	@result 
*/
- (IBAction)addLine:(id)sender;
/*!
	@method removeLine
	@abstract 
	@discussion 
	@result 
*/
- (IBAction)removeLine:(id)sender;
/*!
	@method duplicateLine
	@abstract 
	@discussion 
	@result 
*/
- (IBAction)duplicateLine:(id)sender;

// delegate methods
/*!
	@method controlTextDidChange
	@abstract 
	@discussion 
	@result 
*/
//- (void)controlTextDidChange:(NSNotification *)aNotification;

// toolbar delegates
/*!
	@method toolbar
	@abstract 
	@discussion 
	@result 
*/
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag;
/*!
	@method toolbarDefaultItemIdentifiers
	@abstract 
	@discussion 
	@result 
*/
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar;
/*!
	@method toolbarAllowedItemIdentifiers
	@abstract 
	@discussion 
	@result 
*/
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar;
/*!
	@method count
	@abstract 
	@discussion 
	@result 
*/
- (int)count;

// toolbar menu actions
/*!
	@method customize
	@abstract 
	@discussion 
	@result 
*/
- (void)customize:(id)sender;
/*!
	@method showhide
	@abstract 
	@discussion 
	@result 
*/
- (void)showhide:(id)sender;

@end
