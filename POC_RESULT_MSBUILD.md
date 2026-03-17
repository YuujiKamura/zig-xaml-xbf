# POC Result: MSBuild XAML Compilation

This report details the attempt to compile `TabView.xaml` using `dotnet msbuild` instead of calling `XamlCompiler.exe` directly.

## 1. Setup

- **Project File:** `MinimalXaml.csproj` created with WinUI 3 references.
- **XAML Files:** `App.xaml` and `TabView.xaml`.
- **Source Files:** Dummy `.cs` files for `App` and `TabView` partial classes.
- **Target:** `CompileXaml` target added to `.csproj` which depends on `ResolveAssemblyReferences`, `MarkupCompilePass1`, and `MarkupCompilePass2`.

## 2. Execution Results

- **Command:** `dotnet msbuild MinimalXaml.csproj /t:CompileXaml /p:Platform=x64`
- **Result:** Failed with `Exit Code: 1`.
- **Error:** `error MSB3073: The command ""C:\Users\yuuji\.nuget\packages\microsoft.windowsappsdk\1.6.250108002\buildTransitive\..\tools\net6.0\..\net472\XamlCompiler.exe" "obj\x64\Debug\net9.0-windows10.0.22621.0\\input.json" "obj\x64\Debug\net9.0-windows10.0.22621.0\\output.json"" exited with code 1.`

## 3. Analysis

- The MSBuild task successfully generated `input.json` with all reference assemblies populated (after including `ResolveAssemblyReferences` in the dependency chain).
- The `XamlCompiler.exe` subprocess is being called by the MSBuild `Exec` task.
- Even with correct `input.json` and `ReferenceAssemblies`, `XamlCompiler.exe` returns code 1 without any diagnostic output.
- This suggests that either:
    1. The XAML itself contains errors or missing namespace declarations that the compiler can't handle.
    2. The `XamlCompiler.exe` (part of Windows App SDK 1.6) has undocumented environment dependencies or issues when run via `dotnet msbuild` (Core runtime).
- Interestingly, the drive letter `C:` was missing from the error message in some runs (e.g., `""Users\...`), but appeared in others.

## 4. Observations on `winui3-baseline`

- A reference project `winui3-baseline` was tested. It also failed with similar errors (`MSB4062` for `ExpandPriContent` and code 1 for `XamlCompiler.exe` when modified).
- This indicates a broader environment issue with building WinUI 3 projects via `dotnet msbuild` in this specific setup, possibly due to mismatched SDK/Tooling versions or runtime limitations.

## 6. Final Conclusion

Even after simplifying `TabView.xaml` to a basic `Grid` and ensuring all `ReferenceAssemblies` are correctly populated in `input.json` (verified by MSBuild diagnostic logs and `ResolveAssemblyReferences` target), the `XamlCompiler.exe` consistently returns **Exit Code: 1**.

This confirms that invoking the WinUI 3 XAML Compiler via `dotnet msbuild` (which internally uses `XamlCompiler.exe` for the Core runtime) is currently failing in this environment with a non-descriptive error. The previous success observed in `winui3-baseline` (existence of `App.xbf`) could not be reproduced by a fresh `dotnet msbuild` run, suggesting that the toolchain might require a full Visual Studio / `msbuild.exe` environment to function correctly.
