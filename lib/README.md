# Flutter BLoC Project Structure Guide

This guide outlines the recommended industry-standard folder structure for Flutter applications using the BLoC pattern. The structure follows clean architecture principles and is designed for scalability, maintainability, and team collaboration.

## Project Structure Overview

### Core Layer (`lib/core/`)

The core layer contains application-wide functionality and configurations that serve as the foundation of your application.

#### Configuration (`config/`)
Contains environment-specific configurations and setup files:
- API endpoints for different environments (dev, staging, prod)
- Feature flags and toggle configurations
- Environment variables and constants
- App-wide configuration objects

#### Constants (`constants/`)
Houses all application-wide constant values:
- API keys and secrets
- Route names and navigation constants
- Asset paths and references
- String constants
- Dimension and layout constants

#### Theme (`theme/`)
Manages the application's visual styling:
- Color schemes and palettes
- Typography definitions
- Theme configurations
- Custom theme extensions
- Design system implementations

#### Utils (`utils/`)
Contains helper utilities and common functions:
- Date formatters and manipulators
- String manipulation utilities
- Validation functions
- Common decorators
- Math utilities

#### Errors (`errors/`)
Handles error management across the application:
- Custom exception classes
- Error models and types
- Global error handlers
- Exception mappers
- Error reporting utilities

#### Network (`network/`)
Manages all network-related functionality:
- HTTP client configuration (Dio setup)
- API interceptors
- Base API classes
- Connection handlers
- Network status management

#### Storage (`storage/`)
Handles local data persistence:
- Shared preferences wrapper
- Secure storage implementation
- Cache managers
- Database configurations
- Local storage interfaces

#### Analytics (`analytics/`)
Manages application analytics and monitoring:
- Event tracking implementations
- User analytics services
- Performance monitoring
- Crash reporting
- Analytics mappers

#### Dependency Injection (`di/`)
Contains dependency injection setup and configuration:
- Service locator setup
- Module definitions
- Dependency configurations
- Injection containers

#### Enums (`enums/`)
Contains global enumeration definitions:
- Status enums
- Type definitions
- Common flags
- Shared enumerations

#### Extensions (`extensions/`)
Houses extension methods for existing classes:
- Widget extensions
- String extensions
- DateTime extensions
- Context extensions
- Custom type extensions

#### Localization (`localization/`)
Manages internationalization and localization:
- Translation files
- Localization delegates
- Language models
- Locale utilities

#### Navigation (`navigation/`)
Handles application routing and navigation:
- Route definitions
- Navigation services
- Deep link handlers
- Route guards
- Navigation utilities

### Features Layer (`lib/features/`)

Each feature module is a self-contained unit that follows a consistent internal structure.

#### BLoC (`bloc/`)
Manages state for the feature:
- BLoC classes
- Event definitions
- State definitions
- Cubit implementations
- State mappers

#### Models (`models/`)
Contains feature-specific domain models:
- Business objects
- Value objects
- Entity definitions
- Model mappers
- Type definitions

#### Repositories (`repositories/`)
Defines data access contracts:
- Repository interfaces
- Data contracts
- Cache strategies
- Repository methods
- Data access patterns

#### Services (`services/`)
Implements business logic:
- Use cases
- Business rules
- Service implementations
- Business logic handlers
- Feature-specific utilities

#### Views (`views/`)
Contains UI components:
- `screens/`: Full page implementations
- `widgets/`: Feature-specific components
- Screen controllers
- View models
- UI utilities

#### Data (`data/`)
Implements the data layer:
- `datasources/`:
  - `local/`: Local storage implementations
  - `remote/`: API clients and implementations
- `models/`: Data transfer objects
- `repositories/impl/`: Repository implementations

### Shared Layer (`lib/shared/`)

Contains components and services used across multiple features.

#### Widgets (`widgets/`)
Houses reusable UI components:
- Custom buttons
- Form fields
- Loading indicators
- Common dialogs
- Shared layouts

#### Services (`services/`)
Contains common service implementations:
- Authentication service
- Logging service
- Analytics service
- Permission handlers
- Common utilities

#### Hooks (`hooks/`)
Contains custom Flutter hooks:
- Form hooks
- Animation hooks
- Lifecycle hooks
- State hooks
- Effect hooks

#### Mixins (`mixins/`)
Houses shared mixins:
- Validation mixins
- State mixins
- Widget mixins
- Behavior mixins
- Utility mixins

#### Providers (`providers/`)
Contains state providers:
- Global state providers
- Theme providers
- Configuration providers
- Service providers
- Data providers

## Best Practices

1. Keep features isolated and independent
2. Follow the single responsibility principle
3. Maintain consistent naming conventions
4. Use proper abstraction layers
5. Implement proper dependency injection
6. Write comprehensive documentation
7. Follow test-driven development
8. Maintain separation of concerns
9. Use proper error handling
10. Implement proper logging and analytics

This structure provides a solid foundation for building scalable Flutter applications while maintaining code quality and developer productivity.
