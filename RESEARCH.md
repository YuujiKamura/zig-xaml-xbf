# XAML Compiler Research Report

This document summarizes findings regarding the XAML Binary Format (XBF), PRI generation, and associated tools for the development of `zig-xaml-compiler`.

## 1. XAML Binary Format (XBF) Specification

XBF (XAML Binary Format) is a proprietary, closed-source format used by the Windows Runtime (WinRT) to represent pre-parsed XAML markup for performance optimization.

### Key Characteristics:
- **Successor to BAML:** XBF replaced the Binary Application Markup Language (BAML) used in WPF.
- **Internal Structure:** It uses a structured binary layout consisting of lookup tables (Strings, Assemblies, Type Namespaces, Types, Properties) and a DOM tree referencing these tables.
- **Versions:**
  - **v1:** Introduced in Windows 8.1.
  - **v2:** Introduced in Windows 10/WinUI 2.
  - **v2.1:** Used in newer WinUI versions (Windows App SDK).
- **Public Specification:** Microsoft has **not published** an official specification. Current understanding is based on community reverse-engineering efforts (e.g., `XbfDecompiler`, `XbfAnalyzer`).

## 2. GenXbf.dll Investigation

`GenXbf.dll` is the core binary component used by the XAML compiler to convert `.xaml` files into `.xbf`.

### Findings in Local Environment:
- **Specified Path:** `C:\Users\yuuji\WindowsTerminal\packages\Microsoft.UI.Xaml.2.8.4\tools\GenXbf.dll` was **not found**.
- **Alternative Location:** Found at `C:\Users\yuuji\.nuget\packages\microsoft.windowsappsdk\1.6.250108002\tools\x64\GenXbf.dll`.
- **Exports (Inferred):**
  - `WriteXbf`: The primary entry point. Likely signature:
    ```cpp
    HRESULT WriteXbf(IStream* xaml, IStream* xbf, IXamlMetadataProvider* provider, BOOL optimized, IUnknown* reserved);
    ```
  - `GetXbfVersion`: Returns the supported XBF version.

### Observations:
In WinUI 2.x (UWP), the XAML compiler is often bundled as `Microsoft.UI.Xaml.Markup.Compiler.dll` (a managed MSBuild task) which may internally call `GenXbf.dll`. In WinUI 3, `GenXbf.dll` is directly included in the `tools` directory of the `Microsoft.WindowsAppSDK` package.

## 3. PRI (Package Resource Index) Generation

PRI files store and resolve application resources (strings, images, file paths) based on runtime qualifiers (language, scale, contrast).

### Generation Tools:
- **`MakePri.exe`:** The official command-line tool in the Windows SDK (`C:\Program Files (x86)\Windows Kits\10\bin\<version>\<arch>\makepri.exe`).
- **Commands:**
  - `createconfig`: Generates a configuration XML (`priconfig.xml`).
  - `new`: Indexes a project directory to create a `.pri` file.
  - `dump`: Decompiles a binary `.pri` into a readable XML format.
- **Format Specification:** Proprietary, but the logic for reading/writing is open-sourced in `WindowsAppSDK/MRTCore` (Modern Resource Technology).

## 4. zig-xaml-compiler Contents & Status

- **Location:** `C:\Users\yuuji\zig-xaml-compiler`
- **Current Goal:** Decouple XAML/XBF/PRI generation from MSBuild/Visual Studio to enable usage from Zig.
- **Proposed Approaches:**
  1. **A: XamlBinaryWriter API:** Call `WriteXbf` in `GenXbf.dll` directly at build time.
  2. **B: XamlCompiler.exe Standalone:** Invoke the official compiler with JSON I/O (based on `microsoft-ui-xaml` repo).
  3. **C: Full Reimplementation:** Reverse-engineer the XBF format for a native Zig implementation.

---
*Date: 2026-03-15*
