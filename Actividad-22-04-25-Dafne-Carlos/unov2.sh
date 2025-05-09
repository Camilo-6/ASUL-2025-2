#!/bin/bash

ARCHIVO_ENTRADA="$1"
SEPARADOR_COLUMNA=','
INDICE_COL_USUARIO=5 
INDICE_COL_CLAVE=6   

if [[ -z "$ARCHIVO_ENTRADA" ]]; then
  echo "Uso: sudo $0 <archivo_entrada>"
  exit 1
fi

if [[ ! -f "$ARCHIVO_ENTRADA" ]]; then
  echo "Error: Archivo de entrada '$ARCHIVO_ENTRADA' no encontrado."
  exit 1
fi

if [[ ! -r "$ARCHIVO_ENTRADA" ]]; then
  echo "Error: Archivo de entrada '$ARCHIVO_ENTRADA' no se puede leer."
  exit 1
fi

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Error: Este script debe ejecutarse como root o con sudo."
  exit 1
fi

echo "Procesando archivo: $ARCHIVO_ENTRADA"

tr '\r' '\n' < "$ARCHIVO_ENTRADA" | while IFS= read -r registro || [[ -n "$registro" ]]; do
  if [[ -z "$registro" ]]; then
    continue
  fi

  IFS="$SEPARADOR_COLUMNA" read -r -a campos <<< "$registro"

  nombre_usuario="${campos[$INDICE_COL_USUARIO]}"
  clave_ssh="${campos[$INDICE_COL_CLAVE]}"

  if [[ -z "$nombre_usuario" ]]; then
    echo "Advertencia: Omitiendo registro - Nombre de usuario en columna $((INDICE_COL_USUARIO + 1)) esta vacio."
    continue
  fi
  if ! [[ "$nombre_usuario" =~ ^[a-z_][a-z0-9_-]*[$]?$ ]]; then
       echo "Advertencia: Omitiendo registro - Formato de nombre de usuario invalido: '$nombre_usuario'"
       continue
  fi

  if [[ -z "$clave_ssh" ]]; then
    echo "Advertencia: Omitiendo registro - Clave SSH en columna $((INDICE_COL_CLAVE + 1)) para usuario '$nombre_usuario' esta vacia."
    continue
  fi
  if ! [[ "$clave_ssh" =~ ^(ssh-(rsa|dss|ed25519)|ecdsa-sha2-nistp) ]]; then
       echo "Advertencia: Omitiendo registro - Formato de clave SSH invalido para usuario '$nombre_usuario'."
       continue
  fi


  echo "Usuario encontrado: '$nombre_usuario', Clave: '${clave_ssh:0:20}...' (truncada)" # Mostrar solo inicio de la clave

  if id -u "$nombre_usuario" >/dev/null 2>&1; then
    echo "Info: Usuario '$nombre_usuario' ya existe. Omitiendo creacion."
  else
    echo "Creando usuario '$nombre_usuario'..."
    useradd -m -s /bin/bash "$nombre_usuario"
    if [[ $? -ne 0 ]]; then
      echo "Error: Fallo la creacion del usuario '$nombre_usuario'."
      continue
    else
       echo "Usuario '$nombre_usuario' creado exitosamente."
    fi
  fi

  directorio_home="/home/$nombre_usuario"
  directorio_ssh="$directorio_home/.ssh"
  archivo_claves_autorizadas="$directorio_ssh/authorized_keys"

  echo "Configurando clave SSH para '$nombre_usuario'..."

  mkdir -p "$directorio_ssh"
  if [[ $? -ne 0 ]]; then
    echo "Error: Fallo la creacion del directorio '$directorio_ssh'."
    continue
  fi

  chown "$nombre_usuario:$nombre_usuario" "$directorio_ssh"
  chmod 700 "$directorio_ssh"
  if [[ $? -ne 0 ]]; then
    echo "Error: Fallo al establecer propietario/permisos en '$directorio_ssh'."
  fi

  if grep -qFx "$clave_ssh" "$archivo_claves_autorizadas" 2>/dev/null; then
      echo "Info: La clave ya existe en '$archivo_claves_autorizadas' para el usuario '$nombre_usuario'."
  else
      echo "$clave_ssh" >> "$archivo_claves_autorizadas"
      if [[ $? -ne 0 ]]; then
        echo "Error: Fallo al anadir la clave a '$archivo_claves_autorizadas'."
        continue
      else
         echo "Clave anadida exitosamente a '$archivo_claves_autorizadas'."
      fi
  fi


  chown "$nombre_usuario:$nombre_usuario" "$archivo_claves_autorizadas"
  chmod 600 "$archivo_claves_autorizadas"
   if [[ $? -ne 0 ]]; then
    echo "Error: Fallo al establecer propietario/permisos en '$archivo_claves_autorizadas'."
  fi

  echo "Configuracion SSH completa para '$nombre_usuario'."

done