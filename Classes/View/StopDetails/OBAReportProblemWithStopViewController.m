#import "OBAReportProblemWithStopViewController.h"
#import "OBAListSelectionViewController.h"
#import "OBATextEditViewController.h"
#import "OBALogger.h"
#import "SBJson.h"


typedef enum {
	OBASectionTypeNone,	
	OBASectionTypeProblem,
	OBASectionTypeComment,
	OBASectionTypeSubmit,
	OBASectionTypeNotes
} OBASectionType;


@interface OBAReportProblemWithStopViewController (Private)

- (void) addProblemWithId:(NSString*)problemId name:(NSString*)problemName;

- (OBASectionType) sectionTypeForSection:(NSUInteger)section;
- (NSUInteger) sectionIndexForType:(OBASectionType)type;

- (void) submit;
- (NSString*) getProblemAsData;

@end


@implementation OBAReportProblemWithStopViewController

#pragma mark -
#pragma mark Initialization

- (id) initWithApplicationContext:(OBAApplicationContext*)context stop:(OBAStopV2*)stop {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		_appContext = [context retain];
		_stop = [stop retain];
		
		self.navigationItem.title = NSLocalizedString(@"Report a Problem",@"self.navigationItem.title");

		UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Custom Title",@"UIBarButtonItem * item")
										 style:UIBarButtonItemStyleBordered
										target:nil
										action:nil];
		self.navigationItem.backBarButtonItem = item;
		[item release];
		
		_problemIds = [[NSMutableArray alloc] init];
		_problemNames = [[NSMutableArray alloc] init];
		
		[self addProblemWithId:@"stop_name_wrong" name:NSLocalizedString(@"Stop name is wrong",@"name")];
		[self addProblemWithId:@"stop_number_wrong" name:NSLocalizedString(@"Stop number is wrong",@"name")];
		[self addProblemWithId:@"stop_location_wrong" name:NSLocalizedString(@"Stop location is wrong",@"name")];
		[self addProblemWithId:@"route_or_trip_missing" name:NSLocalizedString(@"Route or scheduled trip is missing",@"name")];
		[self addProblemWithId:@"other" name:NSLocalizedString(@"Other",@"name")];
		
		_activityIndicatorView = [[OBAModalActivityIndicator alloc] init];
    }
    return self;
}

- (void)dealloc {
	[_appContext release];
	[_problemIds release];
	[_problemNames release];
	[_stop release];	
	[_comment release];
	[_activityIndicatorView release];
    [super dealloc];
}


#pragma mark UIViewController

