// Einstellungen und Fragen der Evaluation – hier anpassen.
//
// supabaseUrl / supabaseKey: Project URL und öffentlicher Schlüssel ("anon" bzw. "publishable")
// aus Supabase unter Project Settings → API. Dieser Schlüssel ist für die Veröffentlichung
// gedacht. NIEMALS den "service_role"- oder "secret"-Schlüssel oder das Datenbank-Passwort eintragen.
//
// type "scale": Skala 1–5 (low = Beschriftung für 1, high = Beschriftung für 5)
// type "yesno": Ja/Nein
// Die Fragen-IDs (q1, q2, …) müssen im Format q + Zahl bleiben.
const CONFIG = {
  supabaseUrl: "https://lzkvrlcyxcugryzbbpou.supabase.co",
  supabaseKey: "sb_publishable_qIhY6NW3nR0ZMWsl6PRT_g_dT7nlZL-",
  title: "Evaluation (Beispiel)",
  intro: "Ihre Antworten sind anonym. Es wird kein Name abgefragt, und die Antworten werden nach 24 Stunden gelöscht.",
  questions: [
    { id: "q1", type: "scale", text: "Die Erklärungen im Unterricht sind für mich verständlich.", low: "trifft nicht zu", high: "trifft voll zu" },
    { id: "q2", type: "scale", text: "Das Arbeitstempo im Unterricht ist für mich …", low: "viel zu langsam", high: "viel zu schnell" },
    { id: "q3", type: "yesno", text: "Ich traue mir zu, die Inhalte der letzten Wochen selbstständig anzuwenden." },
    { id: "q4", type: "yesno", text: "Ich hätte gern mehr Zeit für Übungen im Unterricht." },
    { id: "q5", type: "scale", text: "Insgesamt bin ich mit dem Unterricht zufrieden.", low: "gar nicht", high: "sehr" }
  ]
};
