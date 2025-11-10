# BLoC Architecture Implementation Guide

## Overview
This project has been converted to use the BLoC (Business Logic Component) architecture pattern for better state management and separation of concerns. All API calls are now centralized and managed through a unified repository pattern.

## Key Components Added

### 1. API Repository (`lib/api/api_service/api_repository.dart`)
- **Purpose**: Centralized API client that handles all network requests
- **Features**:
  - Automatic token management
  - Standardized error handling
  - Unified response parsing
  - ApiException for consistent error reporting

### 2. BLoC Structure
Each major feature has its own BLoC with three components:
- **Event**: Defines user actions/triggers
- **State**: Defines UI states
- **BLoC**: Contains business logic and state transitions

#### Current BLoCs Implemented:

##### AuthBloc (`lib/bloc/auth/`)
- **Events**: `SendOtpEvent`, `VerifyOtpEvent`, `LogoutEvent`, `CheckAuthStatusEvent`
- **States**: `AuthLoading`, `OtpSentSuccess`, `OtpVerificationSuccess`, `AuthenticatedState`, `UnauthenticatedState`, `AuthError`
- **Usage**: Handles login, OTP verification, logout, and authentication status

##### HomeBloc (`lib/bloc/home/`)
- **Events**: `LoadHomeDataEvent`, `RefreshHomeDataEvent`
- **States**: `HomeLoading`, `HomeLoaded`, `HomeError`
- **Usage**: Manages home screen data and banners

##### UserProfileBloc (`lib/bloc/user_profile/`)
- **Events**: `LoadUserProfileEvent`, `UpdateUserProfileEvent`, `GetPaymentStatusEvent`
- **States**: `UserProfileLoading`, `UserProfileLoaded`, `UserProfileUpdateSuccess`, `PaymentStatusLoaded`, `UserProfileError`
- **Usage**: Handles user profile data and updates

##### VehicleBloc (`lib/bloc/vehicle/`)
- **Events**: `AddVehicleEvent`, `SearchVehiclesEvent`, `LoadVehicleTypesEvent`, `UpdateVehicleEvent`, `DeleteVehicleEvent`
- **States**: `VehicleLoading`, `VehicleAddSuccess`, `VehicleSearchSuccess`, `VehicleTypesLoaded`, `VehicleUpdateSuccess`, `VehicleDeleteSuccess`, `VehicleError`
- **Usage**: Manages all vehicle-related operations

##### ChatBloc (`lib/bloc/chat/`)
- **Events**: `StartChatEvent`, `LoadChatHistoryEvent`, `SendMessageEvent`, `LoadChatConversationEvent`
- **States**: `ChatLoading`, `ChatStarted`, `ChatHistoryLoaded`, `ChatConversationLoaded`, `MessageSent`, `ChatError`
- **Usage**: Handles chat functionality

### 3. Updated API Endpoints (`lib/constants/api_endpoints.dart`)
Comprehensive list of all API endpoints organized by feature:
- Authentication
- User management
- Driver operations
- Vehicle management
- Chat functionality
- Payment processing
- Location services
- Document verification
- And more...

## Integration in main.dart
The app now uses `MultiBlocProvider` to provide all BLoCs globally:

```dart
MultiBlocProvider(
  providers: [
    BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(apiRepository: apiRepository),
    ),
    BlocProvider<HomeBloc>(
      create: (context) => HomeBloc(apiRepository: apiRepository),
    ),
    // ... other BLoCs
  ],
  child: // your app widget
)
```

## Migration Example: Login Screen
**Before (Direct API calls)**:
```dart
final response = await LoginService.sendOtp(phoneNumber);
if (response.status) {
  // Handle success
} else {
  // Handle error
}
```

**After (BLoC pattern)**:
```dart
// In screen:
context.read<AuthBloc>().add(SendOtpEvent(phoneNumber: phoneNumber));

// Listen for state changes:
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is OtpSentSuccess) {
      // Handle success
    } else if (state is AuthError) {
      // Handle error
    }
  },
  child: // your UI
)
```

## Benefits of This Architecture

### 1. **Separation of Concerns**
- UI only handles presentation logic
- Business logic is isolated in BLoCs
- API calls are centralized in the repository

### 2. **Testability**
- BLoCs can be easily unit tested
- Mock repository for testing
- State changes are predictable

### 3. **Maintainability**
- Single place to modify API endpoints
- Consistent error handling
- Standardized state management

### 4. **Reusability**
- BLoCs can be reused across multiple screens
- Common states and events
- Shared API repository

## How to Use BLoCs in Screens

### 1. **Basic Usage**
```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SomeBLoC, SomeState>(
      builder: (context, state) {
        if (state is LoadingState) {
          return CircularProgressIndicator();
        } else if (state is LoadedState) {
          return YourContent(data: state.data);
        } else if (state is ErrorState) {
          return ErrorWidget(message: state.message);
        }
        return SizedBox();
      },
    );
  }
}
```

### 2. **Triggering Events**
```dart
// Add event to BLoC
context.read<SomeBLoC>().add(SomeEvent(data: data));

// Or using BlocProvider.of
BlocProvider.of<SomeBLoC>(context).add(SomeEvent(data: data));
```

### 3. **Listening to State Changes**
```dart
BlocListener<SomeBLoC, SomeState>(
  listener: (context, state) {
    if (state is SuccessState) {
      Navigator.push(context, ...);
    } else if (state is ErrorState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: YourWidget(),
)
```

## Migration Status

### ✅ Completed
- [x] Centralized API repository
- [x] Updated API endpoints
- [x] AuthBloc implementation
- [x] HomeBloc implementation
- [x] UserProfileBloc implementation
- [x] VehicleBloc implementation
- [x] ChatBloc implementation
- [x] Global BLoC providers setup
- [x] Login screen migration

### 🚧 In Progress
- [ ] Driver functionality BLoC
- [ ] Payment processing BLoC
- [ ] Screen migrations (OTP, Dashboard, Profile, etc.)

### 📋 TODO
- [ ] Migrate remaining screens to use BLoC pattern
- [ ] Add comprehensive error handling
- [ ] Implement loading states across all screens
- [ ] Add offline capability
- [ ] Write unit tests for BLoCs

## Best Practices

### 1. **State Management**
- Always emit loading states before API calls
- Handle error states consistently
- Use meaningful state names

### 2. **Event Naming**
- Use verb + noun format (e.g., `LoadUserData`, `SendMessage`)
- Include necessary data in events
- Keep events simple and focused

### 3. **Error Handling**
- Always catch and handle exceptions
- Provide meaningful error messages to users
- Log errors for debugging

### 4. **Testing**
- Write unit tests for BLoCs
- Test state transitions
- Mock API repository for testing

## Next Steps
1. Continue migrating screens to use BLoC pattern
2. Implement remaining BLoCs (Driver, Payment)
3. Add comprehensive error handling and loading states
4. Write unit tests for all BLoCs
5. Add offline support where applicable

## Support
For questions about the BLoC implementation or migration, please refer to:
- [BLoC Library Documentation](https://bloclibrary.dev/)
- This implementation guide
- Code comments in the BLoC files
