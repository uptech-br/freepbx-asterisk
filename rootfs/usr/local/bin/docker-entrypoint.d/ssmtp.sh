# shellcheck shell=bash

write_ssmtp_ini() {
  cat <<EOF > /etc/ssmtp/ssmtp.conf
root=${MAIL_FROM_ADDRESS-pbx@uptech.com.br}
hostname=${MAIL_DOMAIN-uptech.com.br}
mailhub=${SMTP_HOST}:${SMTP_PORT-587}
AuthUser=${SMTP_NAME}
AuthPass=${SMTP_PASSWORD}
UseTLS=YES
UseSTARTTLS=YES
FromLineOverride=YES
EOF
}
