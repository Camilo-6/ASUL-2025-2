# Check if the CSV file is provided as an argument.
if [ $# -ne 1 ]; then
  echo "Usage: $0 <csv_file>"
  exit 1
fi

csv_file="$1"

# Check if the CSV file exists.
if [ ! -f "$csv_file" ]; then
  echo "Error: CSV file '$csv_file' not found."
  exit 1
fi

# Temporary file to store the new /etc/hosts content.
temp_file="/tmp/hosts.temp"

# Start with the standard /etc/hosts header.
echo "127.0.0.1 localhost" > "$temp_file"
echo "127.0.1.1 $(hostname)" >> "$temp_file"
echo "::1 localhost ip6-localhost ip6-loopback" >> "$temp_file"
echo "ff02::1 ip6-allnodes" >> "$temp_file"
echo "ff02::2 ip6-allrouters" >> "$temp_file"

# Read the CSV file, skipping the header if it exists.
tail -n +2 "$csv_file" | while IFS=',' read -r _ _ hostname ip_address _; do
  # Check if hostname and ip_address are not empty.
  if [[ -n "$hostname" && -n "$ip_address" ]]; then
    # Validate the IP address. Use a simpler check.
    if [[ "$ip_address" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
      # Append the entry to the temporary file.
      echo "$ip_address $hostname" >> "$temp_file"
    else
      echo "Warning: Invalid IP address '$ip_address' for host '$hostname'. Skipping entry."
    fi
  else
    echo "Warning: Missing hostname or IP address in CSV file. Skipping line."
  fi
done

# Check if the temporary file was created.
if [ ! -f "$temp_file" ]; then
  echo "Error: Failed to create temporary file."
  exit 1
fi

# Replace the /etc/hosts file with the new content.
if sudo mv "$temp_file" "/etc/hosts"; then
  echo "Successfully updated /etc/hosts."
else
  echo "Error: Failed to update /etc/hosts. Ensure you have sudo privileges."
  exit 1
fi

exit 0
