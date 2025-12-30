#!/usr/bin/env bash

set -eo pipefail

scrDir="$(dirname "$(realpath "$0")")"
if [[ ! "${scrDir}/globalfunction.sh" ]]; then
  echo "n\Something went wrong to '${scrDir}/globalfunction.sh'"
else
  echo "n\Sourcing Global Variable"
fi
[[ -e ${scrDir}/globalfunction.sh ]] && source "${scrDir}/globalfunction.sh"

if [[ $EUID -eq 0 ]]; then
  echo "${IndentError} This script should ${indentWarning} NOT ${indentReset} be executed as root!!"
  printf "\n%.0s" {1..2}
  exit 1
fi

if grep -iqE '(ID|ID_LIKE)=.*(arch)' /etc/os-release >/dev/null 2>&1; then
  echo ${indentOk} "Arch Linux Detected"
  while true; do
    read -p "$(echo -n "${indentAction} Do you want to install anyway? (y/n): ")" check
    case ${check} in
      y|yes)
        echo "${indentNotice} Proceeding on Arch Linux by user confirmation."
        break
        ;;
      n|no|"")
        echo "${indentError} Aborting installation due to user choice. No changes were made."
        exit 0
        ;;
      *)
        echo "${indentError} Please answer 'y' or 'n'."
        ;;
    esac
  done
fi

if [[ -d "${cloneDir}/${aurRp}" ]]; then
  echo -n "${indentAction} AUR exists '${cloneDir}/${aurRp}'...."
  while true; do
    read -p "$(echo -n "${indentAction} Do you want to remove the directory? (y/n): ")" check1
    case ${check1} in
      Y|y)
        var=$(stat -c '%U' ${cloneDir}/${aurRp})
        var1=$(stat -c '%U' ${cloneDir}/${aurRp}/PKGBUILD)
        if [[ $var = $USER ]] && [[ $var1 = $USER ]]; then
          echo -n "${indentAction} Removing..."
          rm -rf "${cloneDir}"
          break
        elif [[ $var = root ]] && [[ $var1 = root ]]; then
          echo "${indentWarning} The file has ${indentWarning}root${indentWarning} ownership!!! Manual intervention required - ${indentError} Code: 1"
        fi
        ;;
      N|n)
        read -p "$(echo -n "${indentAction} !!!? Would you like to use that folder instead? (y/n): ")" check2
        case ${check2} in
          Y|y)
            if [[ -e "${cloneDir}/${aurRp}/PKGBUILD" ]]; then
              (cd "${cloneDir}/${aurRp}/" && makepkg -si)
              break
            else
              echo "${indentWarning} !!! Something went ${indentWarning}wrong${indentWarning} in our side..."
              var=$(stat -c '%U' ${cloneDir}/${aurRp})
              var1=$(stat -c '%U' ${cloneDir}/${aurRp}/PKGBUILD)
              if [[ $var = $USER ]] && [[ $var1 = $USER ]]; then
                echo "${indentAction} Retrying the script"
              elif [[ $var = root ]] && [[ $var1 = root ]]; then
                echo "${indentInfo} The folder has ${indentWarning}root${indentWarning} ownership. Manual intervention required - ${indentError} Code: 1"
              fi
            fi
            ;;
          N|n)
            var=$(stat -c '%U' ${cloneDir}/${aurRp})
            var1=$(stat -c '%U' ${cloneDir}/${aurRp}/PKGBUILD)
            if [[ $var = $USER ]] && [[ $var1 = $USER ]]; then
              echo -n "${indentAction} Removing..."
              rm -rf "${cloneDir}"
            elif [[ $var = root ]] && [[ $var1 = root ]]; then
              echo "${indentError} The file has ${indentWarning}root${indentWarning} ownership!!! ${indentError} Code: 1"
            fi
            ;;
          *)
            echo "${indentError} Please answer 'y' or 'n'."
            ;;
        esac
        ;;
      *)
        echo "${IndentError} Please answer 'y' or 'n'."
        ;;
    esac
  done
else
  mkdir -p ${cloneDir}
fi

