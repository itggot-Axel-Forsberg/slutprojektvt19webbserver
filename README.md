# slutprojektvt19webbserver

# Projektplan

## 1. Projektbeskrivning
Jag tänker göra en sorts webbshop. Webbshoppen ska inrikta sig på datordelar och datortillbehör. Du ska kunna köpa prudukter och beställa och slutföra orders på sidan.
## 2. Vyer (sidor)
Först ska jag ha en hemsida där man kan välja de olika produkter som finns tillgängliga på hemsidan där man också kan lägga till produkterna i en order om man är inloggad. Jag ska såklart ha en register och en inloggningssida. Jag ska ha en profilsida där man bland annat kan se sina orders och man kan ta bort orders.
## 3. Funktionalitet (med sekvensdiagram)
Funktionerna som sidan har är: skapa orders, lägga till produkter i orders, slutföra orders, logga in och skapa konto. Jag har också en funktion som kan ta bort en existerande produkt i en aktiv order och en annan som tar bort en existerande order. Sidan ska också kolla om du är inloggad och ge dig olika behörigheter om du är inloggad eller ej.Jag ska göra detta genom att säkra sidor där man behöver vara inloggad så att man endast kan komma in på dem om man är inloggad. Den ska också använda MVC för att separera upp interaktioner med databas och interaktioner med klientem.
(Sekvensdiagram ska infogas)
## 4. Arkitektur (Beskriv filer och mappar)
Jag har dessa mappar mappar: 
db, som innehåller databasen; 
misc, som innehåller övriga bilder som exempelvis ER-diagram; public, som innehåller saker som användaren kan komma åt som exempelvis css och img filer;
css, ligger inuti public och innehåller css filer till sidan;
img, ligger inuti public och innehåller bilder som exempelvis profilbilder eller bilder på produkter;
views, som innehåller alla delsidor som sidan har;

Dessa filer finns:
store.db, som finns inuti db och innehåller all information som sparas på sidan;
main.css, som finns inuti css och innehåller css kod som ändrar utseende på sidan;
cart.slim, som innehåller cartsidan som visar användarens aktiva order om den har en;
checkout.slim, som innehåller ett formulär som kan slutföra ens aktiva order;
error403.slim, som visar ett errormeddelande och denna visas då användaren inte är inloggad och försöker gå in på en säkrad sida;
index.slim, som innehåller hemsidan där man kan logga in, gå till storesidan eller sin profilsida om man är inloggad;
layout.slim, som innehåller en header och en yield som stoppar in texten från de andra slimfilerna. Det som står i denna visas därför på alla delsidor;
login.slim, innehåller ett formulär där man kan logga in och skickar ett errormeddelande om du skriver in fel;
profile.slim, innehåller alla användarens orders och funktionen att ta bort orders;
register.slim, innehåller ett formulär där man kan registrera ett konto och errormmeddelande om du skriver in fel;
store.slim, som visar produkter som kan köpas på sidan och funktion där man kan lägga till en mängd av produkter i en order;
controller.rb, som innehåller kod som interagerar med klienten;
model.rb, som innehåller kod som interagerar med databasen;

## 5. (Databas med ER-diagram)
