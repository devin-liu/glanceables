# Glanceables Project Overview

## Introduction

- **Purpose**: Turns parts of websites into Glanceable widgets, helping you keep tabs on what's important.
- **Scope**: Transforming complex websites into widgets that help you find what you need. Watch for price changes, check for open campground spaces, and get updates on the latest traffic situation.

## High-Level Architecture

The Glanceables project is designed to streamline the browsing experience on macOS by allowing users to save and interact with specific portions of webpages. The architecture is composed of several key components that interact through a central ContentView, facilitating a modular and scalable system.

1. **ContentView**:

   - Acts as the main interface where users interact with the application. It integrates various views and handles the navigation between different parts of the application. Holds the dashboard, webclip menu, and notifications manager.

2. **Web Capture System**:

   - Utilizes WebView to capture screenshots of webpages or specific areas defined by the user. This system is responsible for the real-time rendering and capture of web content.

3. **Local Storage**:

   - Saves the captured screenshots and webpage data locally. This allows users to access and manage their saved content offline and enhances the application's performance by reducing load times.

4. **Notification System**:

   - Integrates with macOS desktop notifications to alert users about updates or changes in their saved web content. This system helps in keeping the user informed without needing to actively check the app.

5. **Ollama Integration**:
   - Connects to Ollama for secure, private integration with an open-source LLM (large language model). This feature allows users to perform enhanced text analysis and other AI-driven tasks directly within the application.

## Directory Structure

- **Root Folders**:
  - `/View`: Contains all UI components.
  - `/ViewModel`: Handles the business logic associated with views.
  - `/Model`: Defines the data structure and business models.
  - `/Utilities`: Includes helper classes and utilities functions.

## Key Components

### Views

- **AddURLFormView**: Responsible for handling URL input forms.
- **NavigationButtonsView**: Contains navigation buttons for the UI.
- **CaptureRectangleView**: Manages the functionality to capture specific areas of the webpage.

### Repository

- **WebClipRepositoryProtocol.swift**: Defines the protocol for web clip data handling.
- **WebClipUserDefaultsRepository.swift**: Implementation of the WebClip repository using User Defaults for storage.

### ViewModels

- **DashboardViewModel**: Manages data and state for the dashboard.
- **WebClipManagerViewModel.swift**: Manages the lifecycle and operations of web clips.
- **WebViewCoordinator.swift**: Coordinates web views and their interactions within the app.

### Models

- **WebClip**: Represents the data model for a web clip.
- **SnapshotTimelineModel.swift**: Manages the timeline of captured web snapshots for historical views.
- **UserDefaults**: Manages user preferences stored across sessions.

### Utilities

- **JavascriptLoader.swift**: Loads and manages JavaScript for dynamic interaction within webviews.
- **NotificationManager.swift**: Manages all notifications to alert users about changes or updates.
- **URLUtilities.swift**: Helper functions for URL validation and manipulation.
- **UserDefaults.swift**: Manages the storage of user settings and preferences.
