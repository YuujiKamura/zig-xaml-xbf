# zig-xaml-compiler Design Document (Revised: Subprocess Approach)

This document outlines the architecture for `zig-xaml-compiler` using a subprocess-based approach after direct FFI with `GenXbf.dll` proved unstable due to undocumented signatures.

## 1. Overview: The Subprocess Pipeline

1.  **Input:** `.xaml` markup files.
2.  **XBF Generation:** Invoke `XamlCompiler.exe` (from Windows App SDK) as a standalone subprocess.
    -   This tool handles parsing, validation, and XBF emission.
    -   It typically expects a set of arguments or a JSON response file.
3.  **PRI Generation:** Invoke `MakePri.exe` to index the generated XBFs.
4.  **Runtime Loading:** Load via `Windows.UI.Xaml.Application.LoadComponent`.

---

## 2. Component Design

### 2.1. XBF Build Step (Subprocess)

The Zig build system will invoke `XamlCompiler.exe`.

-   **Tool Path:** `C:\Users\yuuji\.nuget\packages\microsoft.windowsappsdk\1.6.250108002\tools\net472\XamlCompiler.exe`
-   **Execution Logic:**
    -   Zig's `std.ChildProcess` (or `std.process.Child`) will be used to run the compiler.
    -   We need to determine the minimal CLI arguments for `XamlCompiler.exe` to process a single file.

### 2.2. PRI Generation Step

Remains as previously designed, calling `MakePri.exe`.

---

## 3. Integration with ghostty-win

-   `build.zig` will provide a helper function to add XAML compilation tasks.
-   The helper will encapsulate the `XamlCompiler.exe` command-line logic.

---

## 4. Proof of Concept (PoC) Plan

1.  **Identify CLI Arguments:** Run `XamlCompiler.exe /?` to discover required flags.
2.  **Standalone Run:** Manually compile `TabView.xaml` using the EXE.
3.  **Zig Implementation:** Update `src/main.zig` to wrap this call.
4.  **Build Integration:** Ensure `zig build run` orchestrates the process.

---

## 5. Challenges

-   **CLI Complexity:** `XamlCompiler.exe` is designed to be called by MSBuild and might require many arguments (TargetPlatform, SDK paths, etc.).
-   **Dependencies:** `XamlCompiler.exe` (net472) requires .NET Framework 4.7.2+ to be installed on the host.

---
*Revised: 2026-03-15*
