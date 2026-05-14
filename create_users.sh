#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Fel: Du måste vara root för att köra detta script."
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "Användning: $0 användare1 användare2 ..."
    exit 1
fi

for USERNAME in "$@"
do
    if id "$USERNAME" &>/dev/null; then
        echo "Användaren $USERNAME finns redan."
        continue
    fi

    useradd -m "$USERNAME"

    HOME_DIR="/home/$USERNAME"

    mkdir -p "$HOME_DIR/Documents"
    mkdir -p "$HOME_DIR/Downloads"
    mkdir -p "$HOME_DIR/Work"

    chown -R "$USERNAME:$USERNAME" "$HOME_DIR"
    chmod 700 "$HOME_DIR/Documents"
    chmod 700 "$HOME_DIR/Downloads"
    chmod 700 "$HOME_DIR/Work"

    WELCOME_FILE="$HOME_DIR/welcome.txt"

    echo "Välkommen $USERNAME" > "$WELCOME_FILE"
    echo "" >> "$WELCOME_FILE"
    echo "Andra användare i systemet:" >> "$WELCOME_FILE"

    cut -d: -f1 /etc/passwd | grep -v "^$USERNAME$" >> "$WELCOME_FILE"

    chown "$USERNAME:$USERNAME" "$WELCOME_FILE"
    chmod 600 "$WELCOME_FILE"

    echo "Användaren $USERNAME skapades."
done
