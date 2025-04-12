# Invio USG Challange 
Invio iOS case study. 

## Table of contents
* [Screenshots](#screenshots)
* [General info](#general-info)
* [Requirements](#requirements)
* [Design Pattern](#design-pattern)
* [Built-in Packages](#built-in-packages)
* [Technologies](#technologies)
* [Dependencies](#dependencies)

## Screenshots
### Light
<div align="left">
    <img src="/screenshots/light/ss1.png" width="200px"</img>
    <img src="/screenshots/light/ss2.png" width="200px"</img>
    <img src="/screenshots/light/ss3.png" width="200px"</img>
    <img src="/screenshots/light/ss4.png" width="200px"</img> 
    <img src="/screenshots/light/ss5.png" width="200px"</img> 
    <img src="/screenshots/light/ss6.png" width="200px"</img> 
    <img src="/screenshots/light/ss7.png" width="200px"</img> 
</div>

### Dark
<div align="left">
    <img src="/screenshots/dark/ss1.png" width="200px"</img>
    <img src="/screenshots/dark/ss2.png" width="200px"</img>
    <img src="/screenshots/dark/ss3.png" width="200px"</img>
    <img src="/screenshots/dark/ss4.png" width="200px"</img> 
    <img src="/screenshots/dark/ss5.png" width="200px"</img> 
    <img src="/screenshots/dark/ss6.png" width="200px"</img> 
    <img src="/screenshots/dark/ss7.png" width="200px"</img> 
</div>

## General info
This is an iOS Project that developed using `UIKit` framework for Invio USG iOS Challange. It is a 6 pages application which are: 
* Splash screen
* Main screen
* Location detail screen
* City map screen
* Location map screen
* Favorites screen 

All map-related features were built with `MKMapView`, while list-based views were implemented using `UITableView`. The `Kingfisher` library was used across the project to handle image downloading, caching, and scaling efficiently. The app applies `SOLID` principles throughout its architecture, and favorite locations are persistently managed using `UserDefaults`. Additionally, performance tests were conducted using Xcode Instruments, and no `hangs`, `hitches`, or `memory leaks` were detected in the application.

## Design Pattern
The project follows the MVC (Model-View-Controller) design pattern, which provides a clear separation of concerns and makes the codebase easier to understand and maintain. Each screen is structured around a dedicated view controller that interacts with the model layer and updates the UI accordingly. This approach ensures a straightforward and scalable architecture suitable for small to mid-sized iOS applications.

## Navigation
To manage screen transitions, the `Coordinator` Pattern was used. This helps decouple view controllers and keeps navigation logic out of them. By separating responsibilities and avoiding direct dependencies between controllers, compile times are improved and the codebase becomes easier to scale.

## Built-in Packages
The project includes several Swift Packages to support modular development and code reusability. Each package has a clear responsibility and contributes to maintaining a clean architecture.
<br /><br />

* Coordinators <br />
Manages the app’s navigation flow using the Coordinator Pattern. It keeps view controllers decoupled and improves maintainability by centralizing navigation logic.
* Entities <br />
Contains shared model objects such as CityModel, LocationModel, and CoordinateModel, used across various parts of the project.
* Helper <br />
Provides useful extensions and utility methods for UIKit and Foundation, improving code readability and reducing boilerplate.
* Persistence <br />
Implements a lightweight persistence layer using UserDefaults to manage favorite locations, with support for saving, deleting, and checking stored items.

## Technologies
The app is developed using:
* Swift Language version: 6
* Xcode Version 16.0 (16A242d)
## Requirements
iOS16.6+
## Dependencies
Only `Kingfisger` was used to handle image downloading, caching, and scaling efficiently in the project as a 3rd party dependency.