-(void)viewDidLoad {
	self.navigationItem.backBarButtonItem.title = NSLocalizedString(@"Problem",@"self.navigationItem.backBarButtonItem.title");
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

	OBASectionType sectionType = [self sectionTypeForSection:section];
	
	switch (sectionType) {
		case OBASectionTypeProblem:
			return NSLocalizedString(@"What's the problem?",@"OBASectionTypeProblem");
		case OBASectionTypeComment:
			return NSLocalizedString(@"Optional - Comment:",@"OBASectionTypeComment");
		case OBASectionTypeNotes:
			return NSLocalizedString(@"Your reports help OneBusAway find and fix problems with the system.",@"OBASectionTypeNotes");
		default:
			return nil;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	OBASectionType sectionType = [self sectionTypeForSection:section];
	
	switch( sectionType ) {
		case OBASectionTypeProblem:
			return 1;
		case OBASectionTypeComment:
			return 1;
		case OBASectionTypeSubmit:
			return 1;
		case OBASectionTypeNotes:
			return 0;
		case OBASectionTypeNone:
		default:
			return 0;
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	OBASectionType sectionType = [self sectionTypeForSection:indexPath.section];
	
	switch (sectionType) {
		case OBASectionTypeProblem: {
			UITableViewCell * cell = [UITableViewCell getOrCreateCellForTableView:tableView];			
			cell.textLabel.textAlignment = UITextAlignmentLeft;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.textLabel.text = [_problemNames objectAtIndex:_problemIndex];
			return cell;			
		}
		case OBASectionTypeComment: {
			UITableViewCell * cell = [UITableViewCell getOrCreateCellForTableView:tableView];			
			cell.textLabel.textAlignment = UITextAlignmentLeft;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			
			if (_comment && [_comment length] > 0) {
				cell.textLabel.textColor = [UIColor blackColor];
				cell.textLabel.text = _comment;
			}
			else {
				cell.textLabel.textColor = [UIColor grayColor];
				cell.textLabel.text = NSLocalizedString(@"Touch to edit",@"cell.textLabel.text");
			}
			
			return cell;
		}
		
		case OBASectionTypeSubmit: {
			UITableViewCell * cell = [UITableViewCell getOrCreateCellForTableView:tableView];			
			cell.textLabel.textAlignment = UITextAlignmentCenter;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.textLabel.text = NSLocalizedString(@"Submit",@"cell.textLabel.text");
			return cell;
		}
		default:	
			break;
	}
	
	return [UITableViewCell getOrCreateCellForTableView:tableView];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	OBASectionType sectionType = [self sectionTypeForSection:indexPath.section];
	switch (sectionType) {
		case OBASectionTypeProblem: {
			NSIndexPath * selectedIndex = [NSIndexPath indexPathForRow:_problemIndex inSection:0];			
			OBAListSelectionViewController * vc = [[OBAListSelectionViewController alloc] initWithValues:_problemNames selectedIndex:selectedIndex];
			vc.target = self;
			vc.action = @selector(setProblem:);
			[self.navigationController pushViewController:vc animated:TRUE];
			[vc release];
			break;
		}
			
		case OBASectionTypeComment: {
			OBATextEditViewController * vc = [OBATextEditViewController pushOntoViewController:self withText:_comment withTitle:NSLocalizedString(@"Comment",@"OBATextEditViewController withTitle")];
			vc.target = self;
			vc.action = @selector(setComment:);
			break;
		}
			
		case OBASectionTypeSubmit: {
			[self submit];
		}
			
		default:
			break;
	}
}


#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
	return YES;
}

#pragma mark OBAModelServiceDelegate

- (void)requestDidFinish:(id<OBAModelServiceRequest>)request withObject:(id)obj context:(id)context {
	[_activityIndicatorView hide];
	[self.navigationController popViewControllerAnimated:TRUE];
}

- (void)requestDidFinish:(id<OBAModelServiceRequest>)request withCode:(NSInteger)code context:(id)context {
	[_activityIndicatorView hide];
}

- (void)requestDidFail:(id<OBAModelServiceRequest>)request withError:(NSError *)error context:(id)context {
	[_activityIndicatorView hide];
}

#pragma mark Other methods

- (void) setProblem:(NSIndexPath*)indexPath {
	_problemIndex = indexPath.row;
	NSUInteger section = [self sectionIndexForType:OBASectionTypeProblem];
	NSIndexPath * p = [NSIndexPath indexPathForRow:0 inSection:section];
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:p] withRowAnimation:UITableViewRowAnimationFade];
}

- (void) setComment:(NSString*)comment {
	_comment = [NSObject releaseOld:_comment retainNew:comment];
	NSUInteger section = [self sectionIndexForType:OBASectionTypeComment];
	NSIndexPath * p = [NSIndexPath indexPathForRow:0 inSection:section];
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:p] withRowAnimation:UITableViewRowAnimationFade];
}

@end


@implementation OBAReportProblemWithStopViewController (Private)

- (void) addProblemWithId:(NSString*)problemId name:(NSString*)problemName {
	[_problemIds addObject:problemId];
	[_problemNames addObject:problemName];
}

- (OBASectionType) sectionTypeForSection:(NSUInteger)section {
	switch (section) {
		case 0:
			return OBASectionTypeProblem;
		case 1:
			return OBASectionTypeComment;
		case 2:
			return OBASectionTypeSubmit;
		case 3:
			return OBASectionTypeNotes;
		default:
			return OBASectionTypeNone;
	}
}

- (NSUInteger) sectionIndexForType:(OBASectionType)type {
	switch (type) {
		case OBASectionTypeProblem:
			return 0;
		case OBASectionTypeComment:
			return 1;
		case OBASectionTypeSubmit:
			return 2;
		case OBASectionTypeNotes:
			return 3;
		case OBASectionTypeNone:
		default:
			break;
	}
	return -1;
}

- (void) submit {

	OBAReportProblemWithStopV2 * problem = [[OBAReportProblemWithStopV2 alloc] init];
	problem.stopId = _stop.stopId;
	problem.data = [self getProblemAsData];
	problem.userComment = _comment;
	problem.userLocation = _appContext.locationManager.currentLocation;
	
	[_activityIndicatorView show:self.view];
	[_appContext.modelService reportProblemWithStop:problem withDelegate:self withContext:nil];
	
	[problem release];
}

- (NSString*) getProblemAsData {

	NSMutableDictionary * p = [[NSMutableDictionary alloc] init];
	[p setObject:[_problemIds objectAtIndex:_problemIndex] forKey:@"code"];
	[p setObject:[_problemNames objectAtIndex:_problemIndex] forKey:@"text"];
	
    SBJsonWriter * writer = [[SBJsonWriter alloc] init];
	NSString * v = [writer stringWithObject:p];
	[writer release];
	[p release];
	return v;	
}

@end