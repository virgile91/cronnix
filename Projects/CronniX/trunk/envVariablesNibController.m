#import "envVariablesNibController.h"
#import "crController.h"
#import "Crontab.h"


@implementation envVariablesNibController


static envVariablesNibController *sharedInstance = nil;


+ (envVariablesNibController *)sharedInstance {
    return sharedInstance ? sharedInstance : [[self alloc] init];
}

+ (void)showWindow {
    [ [ self sharedInstance ] showWindow ];
}

+ (void)hideWindow {
    [ [ self sharedInstance ] hideWindow ];
}



- (id)init {
    if (sharedInstance) {
        [self dealloc];
    } else {
        NSBundle *thisBundle = [ NSBundle bundleForClass: [self class] ];
        NSImage *itemImage = nil;
        NSString *imagePath = nil;
        NSString *itemName;
        NSToolbarItem *item;

        //NSLog( @"init" );
        [super init];
        sharedInstance = self;
        envArray = [[ NSMutableArray alloc ] init ];
        // The following does not work here, maybe because the nib's not displayed, yet.
        // Instead the data source has been set in IB.
        //[ envTable setDataSource: self ];
        
        // toolbar setup ---------------------------------
        items = [ [ NSMutableDictionary alloc ] init ];
        
        // new entry item
        itemName = @"New";
        item = [ [ NSToolbarItem alloc ] initWithItemIdentifier: itemName ];
        [ item setPaletteLabel: NSLocalizedString( @"New", @"toolbar item name" ) ]; // name for the "Customize Toolbar" sheet
        [ item setLabel: NSLocalizedString( @"New", @"toolbar item name" ) ]; // name for the item in the toolbar
        [ item setToolTip: NSLocalizedString( @"Add new environment variable", @"toolbar item tooltip" ) ]; // tooltip
        [ item setTarget: self ]; // what should happen when it's clicked
        [ item setAction: @selector(newLineToolbarItemClicked:) ];
        [ items setObject: item forKey: itemName ]; // add to toolbar list
        imagePath = [ thisBundle pathForResource: @"new_env" ofType: @"tiff" ];
        if ( imagePath )
            itemImage = [ [ NSImage alloc ] initWithContentsOfFile: imagePath ];
        if ( itemImage )
            [ item setImage: itemImage ];
        [ itemImage release ];
        
        // "delete" entry item
        itemName = @"Delete";
        item = [ [ NSToolbarItem alloc ] initWithItemIdentifier: itemName ];
        [ item setPaletteLabel: NSLocalizedString( @"Delete", @"toolbar item name" ) ]; // name for the "Customize Toolbar" sheet
        [ item setLabel: NSLocalizedString( @"Delete", @"toolbar item name" ) ]; // name for the item in the toolbar
        [ item setToolTip: NSLocalizedString( @"Remove environment variable", @"toolbar item tooltip" ) ]; // tooltip
        [ item setTarget: self ]; // what should happen when it's clicked
        [ item setAction: @selector(removeLineToolbarItemClicked:) ];
        [ items setObject: item forKey: itemName ]; // add to toolbar list
        imagePath = [ thisBundle pathForResource: @"delete" ofType: @"tiff" ];
        if ( imagePath )
            itemImage = [ [ NSImage alloc ] initWithContentsOfFile: imagePath ];
        if ( itemImage )
            [ item setImage: itemImage ];
        [ itemImage release ];
        
        // create toolbar
        toolbar = [ [ NSToolbar alloc ] initWithIdentifier: @"EnvToolbar" ];
        [ toolbar setDelegate: self ];
        [ toolbar setAllowsUserCustomization: YES ];
        [ toolbar setAutosavesConfiguration: YES ];
        
    }
    return sharedInstance;
}

- (void)dealloc {
    //NSLog( @"I'm leaving" );
    [ envArray dealloc ];
    [ window close ];
    [ super dealloc ];
}



// accessors

- (NSArray *)envArray{
    return envArray;
}


