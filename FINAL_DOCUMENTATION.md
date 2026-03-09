# InfluCollab - Mobile Application Documentation

**Student Name:** <<Your Name>>  
**Coventry ID:** <<Your Coventry ID>>  
**Institution:** Softwarica College of IT & E-Commerce  
**Programme:** BSc (Hons) Computing  
**Module:** ST6002CEM – Mobile Application Development  
**Instructor:** Kiran Rana  
**Submission Date:** <<Due Date>>

---

## 1. Introduction

The influencer marketing industry has experienced remarkable growth, with brands increasingly seeking authentic partnerships with content creators across social media platforms. However, the process of connecting brands with suitable influencers remains inefficient and fragmented, often requiring multiple platforms, lengthy negotiations, and complex contract management. Mobile applications have become essential tools for facilitating these connections, offering real-time communication, streamlined workflows, and secure transaction processing that align with modern business practices.

This project presents InfluCollab, a cross-platform Flutter mobile application designed to bridge the gap between brands and influencers. The platform enables brands to create detailed marketing campaigns, discover suitable influencers through comprehensive profile browsing, and manage collaborations efficiently. Simultaneously, influencers can explore relevant campaign opportunities, submit applications, track their status, and communicate directly with brands through integrated messaging features, all from their smartphones.

### a. Aims and Objectives

**Aim:** To develop a comprehensive mobile application that connects brands with influencers, streamlining the campaign creation, discovery, application, and collaboration process through secure, real-time communication and efficient management tools.

**Objectives:**
- To implement secure user authentication with role-based access control for brands and influencers
- To enable brands to create, manage, and edit marketing campaigns with budget and deadline controls
- To allow influencers to discover relevant campaigns and submit applications efficiently
- To provide real-time messaging functionality for seamless brand-influencer communication
- To integrate biometric authentication for enhanced security and user convenience
- To implement gesture-based controls using device sensors for improved user experience
- To apply clean architecture principles with MVVM pattern for maintainable, testable code
- To utilize cloud-based backend infrastructure for scalable data management

### b. Background of proposed mobile app

The concept for InfluCollab emerged from observing significant challenges in the influencer marketing space. Existing platforms like AspireIQ and Upfluence primarily target enterprise clients with substantial budgets, charging monthly fees exceeding £1,000 and requiring complex onboarding processes. This enterprise focus leaves micro-influencers with 1,000-50,000 followers and small-to-medium businesses significantly underserved, despite micro-influencers often generating higher engagement rates due to authentic audience connections.

Research revealed critical shortcomings in current solutions. Most platforms lack true mobile-first experiences, offering web-based interfaces with limited mobile functionality. Communication systems rely on email or scheduled meetings, introducing delays that conflict with the fast-paced nature of social media. Application processes lack transparency, leaving influencers uncertain about their status and unable to learn from rejections.

InfluCollab addresses these gaps by providing an accessible, mobile-optimized platform specifically designed for emerging content creators and growing businesses. The application prioritizes mobile-first user experience, implements real-time messaging with 3-second polling intervals, and provides transparent application tracking. The planned freemium pricing model ensures accessibility while demonstrating technical proficiency in modern mobile application development.

### c. Features of your app

InfluCollab includes comprehensive features facilitating brand-influencer collaborations:

**User Authentication:** Secure registration allowing users to select roles (brand or influencer), JWT token-based login with automatic session management, biometric authentication support (Face ID/Fingerprint), and password reset functionality through email verification.

**Campaign Management:** Brands create detailed campaigns specifying title, description, category, budget range (£100-£1,000,000), deadline, location, requirements, and deliverables. The system validates budget constraints and ensures only present or future dates can be selected for deadlines. Brands can view, edit, and monitor application submissions.

**Influencer Discovery:** Brands browse registered influencers with comprehensive profiles displaying name, bio, content categories, languages, social media channels with follower counts, and portfolios. Search and filter capabilities enable finding influencers matching campaign requirements.

**Campaign Discovery and Applications:** Influencers browse available campaigns with search and filter options. Each campaign displays detailed information including budget, deadline, requirements, and brand details. Influencers submit applications and track status (pending, accepted, rejected) in application history.

