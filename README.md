# Torio

### Getting Started

To start up using this project, follow these steps:

#### 1. Clone the Repository

```
git clone https://github.com/Sylvance/torio.git
cd torio
```

#### 2. Set Up Nix Environment

This repo uses Nix and Direnv for environment management. Ensure you have Nix installed on your system. If not, you can install it from [determinate.systems nixos installer](https://determinate.systems/posts/determinate-nix-installer/). Install Direnv from [direnv webiste](https://direnv.net/).

Once Nix and Direnv are installed, you can set up the environment:

```
direnv allow
```

This will bring up a shell with all the dependencies needed for the Rails application.

#### 3. Install Bundler and Gems
Inside the Nix shell, install the required Ruby gems:

```
bundle install
```

#### 4. Start the Development Environment
This repo uses Zellij as its terminal multiplexer. You can install it from [zellij's website](https://zellij.dev/documentation/installation). Now you’re ready to start the Development Environment:

```
devspace
```

## Contributing

If you’d like to contribute to this repo, please fork the repository and submit a pull request with your changes. We welcome improvements and new features!

## License

This repo is open-source and available under the MIT License. See the LICENSE file for more information.
