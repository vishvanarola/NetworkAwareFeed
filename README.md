# NetworkAwareFeed

Project Description: UIKit MVVM Offline-Capable App
This iOS app demonstrates a clean architecture using UIKit, MVVM, and CoreData, built to handle both online and offline modes seamlessly.

The app fetches data from a dummy API (listing and detail), stores it locally using CoreData, and intelligently switches between API and local storage based on internet availability. It uses async/await for networking, a generic API manager, and follows SOLID principles for maintainability and scalability.

🔧 Key Features:
✅ MVVM architecture with separation of concerns
✅ CoreData integration for local persistence
✅ Async/Await API Manager using generics
✅ Offline Mode: loads data from CoreData if network is unavailable
✅ Image Caching using NSCache
✅ UIKit-based UI with List and Detail screens
✅ Singleton pattern used where appropriate (e.g., API manager, image cache)
✅ Clean Code Practices: proper comments, indentation, and constants management
✅ Fully functional Git versioning with meaningful commits
✅ README file with setup instructions and architecture overview

This project is a great example of building a resilient, offline-friendly iOS app that follows modern best practices in code architecture and user experience.
