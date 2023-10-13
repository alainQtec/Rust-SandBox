# .SYNOPSIS
#     rust development environment ocal Setup script
# .DESCRIPTION
#     A longer description of the script, its purpose, common use cases, etc.
# .NOTES
#     Information or caveats about the script e.g. 'This script is not supported in Linux'
# .LINK
#     Specify a URI to a help page, this will show when Get-Help -Online is used.
# .EXAMPLE
#     ./Setup.ps1 -Verbose
#     Explanation of the script or its result. You can include multiple examples with additional .EXAMPLE lines

$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$url = 'https://static.rust-lang.org/rustup/archive/1.25.1/i686-pc-windows-msvc/rustup-init.exe'
$url64 = 'https://static.rust-lang.org/rustup/archive/1.25.1/x86_64-pc-windows-msvc/rustup-init.exe'

Add-Type -TypeDefinition @"
    using System.Diagnostics
    using System.Environment
"@

# Define static arrays for proxyable tools and duplicated tools
$TOOLS = @("rustc", "rustdoc", "cargo", "rust-lldb", "rust-gdb", "rust-gdbgui", "rls", "cargo-clippy", "clippy-driver", "cargo-miri")
$DUP_TOOLS = @("rust-analyzer", "rustfmt", "cargo-fmt")

class EnvVar {
    [string] $name
    [string] $value

    EnvVar ([string] $name, [string] $value) {
        $this.name = $name
        $this.value = $value
    }

    [void] Apply ([System.Diagnostics.ProcessStartInfo] $cmd) {
        $oldValue = [System.Environment]::GetEnvironmentVariable($this.name, [System.EnvironmentVariableTarget]::Process)
        if ($oldValue -ne $null) {
            $parts = $oldValue -split ';'
            if ($parts -contains $this.value) {
                return
            }
        }
        $cmd.EnvironmentVariables[$this.name] = $this.value
    }
}

class EnvVarManager {
    [void] PrependPath ([string] $name, [string[]] $prepend, [System.Diagnostics.ProcessStartInfo] $cmd) {
        $oldValue = [System.Environment]::GetEnvironmentVariable($name, [System.EnvironmentVariableTarget]::Process)
        $parts = @()
        if ($oldValue -ne $null) {
            $parts = $oldValue -split ';'
        }
        foreach ($path in $prepend) {
            if ($parts -notcontains $path) {
                $parts = $path + $parts
            }
        }
        $newValue = $parts -join ';'
        $cmd.EnvironmentVariables[$name] = $newValue
    }

    [void] Increment ([string] $name, [System.Diagnostics.ProcessStartInfo] $cmd) {
        $value = [System.Environment]::GetEnvironmentVariable($name, [System.EnvironmentVariableTarget]::Process)
        if ([int]::TryParse($value, [ref]$null)) {
            $value = [int]::Parse($value) + 1
            $cmd.EnvironmentVariables[$name] = $value.ToString()
        }
    }
}

# Example usage:
# $envVar = [EnvVar]::new("RUST_RECURSION_COUNT", "5")
# $envVarManager = [EnvVarManager]::new()
# $cmd = New-Object System.Diagnostics.ProcessStartInfo
# $envVar.Apply($cmd)
# $envVarManager.Increment("RUST_RECURSION_COUNT", $cmd)
# $envVarManager.PrependPath("PATH", @("C:\NewPath"), $cmd)


# Define a function to check if a tool is proxyable
function IsProxyableTool {
    param (
        [string]$tool
    )

    if ($TOOLS -contains $tool -or $DUP_TOOLS -contains $tool) {
        return $true
    } else {
        throw [System.Exception]::new("unknown proxy name: '$tool'; valid proxy names are $($TOOLS + $DUP_TOOLS -join ', ')")
    }
}

# Define a function to get the component for a binary
function GetComponentForBinary {
    param (
        [string]$binary
    )

    $binaryPrefix = $binary -replace "\\.(exe|ps1)$"

    switch ($binaryPrefix) {
        "rustc", "rustdoc" {
            return "rustc"
        }
        "cargo" {
            return "cargo"
        }
        "rust-lldb", "rust-gdb", "rust-gdbgui" {
            return "rustc"  # These are not always available
        }
        "rls" {
            return "rls"
        }
        "cargo-clippy" {
            return "clippy"
        }
        "clippy-driver" {
            return "clippy"
        }
        "cargo-miri" {
            return "miri"
        }
        "rustfmt", "cargo-fmt" {
            return "rustfmt"
        }
        default {
            return $null
        }
    }
}


