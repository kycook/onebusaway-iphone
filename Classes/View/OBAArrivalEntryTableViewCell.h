/**
 * Copyright (C) 2009 bdferris <bdferris@onebusaway.org>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *         http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//#import <UIKit/UIKit.h>


@interface OBAArrivalEntryTableViewCell : UITableViewCell {
	UILabel * routeLabel;
	UILabel * destinationLabel;
	UILabel * timeLabel;
	UILabel * minutesLabel;
}

@property (nonatomic, retain) IBOutlet UILabel * routeLabel;
@property (nonatomic, retain) IBOutlet UILabel * destinationLabel;
@property (nonatomic, retain) IBOutlet UILabel * timeLabel;
@property (nonatomic, retain) IBOutlet UILabel * minutesLabel;

+ (OBAArrivalEntryTableViewCell*) getOrCreateCellForTableView:(UITableView*)tableView;

@end