- (void)setEnvArray: (id)aValue {
    if ( envArray != aValue ) {
        [ envArray release ];
        envArray = [[ NSMutableArray alloc ] initWithArray: aValue ];
		[ self reloadData ];
    }
}


- (NSPanel *)window{
    return window;
}

- (NSToolbar *)toolbar {
    return toolbar;
}



// workers

- (void)showWindow {
    //NSLog( @"show" );
    if ( ! window ) {
        if (![NSBundle loadNibNamed:@"envVariables" owner:self])  {
            NSLog(@"Failed to load envVariables.nib");
            NSBeep();
            return;
        }
    }
	[ window setMenu:nil];
    [ window setFrameUsingName: @"EnvVariablesWindow" ];
    [ window setFrameAutosaveName: @"EnvVariablesWindow" ];
    [ window makeKeyAndOrderFront:nil];
    [ window setToolbar: toolbar ];
}


-(void)hideWindow {
    // "window" is an NSPanel, so closing does not dispose
    //NSLog( @"hide" );
    [ window close ];
}

- (void)addEnv:(NSString *)env withValue:(NSString *)value {
    NSMutableDictionary *dict = [ NSMutableDictionary dictionary ];
    //NSLog( @"add" );
    [ dict setObject: env forKey: @"Env" ];    
    [ dict setObject: value forKey: @"Value" ];
    [ envArray addObject: dict ];
    //[ envTable reloadData ];
}

- (void)removeAllObjects {
    [ envArray removeAllObjects ];
}

- (void)reloadData {
    [ envTable reloadData ];
}

- (int)selectedRow {
    return [ envTable selectedRow ];
}

- (void)removeLine {
    //NSLog( @"remove" );
	int row = [ envTable selectedRow ];
    if ( row == -1 ) {
        NSBeep();
        return;
    }
	id deletedObject = [ NSDictionary dictionaryWithDictionary: [ envArray objectAtIndex: row ]];
    [ envArray removeObjectAtIndex: row ];
    [ envTable reloadData ];
    
    // make sure that the last row remains selected
    if ( [ envTable selectedRow ] == -1 ) {
        [ envTable selectRow: [ envTable numberOfRows ] -1 byExtendingSelection: NO ];
    }

    [[ NSNotificationCenter defaultCenter ] postNotificationName: DocumentModifiedNotification object: self ];
    [[ NSNotificationCenter defaultCenter ] postNotificationName: EnvVariableDeletedNotification object: deletedObject ];
}

- (void)duplicateLine {
    if ( [ envTable selectedRow ] == -1 ) {
        NSBeep();
        return;
    }
    [ envArray insertObject: [ [ envArray objectAtIndex: [ envTable selectedRow ] ] copy ] atIndex: [ envTable selectedRow ] ];
    [ envTable reloadData ];

    // make sure that the last row remains selected
    if ( [ envTable selectedRow ] == -1 ) {
        [ envTable selectRow: [ envTable numberOfRows ] -1 byExtendingSelection: NO ];
    }

    [ [ NSNotificationCenter defaultCenter ] postNotificationName: DocumentModifiedNotification object: self ];
}




- (void)newLine {
    [ self addLine ];
}

- (void)addLine {
    NSMutableDictionary *dict = [ NSMutableDictionary dictionary ];
    //NSLog( @"add" );
    [ dict setObject: NSLocalizedString( @"SOME_ENV", @"env. variable name template" ) forKey: @"Env" ];    
    [ dict setObject: NSLocalizedString( @"value", @"env. variable value template" ) forKey: @"Value" ];
    [ envArray addObject: dict ];
    [ envTable reloadData ];
    [[ NSNotificationCenter defaultCenter ] postNotificationName: DocumentModifiedNotification object: self ];
    [[ NSNotificationCenter defaultCenter ] postNotificationName: EnvVariableAddedNotification object: dict ];
}


- (void)clear {
	[ envArray removeAllObjects ];
	[ self reloadData ];
}

