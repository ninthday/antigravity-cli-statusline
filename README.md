# 🚀 Antigravity CLI Statusline (Max Edition)

An advanced, responsive, and high-information statusline plugin for the **[Antigravity CLI (Community Fork)](https://github.com/weby-homelab/antigravity-cli)** (`agy`). It features multi-layout adapting to your terminal width, real-time Git status tracking, token counting, active model quotas, and sandbox badges.

## 🛠️ Technology Stack

- **Language**: Bash Scripting (`statusline.sh`)
- **JSON Parsing**: `jq` (used efficiently in a single pass)
- **VCS**: `git` integration for branch tracking
- **Visuals**: Classic ANSI escape sequences (16-color palette) and Nerd Fonts (V3+)

## 🏗️ Project Architecture

The statusline operates by reading a JSON payload from `stdin` (provided by the Antigravity CLI) that describes the current agent state, context window usage, VCS info, and more.

- **Data Parsing**: Uses a single `jq` pass to extract all necessary variables quickly.
- **System Telemetry**: Directly queries `/sys/class/power_supply` for battery/AC status, `ip` for Tailscale IP, and `git` for branch info.
- **Dynamic Assembly**: Computes right-aligned pill badges and left-aligned powerline segments, formatting them based on the current terminal width (`$COLS`).

## 🚀 Getting Started

### Prerequisites

- `bash`
- `jq`
- `git`
- A terminal with a **Nerd Font (V3.0+)** installed and active.

### Installation & Usage

1. Place the `statusline.sh` script in your preferred location (e.g., `~/.gemini/antigravity-cli/statusline.sh`).
2. Make it executable: `chmod +x ~/.gemini/antigravity-cli/statusline.sh`.
3. Configure the Antigravity CLI `~/.gemini/antigravity-cli/settings.json` to use this script as its statusline command by adding:

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash /Users/your_user_name/.gemini/antigravity-cli/statusline.sh",
    "enabled": true
  }
}
```

**Options:**

- `--legend` (or `-l`): Display a legend of all telemetry components and icons.
- `--classic` (or `--no-nerdfont`): Use classic Unicode fallback icons instead of Nerd Font glyphs.

## 📁 Project Structure

- `statusline.sh`: The core bash script handling JSON parsing, telemetry gathering, and rendering.
- `README.md`: This documentation.

## ✨ Key Features

- **Multi-Layout Adaptation**: Automatically scales across 4 layouts (Ultra, Medium-Wide, Medium, Compact) depending on terminal width.
- **Deep Telemetry**: Displays agent state (READY, THINKING, WORKING, TOOL), background tasks, artifacts, and subagents.
- **System Metrics**: Real-time power/battery diagnostics and Tailscale IP tracking.
- **Model & Token Stats**: Context window usage visualizer (20-segment bar), active model, and API quota limits (Gemini/3P).
- **Graceful Degradation**: Built-in `--classic` mode for terminals without Nerd Font support.

## 🔄 Development Workflow

- Focus on keeping the script performant; any JSON parsing should remain within the single `jq` execution block.
- Test terminal layout changes by resizing the terminal and ensuring standard error output is kept clean (`2>/dev/null`).

## 📏 Coding Standards

- Use strict error handling (`set -euo pipefail`).
- Restrict to standard 16-color ANSI palette codes for maximum terminal compatibility.
- Ensure all variable extractions have fallbacks to prevent rendering failures when properties are missing from the JSON payload.

## 🤝 Contributing

Contributions are welcome! Please refer to the `AGENTS.md` file for our AI behavior and contribution guidelines, prioritizing:

1. **Think Before Coding**: Don't assume, surface tradeoffs.
2. **Simplicity First**: Write minimum code, avoid overcomplication.
3. **Surgical Changes**: Touch only what you must.
4. **Goal-Driven Execution**: Define success criteria and verify.

## 📄 License

This project does not currently specify an explicit license. Please check the main repository for updates.