class UpdateStatus {
    [string] $status

    UpdateStatus ([string] $status) {
        $this.status = $status
    }
}

class InstallMethod {
    [System.Management.Automation.PSCustomObject] $cfg
    [System.Management.Automation.PSCustomObject] $desc
    [string] $profile
    [System.Management.Automation.PSCustomObject] $update_hash
    [System.Management.Automation.PSCustomObject] $dl_cfg
    [bool] $force
    [bool] $allow_downgrade
    [bool] $exists
    [System.Management.Automation.PSCustomObject] $old_date_version
    [string[]] $components
    [string[]] $targets
    [string] $src
    [string] $dest
    [string] $method

    InstallMethod (
        [System.Management.Automation.PSCustomObject] $cfg,
        [System.Management.Automation.PSCustomObject] $desc,
        [string] $profile,
        [System.Management.Automation.PSCustomObject] $update_hash,
        [System.Management.Automation.PSCustomObject] $dl_cfg,
        [bool] $force,
        [bool] $allow_downgrade,
        [bool] $exists,
        [System.Management.Automation.PSCustomObject] $old_date_version,
        [string[]] $components,
        [string[]] $targets,
        [string] $src,
        [string] $dest,
        [string] $method
    ) {
        $this.cfg = $cfg
        $this.desc = $desc
        $this.profile = $profile
        $this.update_hash = $update_hash
        $this.dl_cfg = $dl_cfg
        $this.force = $force
        $this.allow_downgrade = $allow_downgrade
        $this.exists = $exists
        $this.old_date_version = $old_date_version
        $this.components = $components
        $this.targets = $targets
        $this.src = $src
        $this.dest = $dest
        $this.method = $method
    }

    [UpdateStatus] Install () {
        # Implement the installation logic here and return the appropriate UpdateStatus object
    }

    # Implement the remaining methods in the InstallMethod class
}

class Uninstall {
    [string] $path

    Uninstall ([string] $path) {
        $this.path = $path
    }

    [void] UninstallToolchain () {
        # Implement the uninstallation logic here
    }

    # Implement the remaining methods in the Uninstall class
}






class rspackage {
    [string] $name = "rustup"
    [string] $description = "rustup: the Rust toolchain installer"
    [version] $version = "1.25.1"
    [string] $authors = "Mozilla"
    [string] $projectUrl = "https://rustup.rs"
    $unzipLocation = $toolsDir
    $fileType = 'exe'
    $url = $url
    $url64bit = $url64
    $checksumType64 = 'sha256'
    $silentArgs = '-v -y' # it seems we need '-v -y' starting with 1.9.0 to get rustup copied to the .cargo\bin folder.
    hidden [int[]] $validExitCodes = @(0, -1073741515)
    hidden [string] $licenseUrl = "https://github.com/rust-lang/rustup.rs#license"
    hidden [bool] $requireLicenseAcceptance = $true
    hidden [string] $sourceUrl = "https://github.com/rust-lang/rustup.rs"
    hidden [string] $docsUrl = "https://github.com/rust-lang/rustup.rs/blob/master/README.md"
    hidden [string] $bugTrackerUrl = "https://github.com/rust-lang/rustup.rs/issues"
    hidden [string[]] $tags = ('rustup', 'rust')
    rspackage() {}
}

# If you’re using Linux or macOS, open a terminal and enter the following command:
# $ curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh

<#
# https://static.rust-lang.org/dist/2023-10-05
#
# downloading component 'cargo'
# downloading component 'clippy'
# downloading component 'rust-docs'
# downloading component 'rust-std'
#>

class RustInstallHelper {
    [string] $rustVersion
    [string] $components
    [string] $targets
    hidden [string] $cacheKey
    hidden [string] $cachePath
    hidden [string] $installArgs

