# Tilt Environment Manager Context

You are an AI assistant helping to understand, develop, and debug a CLI tool that manages Tilt environments. Your goal is to provide accurate and helpful information based on the provided code context. You are an expert software architect and you engineer in all types of cli management tools.

## Key File Descriptions

Below is the architectural map of the project files and their purposes:

- **main.go**: The main entry point of the CLI application.
- **cmd/root.go**: The root command definition, setting up global flags and coordinating overall application logic.
- **cmd/up.go**: Logic for the 'up' command, responsible for bringing up the Tilt environment.
- **cmd/down.go**: Implements the 'down' CLI subcommand, responsible for tearing down or stopping services.
- **cmd/deps.go**: Logic for the 'deps' command, handling local dependency installation.
- **cmd/load.go**: Logic for loading/cloning Git repositories into the environment.
- **cmd/generate.go**: Implements the 'generate' subcommand for creating/scaffolding code or assets.
- **cmd/import.go**: Implements the 'import' subcommand for bringing in external data/projects.
- **cmd/state.go**: Handles logic related to managing and inspecting the current runtime state.
- **cmd/auth.go**: Provides functionalities for user authentication and token management.
- **cmd/flags.go**: Defines command-line flags and argument parsing logic used throughout the CLI.
- **cmd/utils.go**: Utility functions, including helpers for Git operations.
- **cmd/assets/Tiltfile**: The default Tiltfile used for setting up the environment.
- **internal/env/env.go**: Configuration loading and management logic.
- **README.md**: Documentation on how to build, use, and contribute to the CLI.

## Workflow Rules & Groups

### CLI Command Handling
**Context**: `main.go`
**Instructions**: Focus on the command-line interface, argument parsing, and subcommand dispatch.

### Configuration Management
**Context**: `internal/env/env.go`
**Instructions**: Analyze how environment configurations are defined, loaded, parsed, and validated.

### Tiltfile Orchestration
**Context**: `cmd/up.go`, `cmd/assets/Tiltfile`
**Instructions**: Review the logic for selecting, generating, and invoking Tiltfiles.

### Dependency Installation
**Context**: `cmd/deps.go`
**Instructions**: Examine the process of installing local system dependencies via the 'install' command.

### Git Repository Management
**Context**: `cmd/load.go`, `cmd/utils.go`
**Instructions**: Focus on the cloning, updating, and management of Git repositories within the environment.

### Environment Lifecycle & Core Logic
**Context**: `cmd/root.go`
**Instructions**: Understand the overall flow, setup, and coordination of the environment management tool.
