#A note on functions

During my presentation of this material during the 2017 PowerShell and DevOps Summit a question came up about my use of internal and helper functions and their purpose. Due to time constraints I wasn't able to adequately explain what I was doing and why.

First, the project I was using in my presentation was built in such a way so that I could demonstrate as many concepts as possible within the short session time. What I showed is not necessarily the *right* way to create a class-based tool.

The use of external functions, helper or otherwise, really fill two needs. If your class has methods, the code within that method can be difficult to test with Pester. And if you have a lot of code, it can be hard to maintain. My recommendation was to implement the heavy-lifting in an external function that is invoked from the method. These were the helper functions that were not exported in the module. The class method might look like this:


```
[timespan]GetAge() {
	#invoke the helper function
	$r = GetAgeData -name $this.foo
	return $r
}
```

Your Pester test can validate the GetAgeData function and this keeps your class definition simple. Think of your Class layout as a schema for the type of thing you are creating.

My other use of functions was to provide wrappers so that end users don't need to know how to create or work with your class programmatically. Instead, you'll create commands that, under the hood, create and work with your class. But the sausage-making bits are all hidden. Instead they have commands with help and parameters and support for WhatIf and all the other things that make PowerShell easy to use. We aren't expected to know how to create a `System.ServiceProcess.ServiceController` object or work its properties and methods. Instead we use commands like `Get-Service `and `Stop-Service`. You are going to do the same thing with your class-based module.

And to bring everything together, your class **may not need to have any methods defined**. You may simply create functions that do something with an instance of the object.

The code in this demo project is intended to show you all of these possibilities. In reality, you will most likely take a simpler approach. 

To sum up, the functions you might include in your class-based module will be either private, helper functions for class methods to facilitate Pester testing and public, exported functions to abstract the class so that the user has the same type experience with process or service cmdlets.

If you have other questions on this topic, please post an Issue in the repository.


