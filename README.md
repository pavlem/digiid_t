# digiid_test Instructions

First checkout the project and start the **DigiIdentity_test.xcodeproj** file, there are no third party dependencies, so it’s pretty simple. In case you want to build on a real device, add your bundle ID project settings. 

# User Interface:
* Just build the app and you will see the loading screen while the catalog data is being fetched from the API. 
* After the successful data retrieval, ten catalogs are shown (or less). On each catalog tap, another screen appears which is correlated to the selected catalog. In this detailed screen you can go back or delete the catalog. In case you delete it, you will see the loading screen and the catalog list will appear again. 
* When catalogs are retrieved, they are encrypted and persisted so on the next app start, they are shown initially and then replaced by the newest ones fetched from the API. 
* In case of any error an alert is presented (turn the internet off and restart the app or try to tap a destination to try it out). Of course, this can be done in much more detail if Reachability class is used, but it would go outside of scope of this test project and it was mentioned to avoid 3rd party libs or other solutions. 
* Add new catalogs via postman or some other way and scroll up. You will see them appear after the loading screen. 
* Everything you see in this project is custom made, so nothing has been copied or used from some other source. 

# Architecture:
* MMVM-C is used as an app design pattern since it complements apples native, out of the box, MVC for UIKit and it's new MVVM in SwiftUI. Coordinator takes the role of presenting the application flow (like push, pop etc.).
* Networking module is independent and can be implemented anywhere. It is based on Apple's “URLSession” and generics so no third party libs have been used.
* There is a custom loading screen and alert for the user feedback. 
* Unit tests are made for view models and moc JSON of products list and details
* Reusable components have been made (like imageview) for illustration purposes. 
* The only external lib is for the encryption and only part of it. It’s **AES256.swift**
* File organisation: 
    * App - App related data 
     *Models
    * Views
    * ViewControllers
    * ViewModels
    * Lib - all custom made libraries with the main one being the networking module under “Networking” 
    * Resources - storyboards, strings, images
