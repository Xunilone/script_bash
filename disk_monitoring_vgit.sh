#!/bin/bash
#Utilisation de mailersend pour envoyer des mails d'alerte

API_KEY="your_API_KEY"
EMAIL="DESTINATION_EMAIL"
SENDER_EMAIL="SENDER_EMAIL_FRO"
SENDER_NAME="SENDER_NAME"
THRESHOLD=90 #seuil de déclenchement de l'alerte en %

#fonction pour envoyer un mail d'alerte
send_email_alert() {

        PARTITION=$1
        USAGE=$2
        SUBJECT="Alerte d'espace disque sur $PARTITION"
        BODY="L'espace disque sur la partition $PARTITION est utilisé à $USAGE%. Merci de libérer de l'espace disque."

        JSON_DATA=$(jq -n \
                                    --arg email "$SENDER_EMAIL" \
                                    --arg name "$SENDER_NAME" \
                                    --arg toEmail "$EMAIL" \
                                    --arg subject "$SUBJECT" \
                                    --arg html "$BODY" \
                                    '{
                                        "from": {"email": $email, "name": $name},
                                        "to": [{"email": $toEmail}],
                                        "subject": $subject,
                                        "html": $html
                                    }')

        curl -X POST https://api.mailersend.com/v1/email \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d "$JSON_DATA"
}

# Fonction pour vérifier l'espace disque
check_disk_space() {
    
    df -h | grep '/dev' | while read -r line; do
        
        USAGE=$(echo $line | awk '{print $5}' | sed 's/%//')
        PARTITION=$(echo $line | awk '{print $1}')
        if [ $USAGE -ge $THRESHOLD ]; then
            send_email_alert $PARTITION $USAGE
            echo "Alerte envoyée pour la partition $PARTITION"   
        fi
    done

}

check_disk_space
echo "Vérification de l'espace disque terminée"