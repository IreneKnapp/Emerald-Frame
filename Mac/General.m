#include <stdio.h>

#include "Emerald-Frame.h"
#import "ApplicationDelegate.h"


static void populate_application_menu(NSMenu *menu);
static void populate_edit_menu(NSMenu *menu);
static void populate_window_menu(NSMenu *menu);


void ef_internal_populate_main_menu() {
    NSMenu *mainMenu = [[NSMenu alloc] initWithTitle: @"MainMenu"];

    NSMenuItem *menuItem;
    NSMenu *submenu;

    menuItem = [mainMenu addItemWithTitle: @"Apple" action: NULL keyEquivalent: @""];
    submenu = [[NSMenu alloc] initWithTitle: @"Apple"];
    [NSApp performSelector: @selector(setAppleMenu:) withObject: submenu];
    populate_application_menu(submenu);
    [mainMenu setSubmenu: submenu forItem: menuItem];

    /*
    menuItem = [mainMenu addItemWithTitle: @"File" action: NULL keyEquivalent: @""];
    submenu = [[NSMenu alloc]
		  initWithTitle: NSLocalizedString(@"File", @"The File menu")];
    populate_file_menu(submenu);
    [mainMenu setSubmenu: submenu forItem: menuItem];
    */

    menuItem = [mainMenu addItemWithTitle: @"Edit" action: NULL keyEquivalent: @""];
    submenu = [[NSMenu alloc]
		  initWithTitle: NSLocalizedString(@"Edit", @"The Edit menu")];
    populate_edit_menu(submenu);
    [mainMenu setSubmenu: submenu forItem: menuItem];

    menuItem = [mainMenu addItemWithTitle: @"Window" action: NULL keyEquivalent: @""];
    submenu = [[NSMenu alloc]
		  initWithTitle: NSLocalizedString(@"Window", @"The Window menu")];
    populate_window_menu(submenu);
    [mainMenu setSubmenu: submenu forItem: menuItem];
    [NSApp setWindowsMenu: submenu];

    [NSApp setMainMenu: mainMenu];
}


static void populate_application_menu(NSMenu *menu) {
    NSString *applicationName
	= [NSString stringWithUTF8String: (char *) ef_internal_application_name()];

    NSMenuItem *menuItem;

    menuItem = [menu addItemWithTitle: [NSString stringWithFormat: @"%@ %@",
						 NSLocalizedString(@"About", nil),
						 applicationName]
		     action: @selector(orderFrontStandardAboutPanel:)
		     keyEquivalent: @""];
    [menuItem setTarget: NSApp];

    [menu addItem: [NSMenuItem separatorItem]];

    menuItem = [menu addItemWithTitle: [NSString stringWithFormat: @"%@ %@",
						 NSLocalizedString(@"Hide", nil),
						 applicationName]
		     action: @selector(hide:)
		     keyEquivalent: @"h"];
    [menuItem setTarget: NSApp];

    menuItem = [menu addItemWithTitle: NSLocalizedString(@"Hide Others", nil)
		     action: @selector(hideOtherApplications:)
		     keyEquivalent: @"h"];
    [menuItem setKeyEquivalentModifierMask: NSCommandKeyMask | NSAlternateKeyMask];
    [menuItem setTarget: NSApp];

    menuItem = [menu addItemWithTitle: NSLocalizedString(@"Show All", nil)
		     action: @selector(unhideAllApplications:)
		     keyEquivalent: @""];
    [menuItem setTarget: NSApp];

    [menu addItem: [NSMenuItem separatorItem]];

    menuItem = [menu addItemWithTitle: [NSString stringWithFormat: @"%@ %@",
						 NSLocalizedString(@"Quit", nil),
						 applicationName]
		     action: @selector(terminate:)
		     keyEquivalent: @"q"];
    [menuItem setTarget: NSApp];
}


static void populate_edit_menu(NSMenu *menu) {
    NSMenuItem *menuItem;

    menuItem = [menu addItemWithTitle: NSLocalizedString(@"Cut", nil)
		     action: @selector(cut:)
		     keyEquivalent: @"x"];

    menuItem = [menu addItemWithTitle: NSLocalizedString(@"Copy", nil)
		     action: @selector(copy:)
		     keyEquivalent: @"c"];

    menuItem = [menu addItemWithTitle: NSLocalizedString(@"Paste", nil)
		     action: @selector(paste:)
		     keyEquivalent: @"v"];
}


static void populate_window_menu(NSMenu *menu) {
    NSMenuItem *menuItem;
    
    menuItem = [menu addItemWithTitle: NSLocalizedString(@"Minimize", nil)
		     action: @selector(performMinimize:)
		     keyEquivalent: @"m"];
    
    menuItem = [menu addItemWithTitle: NSLocalizedString(@"Zoom", nil)
		     action: @selector(performZoom:)
		     keyEquivalent: @""];
    
    [menu addItem: [NSMenuItem separatorItem]];
    
    menuItem = [menu addItemWithTitle: NSLocalizedString(@"Bring All to Front", nil)
		     action: @selector(arrangeInFront:)
		     keyEquivalent: @""];
}


void ef_main() {
    NSApplication *application = [NSApplication sharedApplication];
    [application run];
}
