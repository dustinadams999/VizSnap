//
//  ValueSelectionViewController.m
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/07/31.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "ValueSelectionViewController.h"

@interface ValueSelectionViewController ()

@end

@implementation ValueSelectionViewController {
    int selectedValueIndex;
}

@synthesize delegate = _delegate;
@synthesize values = _values;
@synthesize selectedValue = _selectedValue;
@synthesize valueSuffix = _valueSuffix;
@synthesize message = _message;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    selectedValueIndex = [self.values indexOfObject:self.selectedValue];
    self.valueSuffix = @"";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return MAX(self.values.count, 1);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0 && self.message != nil)
    {
        return self.message;
    }
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *NoValueCellIdentifier = @"NoValueCell";
    static NSString *ValueCellIdentifier = @"ValueCell";
    UITableViewCell *cell;
    
    if (self.values == nil || self.values.count == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:NoValueCellIdentifier];
        UILabel *label;
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NoValueCellIdentifier];
            
            label = [[UILabel alloc] initWithFrame:CGRectInset(cell.contentView.bounds, 10.0, 10.0)];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont boldSystemFontOfSize:20.0];
            label.textColor = [UIColor grayColor];
            label.textAlignment = UITextAlignmentCenter;
            
            [cell.contentView addSubview:label];
        } else {
            label = (UILabel *)[cell.contentView viewWithTag:101];
        }
        
        label.text = NSLocalizedString(@"No values", @"Value selection view");
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:ValueCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ValueCellIdentifier];
        }
        
        if (indexPath.row == selectedValueIndex) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@%@", [self.values objectAtIndex:indexPath.row], self.valueSuffix];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Uncheck previously selected row.
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedValueIndex inSection:0]];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    selectedValueIndex = indexPath.row;
    self.selectedValue = [self.values objectAtIndex:selectedValueIndex];
    
    [self.delegate valueSelectionViewController:self valueSelected:self.selectedValue atIndex:selectedValueIndex];
}

@end