**Real-Time Messaging:** Integrated messaging system enables direct communication between brands and influencers. Messages automatically refresh every 3 seconds using polling, providing near real-time conversation updates.

**Profile Management:** Users manage comprehensive profiles including personal information, profile pictures, bio, content categories, languages, and social media links. Dynamic statistics show total followers (calculated from Instagram, TikTok, Facebook follower counts) and total campaigns created. Profile completion indicators guide optimization.

**Biometric Security:** Users enable biometric authentication for quick, secure login. The system stores encrypted credentials in platform-specific secure storage with PIN/Pattern fallback.

**Gesture Controls:** Accelerometer-based shake detection allows users to toggle between light and dark themes by shaking devices three times within two seconds.

### d. App monetization

InfluCollab is currently in development without active monetization, focusing on core functionality and user experience. However, the architecture supports future implementation through commission-based models (10-15% on successful collaborations), freemium subscriptions (£9.99/month for influencers, £29.99/month for brands), featured listings (£19.99 for 7-day placement), and value-added services including consulting and training courses.

### e. Similar apps

AspireIQ is a leading influencer marketing platform offering discovery, campaign management, and analytics, primarily targeting enterprise brands. InfluCollab differs by targeting micro-influencers and small businesses, providing streamlined mobile-first design versus complex web interfaces, offering real-time messaging versus email communication, operating as an open marketplace versus invitation-based system, and planning affordable freemium pricing (£9.99-£29.99/month) versus enterprise fees (£1,000+/month).

---

## 2. Cloud Computing

Cloud computing enables applications to leverage remote server infrastructure rather than relying solely on device resources. In InfluCollab, cloud infrastructure manages user accounts, campaign listings, application records, messages, and profile data through a Node.js/Express backend with MongoDB database. This architecture enables users to access information from any device, ensuring data consistency across platforms.

Cloud systems provide scalability, allowing the application to handle growing user bases efficiently. As more brands and influencers join, cloud infrastructure automatically accommodates increased data storage and processing demands. This is crucial for handling large datasets including user profiles, campaign details, application histories, and message threads.

Big data capabilities enable InfluCollab to analyze user behavior patterns, campaign performance metrics, and matching algorithms. The platform can process thousands of influencer profiles and campaign listings simultaneously. Cloud-based analytics can identify trending content categories, optimal budget ranges, and successful collaboration patterns, providing valuable insights for optimizing strategies.

---

## 3. Design Pattern and Architectural Pattern

### a. Design Pattern

A design pattern is a reusable solution to commonly occurring problems in software design, providing structured approaches for organizing code to improve maintainability and scalability.

InfluCollab implements the Model-View-ViewModel (MVVM) pattern. Models represent data entities (User, Campaign, Application, Message). Views are UI components built with Flutter widgets. ViewModels manage application state and business logic, acting as bridges between Models and Views.

ViewModels use Riverpod providers to expose state to UI. When data changes (campaign created, application submitted), ViewModels update state and Views automatically reflect changes. This separation ensures clean code organization, easier testing, and improved maintainability.

### b. Architectural Pattern

InfluCollab follows Clean Architecture principles, organizing code into distinct layers: Presentation Layer (UI screens, widgets, ViewModels), Domain Layer (business logic, use cases, repository interfaces), and Data Layer (repository implementations, remote data sources for API calls, local data sources for SharedPreferences).

Benefits include independence (each layer operates independently), testability (business logic tested without UI dependencies), scalability (new features added without restructuring), and maintainability (clear boundaries simplify understanding).

Data flows: UI → ViewModel → Use Case → Repository → Data Source. This ensures UI never directly accesses data sources, providing consistent, testable abstractions.

---

## 4. State Management

State management tracks and updates data affecting the user interface, ensuring UI automatically reflects data changes. InfluCollab uses Riverpod, offering compile-time safety (errors caught during development), no BuildContext dependency (state accessed anywhere), improved testability (easy mocking), and automatic disposal (efficient resource management).

