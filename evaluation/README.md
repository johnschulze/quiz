# Live-Evaluation (anonym, mit Supabase)

- `index.html` – Lehrkraft: Seite öffnen, „Neue Runde starten“; Schüler scannen den QR-Code.
- `config.js` – Zugangsdaten (öffentlicher Supabase-Schlüssel) und Fragen (Skala 1–5 oder Ja/Nein).
- `supabase.sql` – Datenbank-Schema, einmal im Supabase-SQL-Editor ausführen.
- `lib/qrcode.js` – qrcode-generator (MIT).

Es werden keine Namen abgefragt. Direkter Tabellenzugriff ist gesperrt, die Seite ruft nur die Funktionen aus `supabase.sql` auf. Räume und Antworten werden nach 24 Stunden automatisch gelöscht.
