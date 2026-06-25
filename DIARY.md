# 📔 Church Gear - System Engineering Diary

A living ledger of architectural decisions, cryptographic security implementations, and TDD sprint progress for the Church Gear multi-tenant SaaS ecosystem.

---

## 🏗️ Sprint 0: Environment Initialization & Clean Architecture Setup
**Date:** June 24, 2026

### 🔹 Architectural Decisions
* **Layered Clean Architecture:** Established a decoupled directory blueprint separating layout (`presentation/`), state-brokering (`logic/`), and structured data models/repositories (`data/`).
* **Unidirectional Data Flow:** Selected the BLoC (Business Logic Component) pattern to handle reactive configuration management, ensuring zero direct state manipulation from the UI layer.

### 🔹 Security & Guardrails
* **Local Workspace Sanitization:** Initialized Git tracking combined with a strict Flutter `.gitignore` layout to guarantee internal IDE metadata, compilation caches, and local hardware configurations never leak to the public repository.

---

## 🎨 Sprint 1: 10-Theme Dynamic Matrix Engine
**Date:** June 24, 2026

### 🔹 Implementations Completed
* **Design Matrix (`AppTheme`):** Built a centralized Material 3 design template generator mapping out 5 explicit stylistic modes (*Cathedral*, *Olive Grove*, *Royal Purple*, *Charcoal*, *Midnight*) paired with dynamic Light/Dark mode evaluation switches.
* **State Broker (`ThemeBloc`):** Coded the localized event pipeline handling asynchronous runtime aesthetic changes via `ChangeThemeEvent` emissions.
* **App Shell Integration:** Anchored `BlocProvider` and `BlocBuilder` components directly at the application tree root (`main.dart`) to reactively rebuild the global canvas whenever a user configuration adjustment occurs.

### 🔹 Security & Cryptographic Controls
* **Input Vector Hardening:** Enforced strict Dart `enum` constraints (`AppThemeMode`) for style switching requests. This restricts parameters to known compile-time declarations and entirely eliminates data injection vectors targeting the layout manager.

### 🔹 Automated Testing Status
* **`theme_engine_test.dart`:** Verified core palette properties, Material 3 enforcement, and fallback mechanics for default configurations.
* **`theme_bloc_test.dart`:** Stream-tested initial state validation and runtime state changes under asynchronous load profiles.
* **Status:** 🟢 **100% PASS** (4 assertions verified successfully).

---

## 🔐 Sprint 2: Multi-Tenant Session & Security Contract
**Date:** June 24, 2026

### 🔹 Implementations Completed
* **Data Model (`UserSession`):** Authored a immutable multi-tenant data structure enforcing core boundaries across user identifiers, explicit cryptographic JWT string containment, and dedicated tenant ID tokens.
* **Security Tiers (`UserRole`):** Mapped strict runtime authorization levels separating `guest`, `member`, and `admin` scopes.
* **State Manager (`AuthBloc`):** Coded full session lifecycle controllers capable of stream-emitting state data changes for active logins and safe, non-leaking account logouts.
* **Root Orchestrator:** Implemented `MultiBlocProvider` inside `main.dart` to link both layout structures and session variables uniformly down the widget tree.

### 🔹 Automated Testing Status
* **`user_session_test.dart`:** Verified JSON serialization and structural fallback configurations for guest identities.
* **`auth_bloc_test.dart`:** Streams validated initial unauthenticated states, programmatic credential injection, and secure session clearing.
* **Status:** 🟢 **100% PASS** (5 assertions verified successfully across the authentication layer).

---
## 🔒 Sprint 3: Cryptographic Token Cache & Hardware Storage
**Date:** June 24, 2026

### 🔹 Implementations Completed
* **Storage Wrapper (`SecureStorageService`):** Created a hardware-level data storage abstraction layer encapsulating `flutter_secure_storage` to write, read, and delete secure keys.
* **BLoC Integration:** Injected hardware caching mechanisms directly into `AuthBloc` lifecycle event routines (`LoginSuccessEvent` and `LogoutRequestedEvent`).
* **Dependency Injection:** Enhanced the block class constructors to cleanly accept decoupled storage engine properties, preserving strict testing isolation constraints.

### 🔹 Security & Cryptographic Controls
* **Data-at-Rest Protection:** Bound the local storage engine directly to the device's hardware-encrypted subsystem (Keychain on iOS and Keystore on Android) to completely mitigate raw text cache extraction vulnerabilities.

### 🔹 Automated Testing Status
* **`secure_storage_test.dart`:** Utilized Mockito code generation profiles to verify physical write calls and validation fallback checks against simulated hardware pipelines.
* **`auth_bloc_test.dart`:** Cross-layer tested mock state streams to guarantee runtime tokens pass down into storage hardware parameters flawlessly.
* **Status:** 🟢 **100% PASS** (9 total assertions validated successfully across the global test grid).

---
## 🌐 Sprint 5: Supabase Client SDK, Network Contracts & Secure Env Vault
**Date:** June 24, 2026

