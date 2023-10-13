# RustInstallHelper

![RustInstallHelper Logo](rust_install_helper_logo.png)

Are you a Rust developer working in an environment with limited or [no internet access](https://users.rust-lang.org/t/developing-with-rust-offline/8679)? Are you struggling to manage Rust toolchains and dependencies on a Windows machine under these constraints? If so, the `RustInstallHelper` class is here to save the day!

## Introduction

The `RustInstallHelper` is a powerful, user-friendly tool designed to assist developers working offline or in environments with restricted internet access. It provides a set of static methods that mimic the behavior of essential Rust toolchain management functions, helping you overcome the challenges faced by developers like Mark, who posted the question on Stack Overflow.

## Problems We Solve

### 1. Installing Rust Toolchains

Many developers, especially beginners, face difficulties installing Rust toolchains on machines with no internet access. The `RustInstallHelper` class simplifies this process, allowing you to install and manage Rust toolchains with ease.

```powershell
[RustInstallHelper]::InstallRustToolchain("1.53.0")
```

### 2. Managing Rust Dependencies

Managing dependencies is a critical aspect of Rust development. `RustInstallHelper` provides methods to assist you in managing dependencies locally.

```powershell
[RustInstallHelper]::InstallCargoDependencies("my_crate")
```

### 3. Installing Rust Proxies

If you require Rust proxies for your offline development, the `RustInstallHelper` class can help you install and configure them effortlessly.

```powershell
[RustInstallHelper]::InstallRustProxies()
```

### 4. Simplified Project Building

The class also simplifies building Rust projects, ensuring that your projects are compiled correctly and efficiently.

```powershell
[RustInstallHelper]::BuildRustProject("my_project")
```

### 5. Exception Handling

Handling errors gracefully is crucial. `RustInstallHelper` includes error-handling methods to address issues without halting your workflow.

```powershell
try {
    [RustInstallHelper]::InstallRustToolchain("1.53.0")
} catch {
    Write-Host "An error occurred: $_"
}
```

## Getting Started

### Prerequisites

Before using `RustInstallHelper`, make sure you have the following:

- A Windows machine (offline or with restricted internet access)
- A Rust development environment
- PowerShell (version 5.1 or newer)

### Installation

1. Download the `RustInstallHelper.ps1` script.
2. Include the script in your project directory or desired location.

### Usage

To start using the `RustInstallHelper` class, follow these steps:

1. Open a PowerShell session.
2. Navigate to the directory where the `RustInstallHelper.ps1` script is located.
3. Import the script into your PowerShell session:

```powershell
. .\RustInstallHelper.ps1
```

4. You're now ready to use the `RustInstallHelper` methods to manage Rust toolchains, dependencies, proxies, and more.

## Example

Here's a simple example of how you can use `RustInstallHelper` to install a Rust toolchain:

```powershell
[RustInstallHelper]::InstallRustToolchain("1.53.0")
```

## Contributors

The `RustInstallHelper` project is open-source and welcomes contributions from the Rust community. Whether you're new to Rust or an experienced developer, you can help us improve this tool. Feel free to fork the repository, make your changes, and submit a pull request.

## License

`RustInstallHelper` is available under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Support

If you encounter any issues or have questions, please open an issue on the [GitHub repository](https://github.com/rust-install-helper) or reach out to our community for assistance.

Happy Rust coding! 🦀

![Rust Logo](rust_logo.png)
