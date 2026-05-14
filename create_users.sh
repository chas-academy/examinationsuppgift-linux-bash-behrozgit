#!/bin/bash

# --- Grundstruktur och Behörighet (20p) ---

# Kontrollera att scriptet körs av root (EUID 0)
if [ "$EUID" -ne 0 ]; then
    echo "Fel: Du måste vara root (Superuser) för att köra detta script."
    exit 1
fi

# Säkerställ att minst ett argument (användarnamn) skickas in
if [ "$#" -eq 0 ]; then
    echo "Användning: $0 <användare1> <användare2> ..."
    exit 1
fi

# --- Användarskapande (20p) ---

# Loopa igenom varje argument (varje användarnamn) i listan "$@"
for USERNAME in "$@"; do
   
    # Kolla först om användaren redan finns i systemet för att undvika fel
    if id "$USERNAME" &>/dev/null; then
        echo "Information: Användaren '$USERNAME' finns redan. Hoppar över."
        continue
    fi
   
    # Skapa användaren och generera en standard-hemkatalog (-m)
    useradd -m "$USERNAME"
    echo "Skapade användaren: $USERNAME"

    # Definiera sökvägen till den nya användarens hemkatalog
    HOMEDIR="/home/$USERNAME"

    # --- Katalogstruktur och Rättigheter (20p) ---

    # Skapa de begärda undermapparna i användarens hemkatalog
    mkdir -p "$HOMEDIR/Documents" "$HOMEDIR/Downloads" "$HOMEDIR/Work"

    # Sätt användaren som ägare till de nya mapparna
    # (Viktigt eftersom de annars ägs av root som kör scriptet)
    chown -R "$USERNAME:$USERNAME" "$HOMEDIR/Documents" "$HOMEDIR/Downloads" "$HOMEDIR/Work"

    # Sätt rättigheterna så att ENDAST ägaren kan läsa, skriva och öppna mapparna (chmod 700)
    chmod 700 "$HOMEDIR/Documents" "$HOMEDIR/Downloads" "$HOMEDIR/Work"

    # --- Välkomstmeddelande (20p) ---
   
    WELCOME_FILE="$HOMEDIR/welcome.txt"

    # Skapa filen och lägg till den första raden med välkomstmeddelandet
    echo "Välkommen $USERNAME" > "$WELCOME_FILE"
    echo "----------------------------------------" >> "$WELCOME_FILE"
    echo "Andra användare som finns i systemet:" >> "$WELCOME_FILE"

    awk -F: -v user="$USERNAME" '$1 != user {print $1}' /etc/passwd >> "$WELCOME_FILE"

    # Se till att användaren äger sin välkomstfil och endast hen kan läsa/ändra den
    chown "$USERNAME:$USERNAME" "$WELCOME_FILE"
    chmod 600 "$WELCOME_FILE"

done

echo "Klar! Alla användare är skapade och konfigurerade."
