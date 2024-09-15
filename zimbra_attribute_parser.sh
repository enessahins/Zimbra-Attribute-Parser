#!/bin/bash

# Girdi dosyasını tanımlayın
input_file="/opt/zimbra/log/ldap-audit.log"

# Satır numarasını takip etmek için bir değişken
modify_start=false

# Geçici değişkenler
block=""
block_number=1

# Anlık güncellenen dosyayı takip et
tail -f "$input_file" | while IFS= read -r line
do
  # '# modify' ile başlayan satırı yakala
  if [[ $line =~ ^#\ modify ]]; then
    modify_start=true
    block="$line"
  elif [[ $line =~ ^#\ end\ modify ]]; then
    modify_start=false
    block="$block"$'\n'"$line"

    # İçermesi gereken anahtar kelimeyi kontrol et
    if echo "$block" | grep -q "zimbraMailForwardingAddress:"; then
      echo -e "Blok $block_number:"
      echo -e "$block"
      echo ""
    fi

    block=""
    block_number=$((block_number+1))
  elif [ "$modify_start" = true ]; then
    # Aradaki satırları al
    block="$block"$'\n'"$line"
  fi
done