    RustInstallHelper([string]$rustVersion, [string]$components, [string]$targets) {
        $this.rustVersion = $rustVersion
        $this.components = $components
        $this.targets = $targets
        $this.cachePath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath("UserProfile"), ".rustup", "toolchains")
        $this.installArgs = "--default-toolchain none -y"
    }

    [void] InstallRust() {
        $has_rustup = Test-Path (Join-Path $env:USERPROFILE ".cargo/bin/rustup.exe")
        if (!$has_rustup) {
            switch ($true) {
                ($env:OS -in ("Darwin", "Linux")) {
                    $rustupSh = (Invoke-WebRequest -Uri "https://sh.rustup.rs" -UseBasicParsing).Content
                    $rustupShPath = Join-Path $env:USERPROFILE "rustup-init.sh"
                    $rustupSh | Set-Content -Path $rustupShPath -Encoding UTF8
                    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force
                    Start-Process -FilePath $rustupShPath -ArgumentList $this.installArgs -Wait
                }
                ($env:OS -eq "Windows_NT") {
                    # get it from: https://win.rustup.rs/x86_64
                    Start-Process -FilePath (Invoke-WebRequest -Uri "https://win.rustup.rs" -UseBasicParsing).Content -ArgumentList $this.installArgs -Wait
                }
                Default {
                    throw "Unsupported OS: $env:OS"
                }
            }
            $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::User)
        }

        if (-not (Test-Path (Join-Path $this.cachePath $this.rustVersion))) {
            $this.cacheKey = "rustup-$env:OS-$($this.rustVersion)-$($this.components.Replace(" ", "-"))-$($this.targets.Replace(" ", "-"))"
            Restore-Cache -Path $this.cachePath -Key $this.cacheKey
        }

        $argList = @(
            "toolchain",
            "install",
            $this.rustVersion,
            "--profile minimal",
            "--allow-downgrade"
        )

        if ($this.components) {
            $this.components.Split(" ") | ForEach-Object {
                $argList += "--component"
                $argList += $_
            }
        }

        if ($this.targets) {
            $this.targets.Split(" ") | ForEach-Object {
                $argList += "--target"
                $argList += $_
            }
        }

        Write-Host "Installing toolchain with components and targets: $($this.rustVersion) -- $($env:OS) -- $($this.components) -- $($this.targets)"

        $code = (Start-Process -FilePath "rustup" -ArgumentList $argList -NoNewWindow -Wait).ExitCode

        if ($code -ne 0) {
            throw "Failed installing toolchain exited with code: $code"
        }

        Write-Host "Setting the default toolchain: $($this.rustVersion)"
        $defaultCode = (Start-Process -FilePath "rustup" -ArgumentList "default $($this.rustVersion)" -NoNewWindow -Wait).ExitCode

        if ($defaultCode -ne 0) {
            throw "Failed setting the default toolchain exited with code: $defaultCode"
        }

        Write-Host "##[add-matcher]$($(Join-Path $PSScriptRoot "..\rustc.json"))"

        Write-Host "Saving cache: $($this.cacheKey)"
        try {
            Save-Cache -Path $this.cachePath -Key $this.cacheKey
        } catch {
            Write-Host "Cache hit occurred on key $($this.cacheKey), not saving cache."
        }
    }

    static [System.IO.Path] GetTempFileName() {
        $tempDirectory = [System.IO.Path]::GetTempPath()
        $tempFileName = [System.IO.Path]::Combine($tempDirectory, [System.IO.Path]::GetRandomFileName())
        New-Item -Path $tempFileName -ItemType File -Force | Out-Null
        return $tempFileName
        # Example usage
        # $tempFile = [RustInstallHelper]::GetTempFileName()
        # Write-Host "Temporary file created: $tempFile"
    }

    static [System.IO.Path] Combine([string[]]$paths) {
        return [System.IO.Path]::Combine($paths)
    }

    static [string] ErrorToString([System.Exception]$CurrError) {
        if ($CurrError -ne $null) {
            return $CurrError.ToString()
        }
        return "No error provided."
    }

    static [System.Management.Automation.ErrorRecord] CheckExistenceOfRustcOrCargoInPath() {
        $skipCheck = [System.Environment]::GetEnvironmentVariable("RUSTUP_INIT_SKIP_PATH_CHECK")

        if ($null -ne $skipCheck -and $skipCheck -eq "yes") {
            return $null
        }

        $path = [System.Environment]::GetEnvironmentVariable("PATH")
        $paths = $path.Split([System.IO.Path]::PathSeparator)

        foreach ($pathItem in $paths) {
            $rustcPath = Join-Path $pathItem "rustc$($env:EXE_SUFFIX)"
            $cargoPath = Join-Path $pathItem "cargo$($env:EXE_SUFFIX)"

            if (Test-Path -Path $rustcPath -or Test-Path -Path $cargoPath) {
                $message = "It looks like you have an existing installation of Rust at:`n$pathItem`n`n" +
                "It is recommended that rustup be the primary Rust installation.`n" +
                "Otherwise you may have confusion unless you are careful with your PATH.`n" +
                "If you are sure that you want both rustup and your already installed Rust" +
                "then please reply 'y' or 'yes' or set RUSTUP_INIT_SKIP_PATH_CHECK to yes" +
                "or pass '-y' to ignore all ignorable checks."
                $errorRecord = New-Object System.Management.Automation.ErrorRecord -ArgumentList (New-Object System.Exception $message), "RustupInstalledWithRust", "NotSpecified", $null
                return $errorRecord
            }
        }

        return $null
    }

    static [System.Management.Automation.ErrorRecord] DoPreInstallSanityChecks([bool] $noPrompt) {
        $rustcManifestPath = [System.IO.Path]::Combine("C:\usr\local\lib\rustlib", "manifest-rustc")
        $uninstallerPath = [System.IO.Path]::Combine("C:\usr\local\lib\rustlib", "uninstall.sh")
        $rustupShPath = [System.Environment]::GetFolderPath("UserProfile")
        $rustupShPath = [System.IO.Path]::Combine($rustupShPath, ".rustup")
        $rustupShVersionPath = [System.IO.Path]::Combine($rustupShPath, "rustup-version")

        $rustcExists = Test-Path -Path $rustcManifestPath -or (Test-Path -Path $uninstallerPath)
        $rustupShExists = Test-Path -Path $rustupShVersionPath

        if ($rustcExists) {
            $message = "It looks like you have an existing installation of Rust.`n" +
            "rustup cannot be installed alongside Rust. Please uninstall first.`n" +
            "run '$uninstallerPath' as root to uninstall Rust"
            $errorRecord = New-Object System.Management.Automation.ErrorRecord -ArgumentList (New-Object System.Exception $message), "RustInstalled", "NotSpecified", $null
            return $errorRecord
        }

        if ($rustupShExists) {
            $message = "It looks like you have existing rustup.sh metadata.`n" +
            "rustup cannot be installed while rustup.sh metadata exists.`n" +
            "delete '$rustupShPath' to remove rustup.sh.`n" +
            "or, if you already have rustup installed, you can run`n" +
            "`rustup self update` and `rustup toolchain list` to upgrade`n" +
            "your directory structure"
            $errorRecord = New-Object System.Management.Automation.ErrorRecord -ArgumentList (New-Object System.Exception $message), "RustupInstalled", "NotSpecified", $null
            return $errorRecord
        }

        return $null
        # Example usage
        # $errorRecord = [RustInstallHelper]::DoPreInstallSanityChecks($true)
        # if ($errorRecord -ne $null) {
        #     Write-Host "Error Message: $($errorRecord.Exception.Message)"
        # }
    }

    static [System.Management.Automation.ErrorRecord] DoPreInstallOptionsSanityChecks([System.Management.Automation.PSCustomObject] $opts) {
        # Verify that the installation options are vaguely sane
        $hostTriple = if ($opts.default_host_triple -eq $null) { [System.Management.Automation.PSTask]::CompletionInputOrOutput } else { $opts.default_host_triple }
        $partialChannel = if ($opts.default_toolchain -eq $null -or $opts.default_toolchain -eq 'None') { "stable" } else { $opts.default_toolchain }

        try {
            $resolved = [ResolvableToolchainName]::Resolve($partialChannel, $hostTriple)
        } catch {
            $errorMessage = "Pre-checks for host and toolchain failed: $($_.Exception.Message)`n" +
            "If you are unsure of suitable values, the 'stable' toolchain is the default.`n" +
            "Valid host triples look something like: $([TargetTriple]::FromHostOrBuild())"
            $errorRecord = New-Object System.Management.Automation.ErrorRecord -ArgumentList (New-Object System.Exception $errorMessage), "OptionsSanityCheckFailed", "NotSpecified", $null
            return $errorRecord
        }

        return $null
        # InstallOpts

        # Example usage
        # $opts = [PSCustomObject]@{
        #     default_host_triple = "x86_64-unknown-linux-gnu"
        #     default_toolchain = "beta"
        #     profile = "default"
        #     no_modify_path = $false
        # }

        # $errorRecord = [RustInstallHelper]::DoPreInstallOptionsSanityChecks($opts)
        # if ($errorRecord -ne $null) {
        #     Write-Host "Error Message: $($errorRecord.Exception.Message)"
        # }
    }

    static [string] PreInstallMsg([bool] $noModifyPath) {
        $cargoHome = [RustInstallHelper]::GetCargoHome()
        $cargoHomeBin = Join-Path $cargoHome "bin"
        $rustupHome = [RustInstallHelper]::GetRustupHome()

        if (-not $noModifyPath) {
            $message = @"
I'm going to ask you the value of each of these installation options.
You may simply press the Enter key to leave unchanged.

"@
        } else {
            $message = @"
To complete the installation, rustup will add the following to your PATH:
    $cargoHomeBin
    $rustupHome

"@
        }

        return $message
    }

    static [string] CurrentInstallOpts([PSCustomObject] $opts) {
        $defaultHostTriple = if ($opts.defaultHostTriple) {
            $opts.defaultHostTriple
        } else {
            [RustInstallHelper]::GetHostOrBuildTriple()
        }

        $defaultToolchain = if ($opts.defaultToolchain) {
            $opts.defaultToolchain.ToString()
        } else {
            "stable (default)"
        }

        $profile = $opts.profile

        $modifyPath = if (-not $opts.noModifyPath) { "yes" } else { "no" }

        $message = @"
Current installation options:

- Default host triple: $defaultHostTriple
- Default toolchain: $defaultToolchain
- Profile: $profile
- Modify PATH variable: $modifyPath
"@

        return $message
    }

    static [PSCustomObject] CustomizeInstall([PSCustomObject] $opts) {
        [Console]::WriteLine("I'm going to ask you the value of each of these installation options.")
        [Console]::WriteLine("You may simply press the Enter key to leave unchanged.")

        $defaultHostTriple = [RustInstallHelper]::QuestionStr("Default host triple?", $opts.defaultHostTriple)
        $defaultToolchain = [RustInstallHelper]::QuestionStr("Default toolchain? (stable/beta/nightly/none)", $opts.defaultToolchain)
        $profile = [RustInstallHelper]::QuestionStr("Profile (which tools and data to install)? (stable/beta/nightly/none)", $opts.profile)
        $noModifyPath = ![RustInstallHelper]::QuestionBool("Modify PATH variable?", $opts.noModifyPath)

        $customizedOpts = @{
            defaultHostTriple = $defaultHostTriple
            defaultToolchain  = $defaultToolchain
            profile           = $profile
            noModifyPath      = $noModifyPath
        }

        $customizedOptions = [PSCustomObject] $customizedOpts
        return $customizedOptions
    }

    static [string] QuestionStr([string] $question, [string] $defaultValue) {
        # Implement your logic to ask a question and retrieve input
        # You can use Read-Host or another method here
        return $false
    }

    static [bool] QuestionBool([string] $question, [bool] $defaultValue) {
        # Implement your logic to ask a question and retrieve input
        # You can use Read-Host or another method here
        return $false
    }

    static [void] InstallBins() {
        $binPath = [RustInstallHelper]::GetCargoHome().Combine("bin")
        $thisExePath = [RustInstallHelper]::GetCurrentExe()
        $rustupPath = $binPath.Combine("rustup.exe")  # Update the extension if needed

        [RustInstallHelper]::EnsureDirExists("bin", $binPath)

        if ($rustupPath.Exists) {
            [RustInstallHelper]::RemoveFile("rustup-bin", $rustupPath)
        }

        [RustInstallHelper]::CopyFile($thisExePath, $rustupPath)
        [RustInstallHelper]::MakeExecutable($rustupPath)
        [RustInstallHelper]::InstallProxies()
    }

    static [System.IO.FileInfo] GetCurrentExe() {
        $assembly = [System.Reflection.Assembly]::GetExecutingAssembly()
        [System.IO.FileInfo] $thisExe = [System.IO.FileInfo] $assembly.Location
        return $thisExe
    }

    static [void] CopyFile([System.IO.FileInfo] $source, [System.IO.FileInfo] $destination) {
        # Implement your logic to copy a file
        # You can use Copy-Item or another method here
    }

    static [void] RemoveFile([string] $description, [System.IO.FileInfo] $file) {
        # Implement your logic to remove a file
        # You can use Remove-Item or another method here
    }

    static [void] MakeExecutable([System.IO.FileInfo] $file) {
        # Implement your logic to make a file executable
        # You can use Set-ItemProperty or another method here
    }

    static [void] EnsureDirExists([string] $description, [System.IO.DirectoryInfo] $dirPath) {
        # Implement your logic to ensure that a directory exists
        # You can use Test-Path and New-Item or another method here
    }

    static [System.IO.DirectoryInfo] GetCargoHome() {
        # Implement your logic to get the cargo home directory
        # You can use [System.IO.Path]::Combine and [System.IO.DirectoryInfo] or another method here
    }

    static [void] InstallProxies() {
        # Implement your logic to install proxies
        # You can call your proxy installation logic here
    }
}

