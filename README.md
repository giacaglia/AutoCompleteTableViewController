AutoCompleteTableViewController
===============================

AutoCompleteTableViewController a subclass of UITableViewController that automatically displays text suggestions in real-time. This is perfect for automatically suggesting the email of the users in the users' contact list.

## Quickstart Guide

* Manually add `AutoFillTableViewController.m` and `AutoFillTableViewController.h` to your project 
* Mannually import the class to your ViewController that contains the textfield that you want to have the AutoCompleteTableView
* Declare the following property at your header:

    @property AutoFillTableViewController *autoFillTableViewController;

* Add the following code to your class:

     self.autoFillTableViewController = [[AutoFillTableViewController alloc] initWithStyle:UITableViewStylePlain];
    [self addChildViewController:self.autoFillTableViewController];
    self.autoFillTableViewController.toTextField = self.toTextField;
    [self.autoFillTableViewController createTableViewWithYPosition:@185];
    self.toTextField.delegate = self.autoFillTableViewController;
    [self.view addSubview:self.autoFillTableViewController.tableView];
    [self.view bringSubviewToFront:self.autoFillTableViewController.tableView];
    self.autoFillTableViewController.tableView.hidden = YES;

