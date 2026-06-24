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