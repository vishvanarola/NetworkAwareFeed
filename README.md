# NetworkAwareFeed

NetworkAwareFeed is an iOS application that demonstrates efficient data handling with network awareness capabilities and local persistence using Core Data.

## Features

- Network-aware data fetching and caching
- Robust local data persistence using Core Data
- Efficient background context handling for data operations
- Thread-safe data management
- Singleton pattern implementation for Core Data manager

## Requirements

- iOS 14.0+
- Xcode 13.0+
- Swift 5.0+

## Architecture

The project follows a clean architecture pattern with the following key components:

### Core Data Manager

The application uses a robust Core Data implementation with the following features:

- Singleton pattern for shared instance
- Separate contexts for main and background operations
- Automatic context saving
- Error handling and logging

## Installation

1. Clone the repository:
```bash
git clone https://github.com/vishvanarola/NetworkAwareFeed.git
```

2. Open the project in Xcode:
```bash
cd NetworkAwareFeed
open NetworkAwareFeed.xcodeproj
```

3. Build and run the project in Xcode.

## Usage

The Core Data manager can be accessed throughout the application using:

```swift
let coreDataManager = CoreDataManager.shared
```

### Working with Core Data Contexts

Main context (for UI operations):
```swift
let mainContext = CoreDataManager.shared.mainContext
```

Background context (for heavy operations):
```swift
let backgroundContext = CoreDataManager.shared.newBackgroundContext()
```

### Saving Data

```swift
// Save changes in the current context
CoreDataManager.shared.saveContext()

// Save changes in a specific context
CoreDataManager.shared.saveContext(context: backgroundContext)
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Core Data framework by Apple
- Swift and iOS development community

## Contact

Your Name - [Vishva Narola](https://in.linkedin.com/in/vishva-narola-608610230)
Project Link: [https://github.com/vishvanarola/NetworkAwareFeed] 
