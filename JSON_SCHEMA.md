# XamlCompiler JSON Schema

Based on reverse-engineering `Microsoft.UI.Xaml.Markup.Compiler.IO.dll` and `Microsoft.UI.Xaml.Markup.Compiler.MSBuildInterop.dll`, the following schemas are used for communication with `XamlCompiler.exe`.

## 1. input.json (CompilerInputs)

The `input.json` file is a serialized `Microsoft.UI.Xaml.Markup.Compiler.MSBuildInterop.CompilerInputs` object.

### Root Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| `ProjectPath` | `string` | Full path to the `.csproj` file. |
| `Language` | `string` | Language identifier (e.g., `"C#"`, `"CppWinRT"`). |
| `LanguageSourceExtension` | `string` | File extension for source files (e.g., `".cs"`). |
| `OutputPath` | `string` | Directory where generated files will be placed. |
| `ReferenceAssemblies` | `List<MSBuildItem>` | List of assembly references. |
| `TargetPlatformMinVersion` | `string` | Target platform minimum version (e.g., `"10.0.17763.0"`). |
| `ReferenceAssemblyPaths` | `List<MSBuildItem>` | Additional assembly search paths. |
| `BuildConfiguration` | `string` | Build config (e.g., `"Debug"`). |
| `ForceSharedStateShutdown` | `bool` | Whether to force shutdown shared compiler state. |
| `DisableXbfGeneration` | `bool` | Skip XBF generation. |
| `DisableXbfLineInfo` | `bool` | Skip line info in XBF. |
| `EnableXBindDiagnostics` | `bool` | Enable diagnostics for `{x:Bind}`. |
| `ClIncludeFiles` | `List<MSBuildItem>` | C++ header files. |
| `CIncludeDirectories` | `string` | C++ include directories. |
| `XamlApplications` | `List<MSBuildItem>` | Application definition XAML files (e.g., `App.xaml`). |
| `XamlPages` | `List<MSBuildItem>` | Page/UserControl XAML files. |
| `LocalAssembly` | `List<MSBuildItem>` | The assembly being built. |
| `SdkXamlPages` | `List<MSBuildItem>` | XAML pages from SDKs. |
| `ProjectName` | `string` | Name of the project. |
| `IsPass1` | `bool` | `true` for the first pass of compilation. |
| `RootNamespace` | `string` | Root namespace of the project. |
| `OutputType` | `string` | Output type (e.g., `"WinExe"`, `"Library"`). |
| `PriIndexName` | `string` | PRI index name. |
| `CodeGenerationControlFlags` | `string` | Internal flags for code gen. |
| `FeatureControlFlags` | `string` | Internal flags for features (e.g., `UsingCSWinRT`). |
| `XAMLFingerprint` | `bool` | Whether to use fingerprints for incremental build. |
| `UseVCMetaManaged` | `bool` | Internal flag for VC metadata. |
| `FingerprintIgnorePaths` | `string[]` | Paths to ignore during fingerprinting. |
| `VCInstallDir` | `string` | Path to VC installation. |
| `VCInstallPath32` | `string` | Path to 32-bit `vcmeta.dll`. |
| `VCInstallPath64` | `string` | Path to 64-bit `vcmeta.dll`. |
| `WindowsSdkPath` | `string` | Path to Windows SDK. |
| `CompileMode` | `string` | Compilation mode (e.g., `"RealBuildPass1"`). |
| `SavedStateFile` | `string` | Path to `XamlSaveStateFile.xml`. |
| `RootsLog` | `string` | Internal logging path. |
| `SuppressWarnings` | `string` | Warnings to suppress. |
| `GenXbfPath` | `string` | Internal path for XBF generation tool. |
| `PrecompiledHeaderFile` | `string` | Path to PCH. |
| `XamlResourceMapName` | `string` | Resource map name. |
| `XamlComponentResourceLocation` | `string` | Component resource location. |
| `XamlPlatform` | `string` | Platform identifier. |
| `TargetFileName` | `string` | Name of the final output file. |
| `IgnoreSpecifiedTargetPlatformMinVersion` | `bool` | Override min version check. |

### MSBuildItem Structure

| Property | Type | Description |
| :--- | :--- | :--- |
| `ItemSpec` | `string` | MSBuild ItemSpec (usually filename or relative path). |
| `FullPath` | `string` | Absolute path to the file. |
| `DependentUpon` | `string` | Parent file name. |
| `IsSystemReference` | `bool` | Flag for system assemblies. |
| `IsNuGetReference` | `bool` | Flag for NuGet packages. |
| `IsStaticLibraryReference` | `bool` | Flag for static libraries. |
| `MSBuild_Link` | `string` | Logical link path. |
| `MSBuild_TargetPath` | `string` | Target output path. |
| `MSBuild_XamlResourceMapName` | `string` | Resource map for this item. |
| `MSBuild_XamlComponentResourceLocation` | `string` | Resource location for this item. |

---

## 2. output.json (CompilerOutputs)

The `output.json` file is a serialized `Microsoft.UI.Xaml.Markup.Compiler.MSBuildInterop.CompilerOutputs` object.

| Property | Type | Description |
| :--- | :--- | :--- |
| `GeneratedCodeFiles` | `IList<string>` | Paths to generated `.g.cs` or `.g.h` files. |
| `GeneratedXamlFiles` | `IList<string>` | Paths to generated `.xaml` (stripped) files. |
| `GeneratedXbfFiles` | `IList<string>` | Paths to generated `.xbf` files. |
| `GeneratedXamlPagesFiles` | `IList<string>` | Subset of generated files for pages. |
| `MSBuildLogEntries` | `IList<MSBuildLogEntry>` | Log entries (errors, warnings) to be reported to MSBuild. |

### MSBuildLogEntry Structure

| Property | Type | Description |
| :--- | :--- | :--- |
| `Level` | `int` | Log level (0=Error, 1=Warning, 2=Message). |
| `Message` | `string` | Log message. |
| `Code` | `string` | Error/Warning code. |
| `File` | `string` | Source file path. |
| `LineNumber` | `int` | Line number. |
| `ColumnNumber` | `int` | Column number. |
| `EndLineNumber` | `int` | End line number. |
| `EndColumnNumber` | `int` | End column number. |
