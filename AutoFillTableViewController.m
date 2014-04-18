//
//  AutoFillTableViewController.m
//  Invoice
//
//  Created by Giuliano Giacaglia on 4/15/14.
//  Copyright (c) 2014 Giuliano Giacaglia. All rights reserved.
//

#import "AutoFillTableViewController.h"


@implementation AutoFillTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self retrieveData];
        self.toTextField.delegate = self;
        self.staffTableArray = [[NSMutableArray alloc] initWithCapacity:1];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.scrollEnabled = YES;
        self.tableView.hidden = YES;
        [self.tableView setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)createTableViewWithYPosition:(NSNumber *)yPosition {
    self.tableView = [[UITableView alloc] initWithFrame:
                      CGRectMake(0, [yPosition intValue], 320, 200) style:UITableViewStylePlain];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.toTextField) {
        self.tableView.hidden = NO;
        NSString *substring = [NSString stringWithString:textField.text];
        substring = [substring stringByReplacingCharactersInRange:range withString:string];
        [self searchAutocompleteEntriesWithSubstring:substring];
    }
    return YES;
}

- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring
{
    substring = [substring lowercaseString];
    NSMutableArray *autoCompleteArray = [[NSMutableArray alloc] init];
    NSMutableArray *autoCompleteNameArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.emailArray count]; i++) {
        NSString *curString = [self.emailArray objectAtIndex:i];
        NSString *lowerCaseCur = [curString lowercaseString];
        NSRange substringRange = [lowerCaseCur rangeOfString:substring];
        if (substringRange.location == 0)
        {
            [autoCompleteArray addObject:curString];
            [autoCompleteNameArray addObject: [self.nameArray objectAtIndex:i]];
        }
    }
    
    if (![substring isEqualToString:@""])
    {
        self.staffTableArray = [NSMutableArray arrayWithArray:autoCompleteArray];
        self.staffTableNameArray = [NSMutableArray arrayWithArray:autoCompleteNameArray];
        
        [self.tableView reloadData];
    }
    
}

- (void) retrieveData {
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    __block BOOL accessGranted = NO;
    
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // We are on iOS 6
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    
    else { // We are on iOS 5 or Older
        accessGranted = YES;
        [self getContactsWithAddressBook:addressBook];
    }
    
    if (accessGranted) {
        [self getContactsWithAddressBook:addressBook];
    }
}

- (void)getContactsWithAddressBook:(ABAddressBookRef )addressBook {
    NSMutableArray *contactList = [[NSMutableArray alloc] init];
    self.emailArray = [[NSMutableArray alloc] init];
    self.nameArray = [[NSMutableArray alloc] init];
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    for (int i=0;i < nPeople;i++) {
        NSMutableDictionary *dOfPerson=[NSMutableDictionary dictionary];
        
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
        
        //For username and surname
        ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
        
        CFStringRef firstName, lastName;
        firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty);
        [dOfPerson setObject:[NSString stringWithFormat:@"%@ %@", firstName, lastName] forKey:@"name"];
        
        //For Email ids
        ABMutableMultiValueRef eMail  = ABRecordCopyValue(ref, kABPersonEmailProperty);
        if(ABMultiValueGetCount(eMail) > 0) {
            [self.emailArray addObject:(__bridge NSString *)ABMultiValueCopyValueAtIndex(eMail, 0)];
            [dOfPerson setObject:(__bridge NSString *)ABMultiValueCopyValueAtIndex(eMail, 0) forKey:@"email"];
            [self.nameArray addObject:[NSString stringWithFormat:@"%@ %@", firstName, lastName]];
        }
        
        //For Phone number
        NSString* mobileLabel;
        
        for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++) {
            mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, i);
            if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
            {
                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"Phone"];
            }
            else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel])
            {
                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"Phone"];
                break ;
            }
            
        }
        [contactList addObject:dOfPerson];
    }
}




#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section {
//    return 3;
    return self.staffTableArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
    cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:AutoCompleteRowIdentifier];
    }
    cell.detailTextLabel.text = [self.staffTableArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [self.staffTableNameArray objectAtIndex:indexPath.row];
    return cell;
}


#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    self.toTextField.text = selectedCell.detailTextLabel.text;
    
    [self.toTextField resignFirstResponder];
    self.tableView.hidden = YES;
}



@end
