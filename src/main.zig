const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const project_root = "C:\\Users\\yuuji\\zig-xaml-compiler";
    const csproj_name = "GeneratedProject.csproj";
    const xaml_file = "TabView.xaml";

    // 1. Generate minimal .csproj
    const csproj_content =
        \\<Project Sdk="Microsoft.NET.Sdk">
        \\  <PropertyGroup>
        \\    <OutputType>WinExe</OutputType>
        \\    <TargetFramework>net9.0-windows10.0.22621.0</TargetFramework>
        \\    <WindowsSdkPackageVersion>10.0.22621.52</WindowsSdkPackageVersion>
        \\    <Platforms>x64</Platforms>
        \\    <RuntimeIdentifiers>win-x64</RuntimeIdentifiers>
        \\    <UseWinUI>true</UseWinUI>
        \\    <WindowsPackageType>None</WindowsPackageType>
        \\    <WindowsAppSDKSelfContained>true</WindowsAppSDKSelfContained>
        \\    <AppxPackage>false</AppxPackage>
        \\    <EnableMsixTooling>false</EnableMsixTooling>
        \\    <EnableDefaultPageItems>false</EnableDefaultPageItems>
        \\    <EnableDefaultApplicationDefinition>false</EnableDefaultApplicationDefinition>
        \\    <RootNamespace>GeneratedProject</RootNamespace>
        \\  </PropertyGroup>
        \\  <ItemGroup>
        \\    <PackageReference Include="Microsoft.WindowsAppSDK" Version="1.6.250108002" />
        \\    <PackageReference Include="Microsoft.Windows.SDK.BuildTools" Version="10.0.26100.1742" />
        \\  </ItemGroup>
        \\  <ItemGroup>
        \\    <ApplicationDefinition Include="App.xaml">
        \\      <Generator>MSBuild:Compile</Generator>
        \\    </ApplicationDefinition>
        \\    <Page Include="
        ++ xaml_file ++ 
        \\">
        \\      <Generator>MSBuild:Compile</Generator>
        \\    </Page>
        \\  </ItemGroup>
        \\</Project>
    ;

    const app_xaml_content =
        \\<Application
        \\    x:Class="GeneratedProject.App"
        \\    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        \\    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml">
        \\    <Application.Resources>
        \\        <ResourceDictionary>
        \\            <ResourceDictionary.MergedDictionaries>
        \\                <XamlControlsResources xmlns="using:Microsoft.UI.Xaml.Controls" />
        \\            </ResourceDictionary.MergedDictionaries>
        \\        </ResourceDictionary>
        \\    </Application.Resources>
        \\</Application>
    ;

    const program_cs_content =
        \\using Microsoft.UI.Xaml;
        \\namespace GeneratedProject {
        \\    public partial class App : Application {
        \\        protected override void OnLaunched(LaunchActivatedEventArgs args) { }
        \\        static void Main(string[] args) {
        \\            Application.Start((p) => new App());
        \\        }
        \\    }
        \\}
    ;

    {
        var dir = try std.fs.openDirAbsolute(project_root, .{});
        defer dir.close();
        try dir.writeFile(.{ .sub_path = csproj_name, .data = csproj_content });
        try dir.writeFile(.{ .sub_path = "App.xaml", .data = app_xaml_content });
        try dir.writeFile(.{ .sub_path = "Program.cs", .data = program_cs_content });
    }
    std.debug.print("Generated project files in {s}\n", .{ project_root });

    // 2. Invoke dotnet restore
    std.debug.print("Running dotnet restore...\n", .{});
    var restore_proc = std.process.Child.init(&[_][]const u8{
        "dotnet",
        "restore",
        project_root ++ "\\" ++ csproj_name,
        "/p:Platform=x64",
    }, allocator);
    _ = try restore_proc.spawnAndWait();

    // 3. Invoke dotnet build
    std.debug.print("Running dotnet build...\n", .{});
    
    var proc = std.process.Child.init(&[_][]const u8{
        "dotnet",
        "build",
        project_root ++ "\\" ++ csproj_name,
        "/p:Configuration=Debug",
        "/p:Platform=x64",
        "/v:minimal",
        "/nologo",
    }, allocator);

    const term = try proc.spawnAndWait();
    switch (term) {
        .Exited => |code| {
            if (code == 0) {
                std.debug.print("Build successful!\n", .{});
                
                // 4. Search for XBF
                std.debug.print("Searching for generated XBF files...\n", .{});
                var obj_dir = try std.fs.openDirAbsolute(project_root ++ "\\obj", .{ .iterate = true });
                defer obj_dir.close();
                
                var walker = try obj_dir.walk(allocator);
                defer walker.deinit();
                
                while (try walker.next()) |entry| {
                    if (std.mem.endsWith(u8, entry.path, ".xbf")) {
                        std.debug.print("Found XBF: obj\\{s}\n", .{entry.path});
                    }
                }
            } else {
                std.debug.print("Build failed with exit code: {d}\n", .{code});
            }
        },
        else => {
            std.debug.print("Build terminated abnormally.\n", .{});
        },
    }
}
