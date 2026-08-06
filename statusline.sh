#!/bin/bash
set -euo pipefail
INPUT_JSON=$(cat)

# --- ANSI Helpers (Standard 16-color palette only) -------------------------------------
# ANSI Color Code: https://color-palette.hexdocs.pm/ansi_color_codes.htm
R="\e[0m"         # Reset
B="\e[1m"         # Bold
D="\e[2m"         # Dim
I="\e[3m"         # Italic

# Foreground accents (Standard 16 colors)
FG_BLACK="\e[30m"
FG_RED="\e[31m"
FG_GREEN="\e[32m"
FG_YELLOW="\e[33m"
FG_BLUE="\e[34m"
FG_MAGENTA="\e[35m"
FG_CYAN="\e[36m"
FG_WHITE="\e[37m"

FG_GRAY="\e[90m"
FG_BRIGHT_RED="\e[91m"
FG_BRIGHT_GREEN="\e[92m"
FG_BRIGHT_YELLOW="\e[93m"
FG_BRIGHT_BLUE="\e[94m"
FG_BRIGHT_MAGENTA="\e[95m"
FG_BRIGHT_CYAN="\e[96m"
FG_BRIGHT_WHITE="\e[97m"

# ANSI 256
FG_STRAWBERRY="\e[38;5;204m"
FG_LIGHT_ORANGE="\e[38;5;215m"
FG_CORAL="\e[38;5;209m"
FG_CALAMANSI="\e[38;5;229m"
FG_DANDELION="\e[38;5;221m"
FG_BLUE_COLA="\e[38;5;32m"
FG_VIVID_SKY_BLUE="\e[38;5;45m"

# Number Highlight Color
NUM_COLOR="${FG_BRIGHT_WHITE}${B}"

