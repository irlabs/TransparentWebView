Transparent Web Browser
=======================

![TransparentWebView Screenshot](https://trac.mediamatic.nl/devcamps/raw-attachment/wiki/TransparentWebView/TransparentWebView_Screenshot.jpg)

The TransparentWebView is a transparent web browser for Mac OS X. That means that if the visited web page is without a background color, or the background color is set to transparent, the complete browser window will be see-through.

Custom Overlay UI Everywhere
----------------------------

![TransparentWebView Usage Screenshot](https://trac.mediamatic.nl/devcamps/raw-attachment/wiki/TransparentWebView/TransparentWebView_Screenshot_Usage.jpg)

The window of the TransparentWebView does not have a border or a shadow and will always stay on top of other windows. It just has a title bar, so you can move the window around, and it has a resize handle (the little widget with the slanted 'grip' lines, located totally at the bottom right of almost every Mac OS X window), so you can resize the window.

A transparent browser window could be useful for special tricks. You can place a transparent screen-filling window on top of any other application window, to send special messages to the screen through a web server, or add Web UI elements (build with javascript) to any other application or quick prototyped installation.

Borderless
----------

![TransparentWebView cropped under titlebar](https://trac.mediamatic.nl/devcamps/raw-attachment/wiki/TransparentWebView/TransparentWebView_Screenshot_cropped_under_titlebar.jpg)
![TransparentWebView cropped borderless](https://trac.mediamatic.nl/devcamps/raw-attachment/wiki/TransparentWebView/TransparentWebView_Screenshot_cropped_borderless.jpg)


The window can also be setup borderless, so not even the title bar and the resize widget are visible. Because you cannot move a window without its title bar, there is a useful function to toggle between a window with title bar and resize widget and a total borderless window. And because you might also want the window so big that also the space of the title bar is used – for instance if you want a full screen window starting at the top of the screen–, there is a function have to top of the content cropped of by the title bar ... if you then hide the title bar, all of the content area is visible.

Controls
--------

![TransparentWebView Sheet](https://trac.mediamatic.nl/devcamps/raw-attachment/wiki/TransparentWebView/TransparentWebView_Screenshot_Sheet.jpg)

The TransparentWebView app has a very limited set of UI elements, just enough to point it to the location you need, to reload the browser and to position the window the way you like:

 - Command (⌘) R: Reloads the page
 - Command (⌘) L: Shows a sheet to enter any url location
 - Command Esc (⌘⎋): Show the window borderless, i.e. also without a title bar.
 - Command Option Forward Slash (⌘⌥/): Crops the top of the content under the titlebar.
 - Command (⌘) ,: Shows the Preference window to set a reload interval
 - Window size, window position and URL location are automatically saved into a preferences file, so they will be the same the next time you open the app.
 
Automatic Reload
----------------

![TransparentWebView Preferences](https://trac.mediamatic.nl/devcamps/raw-attachment/wiki/TransparentWebView/TransparentWebView_Screenshot_Preferences.jpg)

Through the preferences window you can specify an automatic reload interval. Set this if you want the Transparent Web View to automatic reload its content every so many minutes. Press ⌘ , to see this Preferences Window

