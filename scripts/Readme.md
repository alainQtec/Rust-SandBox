# RustInstallHelper (version 0)

![RustInstallHelper Logo will go here...](rust_install_helper_logo.png)

Are you a Rust developer working in an environment with limited or [no internet access](https://users.rust-lang.org/t/developing-with-rust-offline/8679)? or some similar problem ... I'm still thinking about it!

The psmodule is mean't to be a user-friendly tool designed to assist developers on any os (but especially on windows).

It provides a set of static methods anf functions that mimic the behavior of essential Rust toolchain management functions, helping you overcome the challenges faced by developers like Mark, who posted the question on Stack Overflow.

## Features

### Installing Rust Toolchains

Many developers, especially beginners, face difficulties installing Rust toolchains on machines with no internet access. The `RustInstallHelper` module simplifies this process, allowing you to install and manage Rust toolchains with ease.

```powershell
[RustInstallHelper]::InstallRustToolchain("1.53.0")
```

### Managing Rust Dependencies

Managing dependencies is a critical aspect of Rust development. `RustInstallHelper` provides methods to assist you in managing dependencies locally.

```powershell
[RustInstallHelper]::InstallCargoDependencies("my_crate")
```

### Installing Rust Proxies

If you require Rust proxies for your offline development, the `RustInstallHelper` module can help you install and configure them effortlessly.

```powershell
[RustInstallHelper]::InstallRustProxies()
```

### Simplified Project Building

The module also simplifies building Rust projects, ensuring that your projects are compiled correctly and efficiently.

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

### Usage

```powershell
[RustInstallHelper]::InstallRustToolchain("1.53.0")
```

> MORE feature to come!

## Contributors

The `RustInstallHelper` project is open-source and welcomes contributions from the Rust community. Whether you're new to Rust or an experienced developer, you can help us improve this tool. Feel free to fork the repository, make your changes, and submit a pull request.

## License

`RustInstallHelper` is available under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Support

If you encounter any issues or have questions, please open an issue on the [GitHub repository](https://github.com/alainQtec/RustInstallHelper)

Happy coding! 🦀