# Usage example:
# $rustInstaller = [RustInstallHelper]::new("stable", "clippy rustfmt", "x86_64-unknown-linux-gnu")
# $rustInstaller.InstallRust()



class Toolchain {
    [System.Management.Automation.PSCustomObject] $cfg
    [string] $name
    [System.IO.FileInfo] $path

    Toolchain ([System.Management.Automation.PSCustomObject] $cfg, [string] $name) {
        $path = $cfg.toolchain_path($name)
        if (-Not $this.Exists($cfg, $name)) {
            throw "ToolchainNotInstalled: $name"
        }

        $this.cfg = $cfg
        $this.name = $name
        $this.path = $path
    }

    [bool] Exists ([System.Management.Automation.PSCustomObject] $cfg, [string] $name) {
        $path = $cfg.toolchain_path($name)
        if (-Not (Test-Path -Path $path -PathType Container)) {
            return $false
        }

        return (Test-Path -Path $path -ChildPath "$($name)$([System.Environment]::ExeSuffix)")
    }

    [System.Management.Automation.PSCustomObject] CFG () {
        return $this.cfg
    }

    [string] Name () {
        return $this.name
    }

    [System.IO.FileInfo] Path () {
        return $this.path
    }

    [System.IO.FileInfo] BinaryFile ([string] $name) {
        $binaryPath = Join-Path -Path $this.path.FullName -ChildPath "bin\$($name)$([System.Environment]::ExeSuffix)"
        return [System.IO.FileInfo] $binaryPath
    }

