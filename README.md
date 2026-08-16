# Baxnaano Hospital Management System (HMS)

Nidaam isku-dheelli-tiran oo isla-shaqeeya: Cashier/Reception, Doctor,
Lab, iyo Pharmacy — hal file HTML ah, oo hadda ku xidhan Supabase
(table-yo dhab ah oo relational ah — maahan hal blob) si device-yada
oo dhan ay isla wadaagaan xogta si toos ah (multi-device real-time
sync).

## Waxa ku jira ZIP-kan

| Fayl | Faahfaahin |
|---|---|
| `index.html` | Nidaamka oo dhan — fur browser-ka gudihiisa, wax lama rakibo. Wuxuu si toos ah ugu qorayaa/akhriyaa **table-yada relational-ka ah** (patients, appointments, prescriptions, iwm) — maahan hal "key/value blob". |
| `supabase_schema.sql` | SQL-ka LAGAMA MAARMAANKA AH — abuuraya 17 table (patients, appointments, prescriptions+items, lab_requests+tests+results, pharmacy/lab products+sales, followups, expenses) + RLS + Realtime. **Waa inaad run garaysaa kani marka hore.** |
| `supabase_setup.sql` | (Legacy — dib u looma baahna) Table-kii hore ee `bax_app_data`. Nidaamku hadda ma isticmaalo — waxaad iska tuuri kartaa Supabase gudihiisa haddii aad rabto. |
| `.env` | Diiwaanka qiimayaasha Supabase (URL + Key) — halka reference/backup ah. |

## Sida Nidaamku u Shaqeeyo (Architecture)

Bukaan kasta, ballan kasta, dawo kasta, iyo iib kasta waxay ku jiraan
**table gaar ah oo SQL ah** — sida nidaam HMS oo dhab ah. Tusaale:

- `patients` — bukaannada
- `appointments` — ballamaha (isku xiran `patients` via `patient_id`)
- `prescriptions` + `prescription_items` — dawooyinka dhakhtarku qoro
- `lab_requests` + `lab_request_tests` + `lab_request_results` — baaritaanada shaybaarka
- `pharmacy_products` / `pharmacy_sales` — alaabta iyo iibka farmashiga
- `lab_products` / `lab_sales` — alaabta iyo iibka shaybaarka
- `followups`, `expenses` — la-soo-noqoshada iyo kharashaadka

Marka mid ka mid ah wax keydiyo (ballan, iib, bukaan), si toos ah
ayaa loo qoraa table-ga saxda ah, dabadeedna **Realtime** ayaa
u dirta dhammaan device-yada kale isbeddelkaas — kuwa kale si toos
ah ayay u arki doonaan (ma baahna refresh).

## Tallaabooyinka Bilowga (marka hore kaliya)

1. Aad Supabase.com → project-kaaga.
2. Fur **SQL Editor** → **New query**.
3. Ku dheji dhammaan SQL-ka `supabase_schema.sql` → riix **Run**.
4. Fur `index.html` — wax dheeraad ah looma baahno, Supabase-ku horay
   ayuu u xidhan yahay.

## Sida loo isticmaalo dhowr Device (Kombuyuutar/Mobile)

- Kombuyuutarka/mobile-ka kasta, `index.html` isla file-kan ku fur.
- Marka mid ka mid ah wax keydiyo, kuwa kale si toos ah ayay u arki
  doonaan (Realtime sync).
- Haddii internet la waayo, nidaamku wuu sii shaqeynayaa (local-only)
  — marka internet-ku soo noqdo, wuu isla sameeyaa (sync) mar kale.
- **Badge-ka "Sync"** ee topbar-ka sare (🟢/🔴/⚪) wuxuu ku tusayaa
  xaaladda xidhiidhka — riix si aad u tijaabiso.

## Login-yada Default-ka ah

| Username | Password | Doorka |
|---|---|---|
| `admin` | `admin123` | Admin (dhammaan modules + reports) |
| `reception` | `reception123` | Reception/Cashier |
| `lab` | `lab123` | Lab |
| `pharmacy` | `pharmacy123` | Pharmacy |
| `dr.harith` | `doctor123` | Doctor — Dr. Harith Abdulkadir Sheikh Mohamud |
| `dr.yahye` | `doctor123` | Doctor — Dr. Yahye Shoole |
| `dr.hersi` | `doctor123` | Doctor — Dr. Hersi |

**Muhiim:** Fadlan beddel password-yadan default-ka ah marka hore.

## Talooyin

- Doorka **admin** wuxuu leeyahay awood buuxa laakiin **ma bedeli
  karo** diiwaanka caafimaad ee dhakhtarada (view-only oversight).
- Dhakhtar kasta wuxuu arkaa **kaliya bukaannadiisa**.
- SQL reports/queries toos ah waad ka sameyn kartaa Supabase SQL
  Editor-ka (tusaale: `select * from v_daily_revenue;`).

&copy; 2026 Baxnaano Medical Systems

