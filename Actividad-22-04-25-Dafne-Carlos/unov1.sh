# Check if the CSV file is provided as an argument.
if [ $# -ne 1 ]; then
  echo "Uso: $0 <csv_file>"
  exit 1
fi

csv_file="$1"

if [ ! -f "$csv_file" ]; then
  echo "Error: No se encontro el CSV: '$csv_file'."
  exit 1
fi

temp_file="/tmp/hosts.temp"

echo "127.0.0.1 localhost" > "$temp_file"
echo "127.0.1.1 $(hostname)" >> "$temp_file"
echo "::1 localhost ip6-localhost ip6-loopback" >> "$temp_file"
echo "ff02::1 ip6-allnodes" >> "$temp_file"
echo "ff02::2 ip6-allrouters" >> "$temp_file"

tail -n +2 "$csv_file" | while IFS=',' read -r _ _ hostname ip_address _; do
  if [[ -n "$hostname" && -n "$ip_address" ]]; then
    if [[ "$ip_address" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
      echo "$ip_address $hostname" >> "$temp_file"
    else
      echo "Warning: La IP '$ip_address' para '$hostname' no es valida."
    fi
  else
    echo "Warning: La linea no contiene una IP o hostname."
  fi
done

if [ ! -f "$temp_file" ]; then
  echo "Error: No fue posible generar el archivo temporal."
  exit 1
fi

# Replace the /etc/hosts file with the new content.
if sudo mv "$temp_file" "/etc/hosts"; then
  echo "Se creo/actualizo /etc/hosts."
else
  echo "Error: No se pudo actualizar /etc/hosts. Tienes permisos de sudo?"
  exit 1
fi

exit 0