    SetEnv ([System.Diagnostics.ProcessStartInfo] $cmd) {
        $this.SetLdPath($cmd)

        $cargoHome = [Utils]::CargoHome()
        if ($cargoHome) {
            $cmd.EnvironmentVariables["CARGO_HOME"] = $cargoHome
        }

        [EnvVar]::Increment("RUST_RECURSION_COUNT", $cmd)

        $cmd.EnvironmentVariables["RUSTUP_TOOLCHAIN"] = $this.name
        $cmd.EnvironmentVariables["RUSTUP_HOME"] = $this.cfg.rustup_dir
    }

    SetLdPath ([System.Diagnostics.ProcessStartInfo] $cmd) {
        $newPath = @()
        $newPath += Join-Path -Path $this.path.FullName -ChildPath "lib"

        $sysEnv = Get-Command -Name "Get-Command" | Select-Object -ExpandProperty Module | Where-Object { $_.Name -eq "Microsoft.PowerShell.Management" }
        $loaderPath = if ($sysEnv) { "LD_LIBRARY_PATH" } else { "DYLD_FALLBACK_LIBRARY_PATH" }

        if ($sysEnv -and $loaderPath -eq "DYLD_FALLBACK_LIBRARY_PATH") {
            $newPath += Join-Path -Path $env:HOME -ChildPath "lib"
            $newPath += "/usr/local/lib"
            $newPath += "/usr/lib"
        }

        $envVar = [EnvVar]::PrependPath($loaderPath, $newPath, $cmd)

        # Prepend CARGO_HOME/bin to the PATH variable
        $pathEntries = @()
        $cargoHome = [Utils]::CargoHome()
        if ($cargoHome) {
            $pathEntries += Join-Path -Path $cargoHome -ChildPath "bin"
        }

        if ($env:OS -eq "Windows_NT" -and $env:RUSTUP_WINDOWS_PATH_ADD_BIN -eq "1") {
            $pathEntries += Join-Path -Path $this.path.FullName -ChildPath "bin"
        }

        $envVar = [EnvVar]::PrependPath("PATH", $pathEntries, $cmd)
    }

