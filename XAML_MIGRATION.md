# XAML Migration: Issue #108 Step 1

## Overview
Created `Surface.xaml` and `TabViewRoot.xaml` in `C:\Users\yuuji\zig-xaml-compiler`, updated the project configuration, and successfully generated XBF files using MSBuild.

## Created Files

### 1. Surface.xaml
- **Structure**: `Grid` with 2 columns.
- **Contents**:
    - `SwapChainPanel` (Column 0)
    - `ScrollBar` (Column 1, Vertical, Width 17)
    - `TextBox` (ImeTextBox, Opacity 0)
- **Namespace**: `ghost`
- **Class**: `ghost.Surface` (Initially `ghost.ghostty`, changed to ensure uniqueness)

### 2. TabViewRoot.xaml
- **Structure**: `Grid` with 2 rows (40px + Star).
- **Contents**:
    - `TabView` (Row 0)
    - `Grid` (TabContentGrid, Row 1)
- **Namespace**: `ghost`
- **Class**: `ghost.TabViewRoot` (Initially `ghost.ghostty`, changed to ensure uniqueness)

## Build Process

### MSBuild Configuration
Updated `MinimalXaml.csproj` to include the new pages:
```xml
<ItemGroup>
  <ApplicationDefinition Include="App.xaml" />
  <Page Include="TabView.xaml" />
  <Page Include="Surface.xaml" />
  <Page Include="TabViewRoot.xaml" />
</ItemGroup>
```

### Build Result
The build was executed using MSBuild 17.14.
- **Initial Failure**: `error WMC9999: The class named 'ghost.ghostty' is represented by files with more than one base filename`.
- **Resolution**: Changed `x:Class` to `ghost.Surface` and `ghost.TabViewRoot` respectively.
- **Final Result**: **Build Succeeded.**

## Verification
The following XBF files were successfully generated in `bin\x64\Debug\net9.0-windows10.0.22621.0\`:
- `Surface.xbf` (1,063 bytes)
- `TabViewRoot.xbf` (1,167 bytes)
- `TabView.xbf` (531 bytes)
- `App.xbf` (728 bytes)

The XBF files are now ready for use in the Zig-based WinUI 3 application.
