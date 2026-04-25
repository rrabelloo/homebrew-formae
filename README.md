# Homebrew Tap for Formae (DEPRECATED)

> **WARNING:** This Homebrew tap is no longer maintained.
> Please use the official installer to install Formae:
> 
> ```bash
> /bin/bash -c "$(curl -fsSL https://hub.platform.engineering/get/formae.sh)"
> ```

Unofficial Homebrew tap for [Formae](https://platform.engineering/formae), the Infrastructure-as-Code platform.

## Installation

```bash
brew tap rrabelloo/formae
brew install formae
```

Or install directly without adding the tap:

```bash
brew install rrabelloo/formae/formae
```

> **Note**: Currently only macOS Apple Silicon (arm64) is supported.

## Usage

After installation:

```bash
# Verify installation
formae --version

# Start the agent
formae agent start

# Apply infrastructure
formae apply --mode reconcile --watch

# List resources
formae inventory resources

# Destroy infrastructure
formae destroy --watch
```

## Updating

```bash
brew update
brew upgrade formae
```

## Uninstalling

```bash
brew uninstall formae
brew untap rrabelloo/formae
```

## About Formae

Formae is an open-source Infrastructure-as-Code platform by Platform Engineering Labs. Key features:

- 100% code-based infrastructure management
- No state files - reality is the state, versioned in code
- Automatic discovery and synchronization
- Agent-based architecture
- Uses PKL configuration language

## Resources

- [Official Documentation](https://docs.formae.io)
- [GitHub Repository](https://github.com/platform-engineering-labs/formae)
- [Platform Engineering Labs](https://platform.engineering/formae)

## License

This tap is provided as-is. Formae itself is licensed under FSL-1.1-ALv2 by Platform Engineering Labs.