    [string] RustcVersion () {
        $rustcPath = $this.BinaryFile("rustc").FullName
        if (Test-Path -Path $rustcPath) {
            $cmd = [System.Diagnostics.Process]::Start($rustcPath, "--version")
            $cmd.WaitForExit(10000)  # Timeout after 10 seconds
            if ($cmd.ExitCode -eq 0) {
                $output = $cmd.StandardOutput.ReadLine()
                $output = $output.TrimEnd([System.Environment]::NewLine)
                $cmd.Dispose()
                return $output
            }
        }
        return "(timeout reading rustc version)"
    }

    [System.Diagnostics.ProcessStartInfo] CreateCommand ([string] $binary) {
        $binary = if ($binary -match ".*\.(exe|msi)$") { $binary } else { "$binary$([System.Environment]::ExeSuffix)" }
        $binPath = Join-Path -Path $this.path.FullName -ChildPath "bin\$binary"

        if (Test-Path -Path $binPath) {
            $path = $binPath
        } else {
            $recursionCount = [System.Environment]::GetEnvironmentVariable("RUST_RECURSION_COUNT", [System.EnvironmentVariableTarget]::Process)
            if ([int]::TryParse($recursionCount, [ref]$null) -and $recursionCount -ge 0) {
                if ($recursionCount -gt 9) {
                    throw "'$binary' is not installed for the custom toolchain '$($this.name)'. This is a custom toolchain and cannot use 'rustup component add'."
                }
            }

            $path = $binary
        }

        $cmd = New-Object System.Diagnostics.ProcessStartInfo $path
        $this.SetEnv($cmd)
        return $cmd
    }

