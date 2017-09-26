# Demo-Class-Based-Tools

* These files are intended to be run interactively to demonstrate how you might create a class-based PowerShell tool.
* The demo files are meant to show a progression using simple classes. At the end of the process is a basic module built around a class.
* The demo files are written assuming you are using the PowerShell ISE.
* The module is not intended for production use as currently written and is not necessarily a complete example of best scripting practices.
* The demonstrations require a Windows platform running PowerShell 5.0 or later. They have **not** been tested with PowerShell 6.0.

These example files have *nothing* to do with creating a DSC class-based resource.

To run the demos, download the files to a new folder. Change location to that folder then open DemoOrder.ps1 in the PowerShell ISE, making sure that the ISE is also set to location with these files.

## Suggested Best Practices
* Define classes and enumerations separately from code that uses them.
* Create functions around your class to make it easier to use.
* Package your class and supporting files as a module.
* Consider adding type and format extensions.

_Last updated: 26 September 2017_