### 🔹 Implementations Completed
* **SDK Injection:** Installed and configured the official `supabase_flutter` integration package versioning matrix, adjusting parameters to use future-proofed `publishableKey` requirements.
* **Network Blueprint (`AuthRepository`):** Engineered decoupled abstraction layers isolating network data mapping rules from application logic modules.
* **Environment Isolation Vault (`.env`):** Integrated `flutter_dotenv` to inject sensitive project credentials at runtime, completely shielding backend API vectors from public repository history via `.gitignore` policies.

### 🔹 Automated Testing Status
* **`auth_repository_test.dart`:** Verified static compilation contracts and class signature definitions across the network repository tier.
* **Status:** 🟢 **100% PASS** (10 total assertions validating error-free across the system grid).

---

## 🗄️ Sprint 6: Cloud Schema Architecture & Multi-Tenant Rollout
**Date:** June 24, 2026

### 🔹 Implementations Completed
* **Cloud Database Schema:** Executed unified SQL scripts in the Supabase Cloud Editor to provision custom `user_profiles` tables with native `user_role_tier` enums.
* **Row-Level Security (RLS):** Enabled explicit row isolation policies preventing global leaks between church datasets while preserving master query privileges for the creator.
* **Super Admin Escalation:** Programmed automated PostgreSQL database trigger vectors to implicitly assign global platform clearance roles upon account verification matching `emab.dev.tech@gmail.com`.
* **Model Synchronization:** Expanded frontend `UserSession` model parameters and mapping deserializers to smoothly support the new `superAdmin` tier.

* **Operational Feature Tables:** Provisioned relational `inventory_items` and `gear_checkouts` schemas utilizing optimized data types (`gear_status_tier`).
* **Multi-Tenant Asset Gates:** Enforced automatic Row-Level Security isolation filters across all hardware inventory rows, strictly trapping tracking queries within individual church boundaries while preserving global visibility maps for the platform creator.

### 🔹 Automated Testing Status
* **Test Suite Verification:** Confirmed full data integrity boundaries across all system modules post-refactor.
* **Status:** 🟢 **100% PASS** (10 total assertions running cleanly).


---

## 🎛️ Sprint 7: Connecting AuthBloc to Live Infrastructure Contracts
**Date:** June 24, 2026

### 🔹 Implementations Completed
* **State Machine Overhaul:** Reconfigured `AuthBloc` controllers to drop local simulation toggles and connect directly to real data streams.
* **Network Pipeline Execution:** Wired `LoginWithEmailRequestedEvent` parameters directly into real asynchronous `SupabaseAuthRepository` methods.
* **Secure Cache Binding:** Tied runtime authentication success states to local device string storage checks (`getAuthToken`, `persistAuthToken`, `deleteAuthToken`).
* **Test Suite Refactoring:** Replaced stale event architectures with asynchronous unit tests using `mocktail` and `bloc_test`.

### 🔹 Automated Testing Status
* **Test Suite Verification:** Confirmed stable compilation across all modules.
* **Status:** 🟢 **100% PASS** (11 total assertions running cleanly).

---

## [Sprint 8] - Multi-Tenant Onboarding & Core Presentation Shell
### Completed
- Fixed Web Bootstrap Crash: Injected the missing Passkeys Web SDK dependency tag inside `web/index.html` to eliminate the runtime engine crash.
- Data Integration: Added `RegistrationPayload` model to compile, sanitize, and derive safe string `tenantId` parameters from raw input.
- Repository Layer: Expanded `AuthRepository` and `SupabaseAuthRepository` with the `signUpWithTenant` asynchronous network pipeline.
- State Engine Logic: Registered `EnterAsGuestEvent` and `RegisterWithTenantRequestedEvent` handlers inside `AuthBloc` to drive tenant provisioning.
- Interface Refactor: Transformed `auth_screen.dart` into a fluid state-toggle workspace supporting both Sign-In and Church Registration paths.

---

## [Sprint 8] - Multi-Tenant Onboarding & Core Presentation Shell
### Completed
- Fixed Web Bootstrap Crash: Injected the missing Passkeys Web SDK dependency tag inside `web/index.html` to eliminate the runtime engine crash.
- Data Integration: Added `RegistrationPayload` model to compile, sanitize, and derive safe string `tenantId` parameters from raw input.
- Repository Layer: Expanded `AuthRepository` and `SupabaseAuthRepository` with the `signUpWithTenant` asynchronous network pipeline.
- State Engine Logic: Registered `EnterAsGuestEvent` and `RegisterWithTenantRequestedEvent` handlers inside `AuthBloc` to drive tenant provisioning.
- Interface Refactor: Transformed `auth_screen.dart` into a fluid state-toggle workspace supporting both Sign-In and Church Registration paths.
- Automated Testing: Implemented a robust widget isolation test suite (`test/dashboard_screen_test.dart`) utilizing BLoC stream stubbing to verify error-free `BottomNavigationBar` viewport switching.

---