# --- Parse JSON from stdin (Single jq pass for performance) ----------------------------
{
  read -r STATE
  read -r USED_PCT
  read -r VCS_BRANCH
  read -r VCS_DIRTY
  read -r VCS_TYPE
  read -r VCS_CLIENT
  read -r SANDBOX
  read -r SANDBOX_NET
  read -r ARTIFACTS
  read -r SUBAGENTS
  read -r BG_TASKS
  read -r MODEL_ID
  read -r MODEL_NAME
  read -r COLS
  read -r CWD
  read -r CONV_ID
  read -r PRODUCT
  read -r INPUT_TOKENS
  read -r OUTPUT_TOKENS
  read -r CTX_LIMIT
  read -r CTX_USED
  read -r REM_PCT
  read -r GEMINI_5H
  read -r GEMINI_WK
  read -r TP_5H
  read -r TP_WK
  read -r GEMINI_5H_RESET
  read -r GEMINI_WK_RESET
  read -r TP_5H_RESET
  read -r TP_WK_RESET
  read -r CLI_VERSION
  read -r PLAN_TIER
  read -r USER_EMAIL
  read -r TURN_INPUT_TOKENS
  read -r TURN_OUTPUT_TOKENS
} <<< "$(
  echo "$INPUT_JSON" | jq -r '
    (.agent_state // "idle"),
    (.context_window.used_percentage // 0),
    (.vcs.branch // ""),
    (.vcs.dirty // false),
    (.vcs.type // ""),
    (.vcs.client // ""),
    (.sandbox.enabled // false),
    (.sandbox.allow_network // false),
    (.artifact_count // 0),
    (if .subagents | type == "array" then (.subagents | length) else 0 end),
    (.task_count // 0),
    (.model.id // ""),
    (.model.display_name // ""),
    (.terminal_width // 80),
    (.cwd // ""),
    (.conversation_id // ""),
    (.product // ""),
    (.context_window.total_input_tokens // 0),
    (.context_window.total_output_tokens // 0),
    (.context_window.context_window_size // 0),
    ((.context_window.total_input_tokens // 0) + (.context_window.total_output_tokens // 0)),
    (.context_window.remaining_percentage // 100),
    (if .quota["gemini-5h"].remaining_fraction != null then ((.quota["gemini-5h"].remaining_fraction * 1000 | round) / 10) else -1 end),
    (if .quota["gemini-weekly"].remaining_fraction != null then ((.quota["gemini-weekly"].remaining_fraction * 1000 | round) / 10) else -1 end),
    (if .quota["3p-5h"].remaining_fraction != null then ((.quota["3p-5h"].remaining_fraction * 1000 | round) / 10) else -1 end),
    (if .quota["3p-weekly"].remaining_fraction != null then ((.quota["3p-weekly"].remaining_fraction * 1000 | round) / 10) else -1 end),
    (.quota["gemini-5h"].reset_in_seconds // -1),
    (.quota["gemini-weekly"].reset_in_seconds // -1),
    (.quota["3p-5h"].reset_in_seconds // -1),
    (.quota["3p-weekly"].reset_in_seconds // -1),
    (.version // ""),
    (.plan_tier // ""),
    (.email // ""),
    (.context_window.current_usage.input_tokens // 0),
    (.context_window.current_usage.output_tokens // 0)
  ' 2>/dev/null || printf "idle\n0\n\nfalse\n\n\nfalse\nfalse\n0\n0\n0\n\n\n80\n\n\n\n0\n0\n0\n0\n100\n-1\n-1\n-1\n-1\n-1\n-1\n-1\n-1\n\n\n\n0\n0\n"
)"


# --- Parse CLI Arguments & Theme -------------------------------------------------------
USE_CLASSIC_ICONS=false
for arg in "$@"; do
  if [ "$arg" = "--classic" ] || [ "$arg" = "--no-nerdfont" ] || [ "$arg" = "--compatibility" ]; then
    USE_CLASSIC_ICONS=true
  fi
done

if [ "$USE_CLASSIC_ICONS" = "true" ]; then
  DOT_L1="${FG_GRAY} ╱ ${R}"
  DOT_L2="${FG_GRAY} · ${R}"
  ICON_READY="●"
  ICON_THINKING="◆"
  ICON_WORKING="⚙"
  ICON_TOOL="🔧"
  ICON_STATE_UNKNOWN="⏳"
  ICON_VCS="╱"
  ICON_MODEL=""
  ICON_SANDBOX_NET="ON (net)"
  ICON_SANDBOX_NONET="ON (no-net)"
  ICON_SANDBOX_OFF="OFF"
  ICON_CONTEXT_BAR="ctx"
  ICON_ARTIFACTS="artifacts"
  ICON_SUBAGENTS="subagents"
  ICON_TASKS="tasks"
  ICON_DIR="╱"
  ICON_CONV="╱"
  ICON_TOK_SUM=""
  ICON_RESET="⌛"
  ICON_AC="AC"
  ICON_BAT="BAT"
else
  DOT_L1="${FG_GRAY} | ${R}"
  DOT_L2="${FG_GRAY} | ${R}"
  ICON_READY=""
  ICON_THINKING="󰟷"
  ICON_WORKING=""
  ICON_TOOL=""
  ICON_STATE_UNKNOWN=""
  ICON_VCS=""
  ICON_MODEL=""
  ICON_SANDBOX_NET="󰒙"
  ICON_SANDBOX_NONET="󰴴"
  ICON_SANDBOX_OFF="󰦜"
  ICON_CONTEXT_BAR=""
  ICON_ARTIFACTS=""
  ICON_SUBAGENTS="󱙺"
  ICON_TASKS=""
  ICON_DIR=""
  ICON_CONV="󰍪"
  ICON_TOK_SUM=""
  ICON_RESET="󰔟"
  ICON_AC="󰚥"
  ICON_BAT="󰂎"
fi


# --- VCS directly from git (bypasses JSON parsing entirely) ----------------------------
GIT_DIR="${CWD:-.}"
VCS_BRANCH=$(git -C "$GIT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
if [ -n "$VCS_BRANCH" ]; then
  VCS_TYPE="git"
  if git -C "$GIT_DIR" status --porcelain 2>/dev/null | grep -q .; then
    VCS_DIRTY="true"
  else
    VCS_DIRTY="false"
  fi
else
  VCS_TYPE=""
  VCS_DIRTY="false"
fi

# --- Computed & Formatted Values -------------------------------------------------------
PCT_FMT=$(LC_NUMERIC=C printf "%.1f" "$USED_PCT")
PCT_INT=${USED_PCT%.*}; PCT_INT=${PCT_INT:-0}

human_format() {
  local num=$1
  if [ -z "$num" ] || [ "$num" -eq 0 ] 2>/dev/null; then
    echo "0"
    return
  fi
  if [ "$num" -ge 1000000 ] 2>/dev/null; then
    echo "$((num / 1000000)).$(((num % 1000000) / 100000))M"
  elif [ "$num" -ge 1000 ] 2>/dev/null; then
    echo "$((num / 1000)).$(((num % 1000) / 100))K"
  else
    echo "$num"
  fi
}

INPUT_TOK_FMT=$(human_format "$INPUT_TOKENS")
OUTPUT_TOK_FMT=$(human_format "$OUTPUT_TOKENS")
CTX_LIMIT_FMT=$(human_format "$CTX_LIMIT")
CTX_USED_FMT=$(human_format "$CTX_USED")
TURN_INPUT_FMT=$(human_format "$TURN_INPUT_TOKENS")
TURN_OUTPUT_FMT=$(human_format "$TURN_OUTPUT_TOKENS")

CLI_VER_FMT=""
if [ -n "$CLI_VERSION" ]; then
  CLI_VER_FMT="${DOT_L1}${FG_GRAY}v${CLI_VERSION}${R}"
fi

USER_FMT=""
if [ -n "$PLAN_TIER" ] || [ -n "$USER_EMAIL" ]; then
  user_info=""
  if [ -n "$PLAN_TIER" ] && [ -n "$USER_EMAIL" ]; then
    user_info="${USER_EMAIL} (${PLAN_TIER})"
  elif [ -n "$PLAN_TIER" ]; then
    user_info="${PLAN_TIER}"
  else
    user_info="${USER_EMAIL}"
  fi
  # Truncate if too long
  if [ "${#user_info}" -gt 35 ]; then
    user_info="${user_info:0:32}..."
  fi
  if [ "$USE_CLASSIC_ICONS" = "true" ]; then
    USER_FMT="${DOT_L1}${FG_STRAWBERRY}${user_info}${R}"
  else
    USER_FMT="${DOT_L1}${FG_STRAWBERRY} ${user_info}${R}"
  fi
fi

# --- Get hostname and Tailscale IP -----------------------------------------------------
HOST_NAME=$(hostname 2>/dev/null || echo "")
TS_IP=$(ip -4 addr show dev tailscale0 2>/dev/null | grep -o 'inet [0-9.]*' | cut -d' ' -f2 || echo "")

HOST_FMT=""
if [ -n "$HOST_NAME" ]; then
  host_details="$HOST_NAME"
  if [ -n "$TS_IP" ]; then
    host_details="${HOST_NAME} (${TS_IP})"
  fi
  if [ "$USE_CLASSIC_ICONS" = "true" ]; then
    HOST_FMT="${DOT_L1}${FG_BRIGHT_BLUE}${host_details}${R}"
  else
    HOST_FMT="${DOT_L1}${FG_BRIGHT_BLUE}󰒋 ${host_details}${R}"
  fi
fi

# --- Get Power Status (Resilience check) -----------------------------------------------
POWER_FMT=""
if [ -f /sys/class/power_supply/ACAD/online ]; then
  AC_ON=$(cat /sys/class/power_supply/ACAD/online 2>/dev/null || echo "1")
  BAT_CAP=$(cat /sys/class/power_supply/BAT1/capacity 2>/dev/null || echo "")
  
  if [ "$AC_ON" = "0" ]; then
    # Running on battery/UPS
    if [ "$USE_CLASSIC_ICONS" = "true" ]; then
      if [ -n "$BAT_CAP" ]; then
        POWER_FMT="${DOT_L2}${FG_BRIGHT_YELLOW}${ICON_BAT}:${BAT_CAP}%${R}"
      else
        POWER_FMT="${DOT_L2}${FG_BRIGHT_YELLOW}${ICON_BAT}${R}"
      fi
    else
      if [ -n "$BAT_CAP" ]; then
        POWER_FMT="${DOT_L2}${FG_BRIGHT_YELLOW}${ICON_BAT} ${BAT_CAP}%${R}"
      else
        POWER_FMT="${DOT_L2}${FG_BRIGHT_YELLOW}${ICON_BAT}${R}"
      fi
    fi
  else
    # Running on AC (Mains)
    if [ "$USE_CLASSIC_ICONS" = "true" ]; then
      POWER_FMT="${DOT_L2}${FG_GREEN}${ICON_AC}${R}"
    else
      POWER_FMT="${DOT_L2}${FG_GREEN}${ICON_AC} AC${R}"
    fi
  fi
fi

shorten_path() {
  local path=$1
  if [ -z "$path" ]; then
    echo ""
    return
  fi
  path="${path/#$HOME/\~}"
  if [ "${#path}" -gt 25 ]; then
    echo "...$(basename "$path")"
  else
    echo "$path"
  fi
}
CWD_SHORT=$(shorten_path "$CWD")

# --- Strip ANSI escapes to measure visible length --------------------------------------
visible_len() {
  # Strips ESC sequences and counts remaining bytes
  printf '%s' "$(echo -e "$1" | sed 's/\x1b\[[0-9;]*m//g')" | wc -m
}

# --- State Indicator -------------------------------------------------------------------
case "$STATE" in
  idle)     S="${FG_BRIGHT_GREEN}${B} ${ICON_READY} READY${R}" ;;
  thinking) S="${FG_BRIGHT_YELLOW}${B} ${ICON_THINKING} THINKING${R}" ;;
  working)  S="${FG_BRIGHT_CYAN}${B} ${ICON_WORKING} WORKING${R}" ;;
  tool_use) S="${FG_BRIGHT_MAGENTA}${B} ${ICON_TOOL} TOOL${R}" ;;
  *)        S="${FG_WHITE}${B} ${ICON_STATE_UNKNOWN} $(echo "$STATE" | tr '[:lower:]' '[:upper:]')${R}" ;;
esac

# --- VCS branch details ----------------------------------------------------------------
V=""
if [ -n "$VCS_BRANCH" ]; then
  if [ "$VCS_DIRTY" = "true" ]; then
    if [ "$USE_CLASSIC_ICONS" = "true" ]; then
      V="${DOT_L1}${FG_BRIGHT_RED}${VCS_BRANCH}${FG_BRIGHT_YELLOW}*${R}"
    else
      V="${DOT_L1}${R}${FG_BRIGHT_RED}${ICON_VCS} ${VCS_BRANCH}${FG_BRIGHT_YELLOW}*${R}"
    fi
  else
    if [ "$USE_CLASSIC_ICONS" = "true" ]; then
      V="${DOT_L1}${FG_BRIGHT_BLUE}${VCS_BRANCH}${R}"
    else
      V="${DOT_L1}${R}${FG_BRIGHT_BLUE}${ICON_VCS} ${VCS_BRANCH}${R}"
    fi
  fi
fi

# --- Model -----------------------------------------------------------------------------
MODEL_DISP="${MODEL_NAME:-$MODEL_ID}"

# Mark if the model is Gemini
if [[ "${MODEL_ID,,}" == *gemini* || "${MODEL_NAME,,}" == *gemini* ]]; then
  MODEL_GEMINI=true
  MODEL_COLOR="${FG_VIVID_SKY_BLUE}"
else
  MODEL_GEMINI=false
  MODEL_COLOR="$FG_CORAL"
fi

M=""
if [ -n "$MODEL_DISP" ]; then
  if [ "$USE_CLASSIC_ICONS" = "true" ]; then
    M="${DOT_L1}${MODEL_COLOR}${I}${MODEL_DISP}${R}"
  else
    M="${DOT_L1}${MODEL_COLOR}${I}${ICON_MODEL} ${MODEL_DISP}${R}"
  fi
fi


# --- Sandbox Badge ---------------------------------------------------------------------
SB_FMT=""
if [ "$SANDBOX" = "true" ]; then
  if [ "$SANDBOX_NET" = "true" ]; then
    SB_FMT="${FG_GREEN}${ICON_SANDBOX_NET} (net-on)${R}"
  else
    SB_FMT="${FG_GREEN}${ICON_SANDBOX_NONET} (net-off)${R}"
  fi
else
  if [ "$USE_CLASSIC_ICONS" = "true" ]; then
    SB_FMT="${FG_GRAY}sandbox off${R}"
  else
    SB_FMT="${FG_RED}${ICON_SANDBOX_OFF} ${R}"
  fi
fi

# --- Context Bar (20 segments) ---------------------------------------------------------
BAR_LEN=12
FILLED=$((PCT_INT * BAR_LEN / 100))
REMAINDER=$(( (PCT_INT * BAR_LEN) % 100 ))

if   [ "$PCT_INT" -ge 90 ]; then FILL_COLOR="$FG_BRIGHT_RED"
elif [ "$PCT_INT" -ge 60 ]; then FILL_COLOR="$FG_CALAMANSI"
else                              FILL_COLOR="$FG_DANDELION"
fi

if [ "$USE_CLASSIC_ICONS" = "true" ]; then
  BAR=""
  for ((i = 0; i < BAR_LEN; i++)); do
    if   [ "$i" -lt "$FILLED" ]; then
      BAR="${BAR}█"
    elif [ "$i" -eq "$FILLED" ]; then
      if   [ "$REMAINDER" -ge 75 ]; then BAR="${BAR}▓"
      elif [ "$REMAINDER" -ge 50 ]; then BAR="${BAR}▒"
      elif [ "$REMAINDER" -ge 25 ]; then BAR="${BAR}░"
      else                               BAR="${BAR}·"
      fi
    else BAR="${BAR}·"
    fi
  done
  CTX_BAR="${FG_GRAY}ctx ${FILL_COLOR}${BAR} ${NUM_COLOR}${PCT_FMT}%${R}"
else
  BAR=""
  for ((i = 0; i < BAR_LEN; i++)); do
    if   [ "$i" -lt "$FILLED" ]; then
      BAR="${BAR}${FILL_COLOR}█${R}"
    elif [ "$i" -eq "$FILLED" ]; then
      if   [ "$REMAINDER" -ge 75 ]; then BAR="${BAR}${FILL_COLOR}▓${R}${FG_GRAY}"
      elif [ "$REMAINDER" -ge 50 ]; then BAR="${BAR}${FILL_COLOR}▒${R}${FG_GRAY}"
      else                               BAR="${BAR}${FILL_COLOR}░${R}${FG_GRAY}"
      fi
    else BAR="${BAR}${FG_GRAY}░${R}"
    fi
  done
  CTX_BAR="${FG_DANDELION}${ICON_CONTEXT_BAR}  ${R}${BAR} ${NUM_COLOR}${PCT_FMT}%${R}"
fi

# --- Stats & Metadata formatting -------------------------------------------------------
if [ "$USE_CLASSIC_ICONS" = "true" ]; then
  ART_FMT="${FG_GRAY}artifacts ${NUM_COLOR}${ARTIFACTS}${R}"
  SUB_FMT="${FG_GRAY}subagents ${NUM_COLOR}${SUBAGENTS}${R}"
  BG_FMT="${FG_GRAY}tasks ${NUM_COLOR}${BG_TASKS}${R}"
else
  ART_FMT="${FG_BLUE}${ICON_ARTIFACTS} ${NUM_COLOR}${ARTIFACTS}${R}"
  SUB_FMT="${FG_CYAN}${ICON_SUBAGENTS} ${NUM_COLOR}${SUBAGENTS}${R}"
  BG_FMT="${FG_MAGENTA}${ICON_TASKS} ${NUM_COLOR}${BG_TASKS}${R}"
fi

DIR_FMT=""
if [ -n "$CWD_SHORT" ]; then
  if [ "$USE_CLASSIC_ICONS" = "true" ]; then
    DIR_FMT="${DOT_L1}${FG_LIGHT_ORANGE}${CWD_SHORT}${R}"
  else
    DIR_FMT="${DOT_L1}${FG_LIGHT_ORANGE}${ICON_DIR} ${CWD_SHORT}${R}"
  fi
fi

CONV_FMT=""
if [ -n "$CONV_ID" ]; then
  if [ "$USE_CLASSIC_ICONS" = "true" ]; then
    CONV_FMT="${DOT_L1}${FG_GRAY}${CONV_ID:0:8}${R}"
  else
    CONV_FMT="${DOT_L1}${FG_GRAY}${ICON_CONV} ${CONV_ID:0:8}${R}"
  fi
fi

TOK_DETAILS_WIDE=""
TOK_DETAILS_MED=""
if [ "$CTX_USED" -gt 0 ] 2>/dev/null; then
  turn_str=""
  if [ "$TURN_INPUT_TOKENS" -gt 0 ] || [ "$TURN_OUTPUT_TOKENS" -gt 0 ]; then
    turn_str=" | turn: +${TURN_INPUT_FMT}/${TURN_OUTPUT_FMT}"
  fi
  if [ "$USE_CLASSIC_ICONS" = "true" ]; then
    TOK_DETAILS_WIDE=" (${CTX_USED_FMT}/${CTX_LIMIT_FMT})${DOT_L2}(total: ${INPUT_TOK_FMT}/${OUTPUT_TOK_FMT}${turn_str})"
    TOK_DETAILS_MED=" (${CTX_USED_FMT}/${CTX_LIMIT_FMT})"
  else
    TOK_DETAILS_WIDE=" (${CTX_USED_FMT}/${CTX_LIMIT_FMT})${DOT_L2}${FG_YELLOW}${ICON_TOK_SUM} ${R} (total: ${INPUT_TOK_FMT}/${OUTPUT_TOK_FMT}${turn_str})"
    TOK_DETAILS_MED=" (${CTX_USED_FMT}/${CTX_LIMIT_FMT})"
  fi
fi

# --- Quota formatting ------------------------------------------------------------------
format_reset_time() {
  local sec=$1
  if [ -z "$sec" ] || [ "$sec" -le 0 ]; then
    echo -n ""
    return
  fi

  local days=$((sec / 86400))
  local rem=$((sec % 86400))
  local hours=$((rem / 3600))
  rem=$((rem % 3600))
  local mins=$((rem / 60))

  if [ "$days" -gt 0 ]; then
    if [ "$hours" -gt 0 ]; then
      echo -n "${days}d${hours}h"
    else
      echo -n "${days}d"
    fi
  elif [ "$hours" -gt 0 ]; then
    if [ "$mins" -gt 0 ]; then
      echo -n "${hours}h${mins}m"
    else
      echo -n "${hours}h"
    fi
  elif [ "$mins" -gt 0 ]; then
    echo -n "${mins}m"
  else
    echo -n "<1m"
  fi
}

make_quota_bar() {
  local val=$1
  local label=$2
  local bar_color=$3
  local reset_sec=$4
  
  local reset_label=" ${ICON_RESET} "
  local separator=""
  if [ "$USE_CLASSIC_ICONS" = "true" ]; then
    separator="${FG_GRAY} · ${R}"
  else
    separator="${FG_GRAY}| ${R}"
  fi
  
  if [ -z "$val" ] || [[ "$val" == -* ]]; then
    local bar=""
    for ((i = 0; i < 20; i++)); do
      if [ "$USE_CLASSIC_ICONS" = "true" ]; then
        bar="${bar}·"
      else
        bar="${bar}░"
      fi
    done
    echo -n "${separator}${FG_BRIGHT_WHITE}${label}${R} ${FG_GRAY}${bar} N/A${R}"
    return
  fi

  local val_int=${val%.*}
  val_int=${val_int:-0}
  
  local text_color="$FG_BRIGHT_GREEN"
  if [ "$val_int" -lt 20 ]; then
    text_color="$FG_BRIGHT_RED"
  elif [ "$val_int" -lt 50 ]; then
    text_color="$FG_BRIGHT_YELLOW"
  fi

  local bar_len=12
  local filled=$((val_int * bar_len / 100))
  local remainder=$(( (val_int * bar_len) % 100 ))
  
  local bar=""
  for ((i = 0; i < bar_len; i++)); do
    if [ "$i" -lt "$filled" ]; then
      if [ "$USE_CLASSIC_ICONS" = "true" ]; then
        bar="${bar}█"
      else
        bar="${bar}${bar_color}█${R}"
      fi
    elif [ "$i" -eq "$filled" ]; then
      if [ "$USE_CLASSIC_ICONS" = "true" ]; then
        if [ "$remainder" -ge 75 ]; then bar="${bar}▓"
        elif [ "$remainder" -ge 50 ]; then bar="${bar}▒"
        elif [ "$remainder" -ge 25 ]; then bar="${bar}░"
        else                               bar="${bar}·"
        fi
      else
        if [ "$remainder" -ge 75 ]; then
          bar="${bar}${bar_color}▓${R}${FG_GRAY}"
        elif [ "$remainder" -ge 50 ]; then
          bar="${bar}${bar_color}▒${R}${FG_GRAY}"
        elif [ "$remainder" -ge 25 ]; then
          bar="${bar}${bar_color}░${R}${FG_GRAY}"
        else
          bar="${bar}${FG_GRAY}░${R}"
        fi
      fi
    else
      if [ "$USE_CLASSIC_ICONS" = "true" ]; then
        bar="${bar}·"
      else
        bar="${bar}${FG_GRAY}░${R}"
      fi
    fi
  done

  local reset_str=""
  if [ -n "$reset_sec" ] && [ "$reset_sec" -gt 0 ]; then
    reset_str="${reset_label}$(format_reset_time "$reset_sec")"
  fi

  if [ "$USE_CLASSIC_ICONS" = "true" ]; then
    echo -n "${separator}${FG_BRIGHT_WHITE}${label}${R} ${bar_color}${bar}${R} ${text_color}${val}%${FG_GRAY}${reset_str}${R}"
  else
    echo -n "${separator}${FG_BRIGHT_WHITE}${label}${R} ${bar} ${text_color}${val}%${FG_GRAY}${reset_str}${R}"
  fi
}

# --- Determine active quota based on actual availability -------------------------------
if [ "$MODEL_GEMINI" = true ]; then
  Q_5H="$GEMINI_5H"
  Q_WK="$GEMINI_WK"
  Q_5H_R="$GEMINI_5H_RESET"
  Q_WK_R="$GEMINI_WK_RESET"
else
  Q_5H="$TP_5H"
  Q_WK="$TP_WK"
  Q_5H_R="$TP_5H_RESET"
  Q_WK_R="$TP_WK_RESET"
fi

# Fallback to -1 if variables are empty or unset
[ -z "$Q_5H" ] && Q_5H="-1"
[ -z "$Q_WK" ] && Q_WK="-1"
[ -z "$Q_5H_R" ] && Q_5H_R="-1"
[ -z "$Q_WK_R" ] && Q_WK_R="-1"

QUOTA_FMT=""
if { [ -n "$Q_5H" ] && [ "$Q_5H" != "-1" ]; } || { [ -n "$Q_WK" ] && [ "$Q_WK" != "-1" ]; }; then
  QUOTA_FMT="$(make_quota_bar "${Q_5H}" "5H" "${MODEL_COLOR}" "${Q_5H_R}") $(make_quota_bar "${Q_WK}" "7D" "${MODEL_COLOR}" "${Q_WK_R}")"
fi

# --- Right-align helper ----------------------------------------------------------------
# Prints LINE1 left-aligned and LINE2 right-aligned on the same terminal row.
print_right_aligned() {
  local left="$1"
  local right="$2"
  local total_cols="$3"

  local left_vis right_vis pad
  left_vis=$(visible_len "$left")
  right_vis=$(visible_len "$right")

  # How many spaces needed between left and right
  pad=$(( total_cols - left_vis - right_vis ))
  [ "$pad" -lt 1 ] && pad=1

  printf "%b%*s%b\n" "$left" "$pad" "" "$right"
}

# --- Output Assembly -------------------------------------------------------------------
if [ "$COLS" -ge 180 ]; then
  LINE1="${S}${M}${CLI_VER_FMT}${USER_FMT}${HOST_FMT}${DIR_FMT}${V}${CONV_FMT}"

  if [ -n "$QUOTA_FMT" ]; then
    LINE2="${ART_FMT}${DOT_L2}${SUB_FMT}${DOT_L2}${BG_FMT}${DOT_L2}${SB_FMT}${DOT_L2}${CTX_BAR}${TOK_DETAILS_WIDE}${QUOTA_FMT}${POWER_FMT}"
  else
    LINE2="${ART_FMT}${DOT_L2}${SUB_FMT}${DOT_L2}${BG_FMT}${DOT_L2}${SB_FMT}${DOT_L2}${CTX_BAR}${TOK_DETAILS_WIDE}${POWER_FMT}"
  fi
  print_right_aligned "$LINE1" "$LINE2" "$COLS"

elif [ "$COLS" -ge 90 ]; then
  # Medium Layout: Two-line layout with border
  LINE1="${S}${M}${CLI_VER_FMT}${USER_FMT}${DIR_FMT}${V}"
  if [ -n "$QUOTA_FMT" ]; then
    LINE2=" ${CTX_BAR}${TOK_DETAILS_MED}${DOT_L2}${ART_FMT}${DOT_L2}${SUB_FMT}${DOT_L2}${BG_FMT}${DOT_L2}${SB_FMT}${QUOTA_FMT}${POWER_FMT}"
  else
    LINE2=" ${CTX_BAR}${TOK_DETAILS_MED}${DOT_L2}${ART_FMT}${DOT_L2}${SUB_FMT}${DOT_L2}${BG_FMT}${DOT_L2}${SB_FMT}${POWER_FMT}"
  fi

  echo -e "${FG_GRAY}╭─${R}${LINE1}"
  echo -e "${FG_GRAY}╰─${R}${LINE2}"

else
  M_SHORT=""
  if [ -n "$MODEL_DISP" ]; then
    if [ "$USE_CLASSIC_ICONS" = "true" ]; then
      M_SHORT="${FG_GRAY} ╱ ${FG_BRIGHT_MAGENTA}${MODEL_DISP:0:12}${R}"
    else
      M_SHORT="${FG_GRAY} ╱ ${FG_BRIGHT_MAGENTA}${ICON_MODEL} ${MODEL_DISP:0:12}${R}"
    fi
  fi

  echo -e "${S}${M_SHORT}"
  if [ -n "$QUOTA_FMT" ]; then
    echo -e "${CTX_BAR}${DOT_L2}${BG_FMT}${QUOTA_FMT}${POWER_FMT}"
  else
    echo -e "${CTX_BAR}${DOT_L2}${BG_FMT}${POWER_FMT}"
  fi
fi