if [[ "${check}" = "Y" ]] || [[ ${check} = "y" ]]; then
  if [[ -d "${cloneDir}/cachyos-repo" ]] || [[ -d "${cloneDir}/${cachyRp}" ]]; then
    prompt_timer 120 "${indentAction} Would you like to delete the repository?"
    case "$PROMPT_INPUT" in
      Y|y)
        echo "${indentNotice} Deleting ${indentGreen}the Repository"
        rm -rf ${cloneDir}/${cachyRp}
        rm -rf ${cloneDir}/cachyos-repo
        ;;
      N|n|*)
        read -p "$(echo -ne "${indentNotice} Would you like to rather use the repository? (y/n) ")" rpcheck
        case "$rpcheck" in
          y|Y)
            if [[ -d "${cloneDir}/cachyos-repo" ]]; then
              sudo bash "${cloneDir}/cachyos-repo/cachyos-repo.sh"
            elif [[ -d "${cloneDir}/${cachyRp}" ]]; then
              tar -xvf "${cloneDir}/${cachyRp}" -C "${cloneDir}"
              sudo bash "${cloneDir}/cachyos-repo/cachyos-repo.sh"
            fi
            ;;
          n|N|""|*)
            echo "${indentNotice} Deleting {indenGreen}the repository."
            rm -rf ${cloneDir}/${cachyRp}
            rm -rf ${cloneDir}/cachyos-repo
            ;;
        esac
        ;;
    esac
  else
    read -p "$(echo "${indentNotice} It is generally recommended for this repository to have cachyos-repository. However, it is completely optional. Would you like to get cachyos-repository? (y/n): ")" check3
    check3="${check3,,}"
    case "$check3" in
      y|Y)
        curl "https://mirror.cachyos.org/${cachyRp}" -o "${cloneDir}/${cachyRp}"
        tar xvf "${cloneDir}/${cachyRp}" -C "${cloneDir}"
        sudo bash "${cloneDir}/cachyos-repo/cachyos-repo.sh"
        echo -ne "${indentOk} Repository has been ${indentGreen}installed${indentGreen} successfully."
        ;;
      n|N|""|*)
        echo -ne "${indentReset} Aborting installation due to user preference."
        ;;
    esac 
  fi
fi

if [[ $check = "Y" ]] || [[ $check = "y" ]]; then
  prompt_timer 120 "${indentAction} Would you like to install yay?"

  case "$PROMPT_INPUT" in
    [Yy]*)
      git clone "https://aur.archlinux.org/${aurRp}.git" "${cloneDir}/${aurRp}"
      var=$(stat -c '%U' "${cloneDir}/${aurRp}")
      var1=$(stat -c '%U' "${cloneDir}/${aurRp}/PKGBUILD")

      if [[ $var = "$USER" ]] && [[ $var1 = "$USER" ]]; then
        (cd "${cloneDir}/${aurRp}/" && makepkg -si)
      fi
      break
      ;;
    [Nn]*|""|*)
      echo "${indentReset} Aborting Installation due to user preference. ${aurRp} wasn't ${indentOrange}installed${indentOrange}."
      ;;
  esac
fi

if [[ $check = "Y" ]] || [[ $check = "y" ]]; then
  if [[ -e "${pkgsRp}" ]]; then
    if [[ $(stat -c '%U' ${pkgsRp}) = $USER ]]; then
      ${pkgsRp} --hyprland
      echo -n "${indentOk} All hyprland packages were ${indentGreen}installed${indentGreen}."
    elif [[ $(stat -c '%u' ${pkgsRp}) -eq 0 ]]; then
      echo "${indentError} The shell script has ${indentWarning}root ownership!!! ${indentWarning}Exiting${indentWarning}"
      exit 1
    fi
      prompt_timer 120 "${indentNotice} Would you like to get additional packages?"
      case "$PROMPT_INPUT" in
        [Yy]*)
          echo -n "${indentAction} Proeeding installation due to User's request."
          ${pkgsRp} --extra
          echo -n "${indentOk} All extra packages were ${indentGreen}installed${indentGreen}"
          break
          ;;
        [Nn]|*)
          echo -n "${indentAction} Avorting installation due to User Preferences."
          ;;
      esac
    prompt_timer 120 "${indentNotice} Would you also like to get driver packages (Intel only, The default is 'no' [Recommended]"
    case "$PROMPT_INPUT" in
      [Yy]*)
        echo -n "${indentAction} Proceeding installation due to User's request."
        ${pkgsRp} --driver
        echo -n "${indentAction} All driver packages were ${indentGreen}installed${indentGreen}"
        ;;
      [Nn]|*)
        echo -n "${indentReset} Avorting installation due to User Preferences."
        ;;
    esac
  else
    echo "${indentWarning} The Package DOES NOT EXIST!! ${indentError}"
  fi