    [System.IO.FileInfo] DocPath ([string] $relative) {
        $parts = @("share", "doc", "rust", "html")
        $docDir = Join-Path -Path $this.path.FullName -ChildPath $parts
        $docDir = Join-Path -Path $docDir -ChildPath $relative

        return [System.IO.FileInfo] $docDir
    }

    OpenDocs ([string] $relative) {
        $docPath = $this.DocPath($relative).FullName
        [Utils]::OpenBrowser($docPath)
    }
}

class Utils {
    [string] CargoHome () {
        # Implement the `utils::cargo_home()` function here.
    }
}

class EnvVar {
    [System.Diagnostics.ProcessStartInfo] PrependPath ([string] $name, [string[]] $values, [System.Diagnostics.ProcessStartInfo] $cmd) {
        if (-Not $cmd.EnvironmentVariables.ContainsKey($name)) {
            $cmd.EnvironmentVariables[$name] = $values -join [System.IO.Path]::PathSeparator
        } else {
            $existing = $cmd.EnvironmentVariables[$name]
            $newPath = $values + $existing.Split([System.IO.Path]::PathSeparator)
            $cmd.EnvironmentVariables[$name] = $newPath -join [System.IO.Path]::PathSeparator
        }
    }

    [void] Increment ([string] $name, [System.Diagnostics.ProcessStartInfo] $cmd) {
        $value = [System.Environment]::GetEnvironmentVariable($name, [System.EnvironmentVariableTarget]::Process)
        if ([int]::TryParse($value, [ref]$null)) {
            $value = [int]::Parse($value) + 1
            $cmd.EnvironmentVariables[$name] = $value.ToString()
        }
    }
}

# You will need to implement the rest of the functions and classes mentioned in your Rust code.

