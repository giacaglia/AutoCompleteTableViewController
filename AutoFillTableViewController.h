//
//  AutoFillTableViewController.h
//  Invoice
//
//  Created by Giuliano Giacaglia on 4/15/14.
//  Copyright (c) 2014 Giuliano Giacaglia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>


@interface AutoFillTableViewController : UITableViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>


@property UITextField *toTextField;
@property NSMutableArray * allEmails;
@property NSMutableArray *nameArray;
@property NSMutableArray * emailArray;
@property NSMutableArray * staffTableArray;
@property NSMutableArray * staffTableNameArray;
@property NSNumber* yPosition;

- (void)createTableViewWithYPosition:(NSNumber *)yPosition;

@end
