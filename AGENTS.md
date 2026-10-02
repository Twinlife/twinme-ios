This project is the twinme and Skred private and secure messaging iOS application.

## Layout

- `WebRTCFramework`: Objective-C submodule providing WebRTC support as native library.
- `TwinlifeFramework`: Objective-C submodule defining the services
   to connect to the signaling server and manages generic abstractions in the SQLCipher database.
- `TwinmeFramework`: Objective-C submodule for high level abstractions on top of
   `TwinlifeFramework`.
- `TwinmeCommonFramework`: Objective-C submodule providing services and application utilities.

## Rules

- Implementation is exclusively in Objective-C for iOS 15 minimum
- Implementation architecture tries to follow the same architecture as on Android,
- Read top-level `CODING_GUIDELINES.md` and follow the submodule `CODING_GUIDELINES.md` for all code changes.
- You are not allowed to commit or push in git.
