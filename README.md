# torio

## Ruby on Rails Shell Project Application Template

This repository provides a template to kickstart a Ruby on Rails application, complete with Nix-based environment management and essential configurations.

Project Structure

```
├── .bundle           # Bundler configuration files
├── .direnv           # Direnv environment configuration
├── .envrc            # Environment variables for direnv
├── .git              # Git version control
├── .gitignore        # Git ignore rules
├── devshell.toml     # Development shell configuration
├── flake.lock        # Nix flake lock file
├── flake.nix         # Nix flake configuration for reproducible builds
├── Gemfile           # Ruby gems dependencies
├── Gemfile.lock      # Lock file for Ruby gems
├── layout.kdl        # Layout configuration (could be used for project structure or documentation)
├── README.md         # Project documentation (this file)
└── vendor            # Vendorized dependencies (if any)
```

### Getting Started

To start using this template for your Ruby on Rails application, follow these steps:

1. Clone the Repository

```
git clone https://github.com/Sylvance/torio.git
cd torio
```

2. Set Up Nix Environment

This template uses Nix and Direnv for environment management. Ensure you have Nix installed on your system. If not, you can install it from [determinate.systems nixos installer](https://determinate.systems/posts/determinate-nix-installer/). Install Direnv from [direnv webiste](https://direnv.net/).

Once Nix and Direnv are installed, you can set up the environment:

```
direnv allow
```

This will bring up a shell with all the dependencies needed for the Rails application.

3. Install Bundler and Gems
Inside the Nix shell, install the required Ruby gems:


```
bundle install
```

4. Start the Development Environment
This template uses Zellij as its terminal multiplexer. You can install it from [zellij's website](https://zellij.dev/documentation/installation). Now you’re ready to start the Development Environment:

```
devspace
```

5. Customize the Template

Feel free to customize this template to fit your project’s needs. Modify the Gemfile, add your own configurations, and set up additional services as required.

## Contributing

If you’d like to contribute to this template, please fork the repository and submit a pull request with your changes. We welcome improvements and new features!

## License

This template is open-source and available under the MIT License. See the LICENSE file for more information.
