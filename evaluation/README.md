# Live-Evaluation (anonym, ohne Speicherung)

- `index.html` – Lehrkraft: Seite öffnen, „Neue Runde starten“; Teilnehmende scannen den QR-Code.
- `config.js` – Fragen (Skala 1–5 oder Ja/Nein) hier ändern.
- `lib/` – PeerJS (MIT) und qrcode-generator (MIT), lokal eingebunden.

Antworten gehen direkt (WebRTC) vom Handy an das geöffnete Lehrkraft-Fenster. Es gibt keine Datenbank; beim Schließen des Fensters sind alle Daten weg.
