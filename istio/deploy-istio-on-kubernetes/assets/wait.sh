#!/bin/bash

show_progress()
{
  echo -n "Starting k8s cluster"
  local -r pid="${1}"
  local -r delay='0.75'
  local spinstr='\|/-'
  local temp

  while true; do 
    sudo grep -i "there" /root/hello &> /dev/null
    if [[ "$?" -ne 0 ]]; then     
      temp="${spinstr#?}"
      printf " [%c]  " "${spinstr}"
      spinstr=${temp}${spinstr%"${temp}"}
      sleep "${delay}"
      printf "\b\b\b\b\b\b"
    else
      break
    fi
  done
  printf "    \b\b\b\b"
  echo ""
  echo "Running"
}

show_progress