// ib actions

- (IBAction)hideWindow:(id)sender {
    [ self hideWindow ];
}

- (IBAction)addLine:(id)sender {
    [ self addLine ];
}

- (IBAction)removeLine:(id)sender {
    [ self removeLine ];
}

- (IBAction)duplicateLine:(id)sender {
    [ self duplicateLine ];
}


// table view delegates

- (int)numberOfRowsInTableView:(NSTableView *)table {
    //NSLog( @"rows: %i", [ envArray count ] );
    return [ envArray count ];
}


- (id)tableView:(NSTableView *)table
        objectValueForTableColumn:(NSTableColumn *)col
        row:(int)row {
    id rec;
    if ( row >= 0 && row < [ envArray count ] ) {
        rec = [ envArray objectAtIndex: row ];
		//		NSLog( @"%@=%@", [ col identifier ], [ rec objectForKey: [ col identifier ]] );
	return [ rec objectForKey: [ col identifier ] ];
    } else {
        return nil;
    }
}

- (void)tableView: (NSTableView *)table
        setObjectValue: (id)obj
        forTableColumn: (NSTableColumn *)col
        row: (int)row {
    id rec;
    //NSLog( @"insert %@ for %@ in row %i", obj, [ col identifier ], row );
    if ( row >= 0 && row < [ envArray count ] ) {
        rec = [ envArray objectAtIndex: row ];
        [ rec setObject: obj forKey: [ col identifier ] ];
    }
}


- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    BOOL state = ( [ envTable selectedRow ] != -1 );
    [ btRemove setEnabled: state ];
}


- (void)controlTextDidChange:(NSNotification *)aNotification {
    [ [ NSNotificationCenter defaultCenter ] postNotificationName: DocumentModifiedNotification object: self ];

    id ed = [ [ aNotification userInfo ] objectForKey: @"NSFieldEditor" ];
	int edrow = [ envTable editedRow ];
	if ( edrow != -1 ) {
		NSTableColumn *col = [[ envTable tableColumns ] objectAtIndex: [ envTable editedColumn ]];
		id obj = [[ ed string ] copy ];

		id editedEnv = [ envArray objectAtIndex: edrow ];
		id oldEnv = [ NSDictionary dictionaryWithDictionary: editedEnv ];
		
		[ editedEnv setObject: obj forKey: [ col identifier ]];
		[ obj release ];

		id notificationObject = [ NSMutableDictionary dictionary ];
		[ notificationObject setObject: oldEnv forKey: @"OldEnv" ];
		[ notificationObject setObject: editedEnv forKey: @"NewEnv" ];
		[[ NSNotificationCenter defaultCenter ] postNotificationName: EnvVariableEditedNotification object: notificationObject ];
	}
}


// toolbar delegates

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    return [ items objectForKey:itemIdentifier];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar {
    NSMutableArray *arr = [ NSMutableArray array ];
    [ arr addObject: @"New" ];
    [ arr addObject: @"Delete" ];
/*    [ arr addObject: ItemName2 ];
    [ arr addObject: ItemName3 ];
    [ arr addObject: ItemName4 ];
    [ arr addObject: ItemName5 ]; */
    return arr;
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar {
    return [ items allKeys];
}

- (int)count {
    return [ items count];
}

- (BOOL)validateToolbarItem: (NSToolbarItem *)item {
    // delete button
    if ( [ item isEqual: [ items objectForKey: @"Delete" ] ] ) {
        return ( [ self selectedRow ] != -1 );
    }
    return YES;
}


// actions


- (void)customize:(id)sender {
    [toolbar runCustomizationPalette:sender];
}

- (void)showhide:(id)sender {
    [toolbar setVisible:![toolbar isVisible]];
}


- (void)newLineToolbarItemClicked:(NSToolbarItem*)item {
    [ self addLine ];
}

- (void)removeLineToolbarItemClicked:(NSToolbarItem*)item {
    [ self removeLine ];
}


@end