Each feature has dedicated providers: authViewModelProvider, campaignViewModelProvider, messageViewModelProvider, profileViewModelProvider. Screens listen using ref.watch(), ensuring automatic UI updates when state changes. When brands create campaigns, UI calls campaignViewModel.createCampaign(), ViewModel executes use case, use case calls repository, repository makes API request, response updates ViewModel state, and UI automatically rebuilds with new data.

---

## 5. Sensors and API

### a. Third-party APIs and Sensors

**Sensors:**

**Accelerometer (Shake Detection):** The shake package utilizes accelerometer sensors for gesture controls. Shake detection monitors device movement, triggering theme toggling when users shake devices three times within two seconds. Parameters include shake threshold gravity (2.0), shake slop time (500ms), and minimum shake count (3).

**Biometric Sensors:** The local_auth package accesses Face ID (iOS) and fingerprint scanners (Android) for secure authentication. BiometricAuthService checks device capabilities and performs authentication. Users enable biometric login from profile settings, storing encrypted credentials in iOS Keychain/Android KeyStore.

**GPS Sensor:** The geolocator package provides GPS access for location-based features, retrieving current position with high accuracy and calculating distances between coordinates.

**APIs:**

**Custom RESTful Backend:** Node.js/Express backend provides endpoints for authentication (/auth/login, /auth/register), campaigns (/campaigns, /campaigns/brand-stats), profiles (/profiles/influencers), applications (/applications/my), and messages (/messages/conversations). All requests use JWT authentication.

**Image Picker API:** The image_picker package accesses device camera and photo library for profile uploads. Permission_handler requests camera and storage permissions. Images are compressed to 70% quality before upload.

**URL Launcher API:** The url_launcher package opens external URLs. When users tap social media links, the app launches platforms in browsers or native apps.

**Socket.IO:** The socket_io_client package implements polling-based messaging, polling backend every 3 seconds during active conversations for near real-time communication.

**Share Plus API:** The share_plus package enables profile sharing through native platform mechanisms via messaging apps, social media, or email.

---

## 6. Data and Security

### a. Data Storage

InfluCollab stores authentication tokens, user profiles, biometric settings, and theme preferences locally using SharedPreferences. Extended profile data including bio, categories, and social media links are stored as query strings for quick access and offline functionality. The MongoDB database stores user accounts, campaigns, applications, messages, and notifications remotely. Profile pictures are stored in the server's /uploads directory, served via static middleware.

### b. Data Security

**Local Security:** Biometric credentials use platform-specific secure storage (iOS Keychain/Android KeyStore). JWT tokens are encrypted in SharedPreferences with 24-hour expiration. Biometric authentication (Face ID/Fingerprint) provides secure login with PIN/Pattern fallback.

**Remote Security:** Passwords are hashed using bcrypt with salt rounds before database storage. JWT tokens authenticate all API requests through authorization middleware. CORS restricts unauthorized access. Input validation prevents injection attacks. HTTPS/TLS encrypts data transmission between app and server.

---

## 7. References

1. Flutter Documentation. (n.d.). *Flutter - Build apps for any screen*. https://flutter.dev/
2. Riverpod Documentation. (n.d.). *Riverpod - A reactive caching framework*. https://riverpod.dev/
3. AspireIQ. (n.d.). *Influencer Marketing Platform*. https://www.aspireiq.com/
4. MongoDB. (n.d.). *MongoDB: The Developer Data Platform*. https://www.mongodb.com/
5. Express.js. (n.d.). *Fast web framework for Node.js*. https://expressjs.com/
6. Local Auth Package. (n.d.). *Flutter plugin for local authentication*. https://pub.dev/packages/local_auth
7. Shake Package. (n.d.). *Flutter plugin for shake detection*. https://pub.dev/packages/shake
8. Martin, R. C. (2017). *Clean Architecture*. Prentice Hall.

---

## 8. Appendix

### a. YouTube
YouTube Link: <<Your YouTube Link>>

### b. GitHub
- Frontend: <<Your Frontend GitHub Link>>
- Backend: <<Your Backend GitHub Link>>

### c. Screenshots
<<Include 4x4 or 4x3 grid showing: Onboarding, Login/Register, Brand Dashboard, Campaign Creation, Influencer Discovery, Campaign Details, Application Submission, Messaging, Profile, Edit Profile, Application History, Settings>>

