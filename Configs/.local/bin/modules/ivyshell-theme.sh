#!/usr/bin/env bash
set -euo pipefail

# -----------------------
# Forbid Root Execution
# -----------------------
if [[ "$EUID" -eq 0 ]]; then
  echo "ivygen must not be run as root." >&2
  exit 1
fi

# -----------------------
# Paths
# -----------------------
ivy_pp="$HOME/.config/ivy-shell/main/ivygen.dcol"
ivy_dir="$HOME/.config/ivy-shell"
ivy_plain="$ivy_dir/theme.ivy"
ivy_rgba="$ivy_dir/theme-rgba.ivy"

# -----------------------
# Read ivy colors
# -----------------------
declare -A ivy

while IFS='=' read -r key val; do
    [[ -z "$key" || -z "$val" ]] && continue
    ivy["$key"]="$val"
done < "$ivy_pp"

# -----------------------
# Generator function
# -----------------------
generate_theme() {
    local suffix="$1"        # "" or "_rgba"
    local target="$2"
    local src_suffix="$3"    # "" or "_rgba"

    local tmpfile
    tmpfile="$(mktemp)"

    {
        echo
        for block in 0 1 2 3; do
            base=$((block * 11))

            echo "ivy_pry$((block+1))${suffix}=${ivy[dcol_rrggbb_$((base+1))${src_suffix}]}"
            echo "ivy_txt$((block+1))${suffix}=${ivy[dcol_rrggbb_$((base+2))${src_suffix}]}"

            for i in {1..9}; do
                idx=$((base + i + 2))
                echo "ivy_$((block+1))xa$i${suffix}=${ivy[dcol_rrggbb_${idx}${src_suffix}]}"
            done

            echo
        done
    } > "$tmpfile"

    mv "$tmpfile" "$target"
}

# -----------------------
# Generate both themes
# -----------------------
generate_theme ""       "$ivy_plain" ""
generate_theme "_rgba" "$ivy_rgba"  "_rgba"

echo "Generated"
