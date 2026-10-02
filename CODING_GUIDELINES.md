Coding rules for the project:

In the rule descriptions, `should` means this is a strong recommendation but we could have
documented exception, `must` and `shall` both mean it is mandatory.

## 1. General Principles

These rules also apply to submodules:

- Files start with the twinlife copyright header and the `SPDX-License-Identifier: AGPL-3.0-only`
  line, followed by the contributors list in the form `<full name> (<email-address>)`:

  ```Objective-C
  /*
   *  Copyright (c) 2015-2026 twinlife SA.
   *  SPDX-License-Identifier: AGPL-3.0-only
   *
   *  Contributors:
   *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
   *   Stephane Carrez (Stephane.Carrez@twin.life)
   */
  ```

- Human contributors are mentioned when they submit significant changes or bug fixes,
  AI are excluded from the contributors list
- The copyright year shall be updated to indicate the last year the file was changed:
  a new file uses a single year (`2026`), a file created in an earlier year uses a
  range `<creation year>-<last modification year>` (`2015-2026`).
- Properties and parameters must be annotated with `nullable` or `nonnull` when applicable.
- Internal properties must be declared in the `.m` implementation file (and not in the `.h` header).
- Inputs received in the constructor should be `readonly` (unless there is a real good reason not to be).
- Before a class-cast, check with `isKindOfClass` before assigning to a typed variable
- The logging framework to use is `CocoaLumberjack` and every method should have
  a `DDLogVerbose` declaration with method name and parameters:
  ```Objective-C
  #import <CocoaLumberjack.h>

  #if 0
  static const int ddLogLevel = DDLogLevelVerbose;
  #else
  static const int ddLogLevel = DDLogLevelWarning;
  #endif
  #undef LOG_TAG
  #define LOG_TAG @"AbstractTwinmeServiceTwinmeContextDelegate"
  ...
  DDLogVerbose(@"%@ initWithService: %@", LOG_TAG, service);
  ```
- When working on a sub-module, read and take into account the module `CODING_GUIDELINES.md`.
- Classes and types in the TwinlifeFramework, TwinmeFramework and KredsModule are prefixed by `TL`,

## 2. View controller implementation rules

- View controllers should inherit from `AbstractTwinmeViewController`.

## 3. Protocols implementation

- For a protocol serialization implementation, follow our TLEncoder/TLDecoder architecture
  defined in Java package `org.twinlife.twinlife` and available in the
  files `TwinlifeFramework/Twinlife/TLEncoder.h` and `TwinlifeFramework/Twinlife/TLDecoder.h`.
  Example of such serialization in TwinlifeFramework/Twinlife/service/secureroster/TLOnListRosterIQ.[hm]
- For the protocol, each packet is described by a class whose name ends with `IQ`.
  The class contains the properties that must be serialized.
  It also contains static classes to implement the serialization based on the
  TLEncoder or TLDecoder interfaces.
- Each packet inherits from TLBinaryPacketIQ and therefore is associated with a unique
  schema ID (a UUID) and a schema version.

## 4. State machines

State machine classes are used for the executors in `TwinmeFramework` and the
UI service helper classes in `TwinmeCommonFramework`.  They follow these rules:

- `onOperation()` is a re-entrant step state machine: it must be idempotent and
  re-entrant: it is called on start, and it is called again by every asynchronous
  callback to make progress, so it must be able to run several times and only
  trigger each step once.
- the state machine progress must be tracked by a `@property (nonatomic) int state;` with
  bit-flag constants declared in pairs, one to mark that a step has been started
  and one to mark that its result arrived.
- some state machine steps may be tracked by a single bit-flag constant when their
  execution does not produce an asynchronous result.
- Each step follows the same template: set the started bit before calling the service
  so a re-entry cannot issue the call twice, then return while the done bit is not set.
- Asynchronous callback steps shall be implemented as internal method
  with a `on` prefix and shall get the error code and result value (ex:
  `onGetTwincodeOutbound()`, `onSendFeedback()`, ...), it shall verify the error code
  and the result (if any), calls `onErrorWithOperationId()/onError()` and return if there was an error,
  or, the method shall set the `_DONE` bit and proceed with the next step by calling
  `onOperation()`.
- when an inherited method `onTwinlifeReady()`, `onTwinlifeOnline()` is overridden,
  it must call the super method.
