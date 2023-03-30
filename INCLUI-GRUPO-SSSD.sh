#!/bin/zsh
# faz backup do arquivo sssd.conf com a data e hora da execução do script

cp /etc/sssd/sssd.conf /etc/sssd/sssd.conf-$(date +%Y%m%d_%H%M%S)

# verifica se o grupo CofreAWS_Infra_admlocal existe
if getent group CofreAWS_Infra_admlocal > /dev/null; then
    echo "O grupo CofreAWS_Infra_admlocal já existe."
    exit 1
fi

# verifica se o arquivo sssd.conf existe
if [ ! -f "/etc/sssd/sssd.conf" ]; then
  echo "O arquivo /etc/sssd/sssd.conf não existe."
  exit 1
fi

# verifica se já existe a linha que contém "simple_allow_groups"
if grep -q "simple_allow_groups" "/etc/sssd/sssd.conf"; then
  # verifica se o grupo CofreAWS_Infra_admlocal já está na lista
  if grep -q "simple_allow_groups.*Domain Admins.*,.*CofreAWS_Infra_admlocal.*" "/etc/sssd/sssd.conf"; then
    echo "O grupo CofreAWS_Infra_admlocal já está na lista."
    exit 1
  fi
  # adiciona o novo grupo após "Domain Admins"
  sed -i 's/simple_allow_groups = \(.*Domain Admins.*\)$/\0,CofreAWS_Infra_admlocal/' "/etc/sssd/sssd.conf"
else
  # adiciona a linha "simple_allow_groups" e os grupos permitidos
  echo "simple_allow_groups = Domain Admins,CofreAWS_Infra_admlocal" >> "/etc/sssd/sssd.conf"
fi

# reinicia o serviço sssd
systemctl restart sssd.service


