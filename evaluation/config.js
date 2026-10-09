// Fragen der Evaluation – hier anpassen.
// type "scale": Skala 1–5 (low = Beschriftung für 1, high = Beschriftung für 5)
// type "yesno": Ja/Nein
const CONFIG = {
  title: "Evaluation (Beispiel)",
  intro: "Ihre Antworten sind anonym. Es werden weder Ihr Name noch Ihr Gerät gespeichert.",
  questions: [
    { id: "q1", type: "scale", text: "Die Erklärungen im Unterricht sind für mich verständlich.", low: "trifft nicht zu", high: "trifft voll zu" },
    { id: "q2", type: "scale", text: "Das Arbeitstempo im Unterricht ist für mich …", low: "viel zu langsam", high: "viel zu schnell" },
    { id: "q3", type: "yesno", text: "Ich traue mir zu, die Inhalte der letzten Wochen selbstständig anzuwenden." },
    { id: "q4", type: "yesno", text: "Ich hätte gern mehr Zeit für Übungen im Unterricht." },
    { id: "q5", type: "scale", text: "Insgesamt bin ich mit dem Unterricht zufrieden.", low: "gar nicht", high: "sehr" }
  ]
};