fi

if [[ -d $configDir ]]; then
  if [[ $(stat -c '%U' ${configDir}) = $USER ]]; then
    echo -n "${indentOk} Populating ${confDir}"
    ${scrDir}/dircaller.sh --all ${homDir}/ 
  elif [[ $(stat -c '%u' ${configDir}) -eq 0 ]]; then
    echo -n "${indentError} The directory is owned by ${indentWarning}root! ${indentWarning}Exiting${indentWarning}!"
    exit 1
  fi
  tar -xvf ${sourceDir}/Sweet-cursors.tar.xz ${homDir}/.icons
  if [[ ! -e "${confDir}/gtk-4.0/assets" ]] || [[ ! -e "${confDir}/gtk-4.0/gtk-dark.css" ]] || [[ -L "${confDir}/gtk-4.0/assets" ]] || [[ -L "${confDir}/gtk-4.0/gtk-dark.css" ]]; then
    ln -sf /usr/share/themes/adw-gtk3/assets "${confDir}/gtk-4.0/assets" 2>&1
    ln -sf /usr/share/themes/adw-gtk3/gtk-4.0/gtk-dark.css "${confDir}/gtk-4.0/gtk-dark.css" 2>&1
    echo -ne "${indentOk} Symlink initialized."
  fi
  
  prompt_timer 120 "${indentAction} Would you like to switch to fish?"
  case $PROMPT_INPUT in
    Y|y)
      echo -n "${indentNotice} Switching the shell to fish"
      chsh -s /usr/bin/env fish
      echo -n "${indentOk} Conversion to ${indentGreen}fish${indentOrange} is completed!"
      ;;
    N|n|*|"")
      echo -n "${indentReset} Aborting due to user preference. Keeping $(echo "$SHELL") intact."
      ;;
  esac
  prompt_timer 120 "${indentYellow} Would you like to get wallpapers?"
  case "$PROMPT_INPUT" in
    Y|y)
      echo -n "${indentAction} Proceeding pulling repository due to User's repository."
      mkdir -p "${walDir}"
      if git clone --depth 1 "https://${repRp}" "${walDir}"; then
        echo "${indentOk} ${indentMagenta}wallpapers${indentReset} cloned successfully!"
      else
        echo "${indentError} Failed to clone ${indentYellow}wallpapers${indentReset}"
      fi
      ${localDir}/color-cache.sh
      echo -n "${indentOk} ${indentOrange}wallpapers${indentGreen} has been cached by ${localDir}/color-cache.sh"
      ;;
    N|n)
      prompt_timer 120 "${indentAction} Would you like to pull from another repository? [Drop the full clone link or say --skip to avoid"
      case $prompt_input in
        "")
          echo -n "${indentError} No Link was given. ${indentReset}"
          ;;
        *)
          if git clone --depth 1 "$PROMPT_INPUT" "${walDir}"; then
            echo "${indentOk} ${indentMagenta}wallpapers${indentReset} cloned successfully"
          else
            echo "${indentError} Failed to clone ${indentYellow}wallpapers${indentReset}"
          fi
          ${localDir}/color-cache.sh
          echo -n "${indentOk} ${indentOrange}wallpapers${indentGreen} has been cached by ${localDir}/color-cache.sh"
          ;;
        --skip)
          echo "${indentOk} Pulling wallpapers from source."
          if cp -r ${sourceDir}/assets/*.png "${walDir}" 2>/dev/null || cp -r ${sourceDir}/assets/*.jpg "${walDir}" 2>/dev/null; then
            echo "${indentOk} Some ${indentMagenta}wallpapers${indentReset} copied successfully!"
          else
            echo "${indentError} Failed to copy some ${indentYellow}wallpapers${indentReset}"
          ${localDir}/color-cache.sh
          echo -n "${indentOk} ${indentOrange}wallpapers${indentGreen} has been cached by ${localDir}/color-cache.sh"
          ;;
      esac
      ;;
  esac
fi

reboot

