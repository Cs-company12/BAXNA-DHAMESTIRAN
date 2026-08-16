# Baxnaano Hospital Management System (HMS)

Nidaam isku-dheelli-tiran oo isla-shaqeeya: Cashier/Reception, Doctor,
Lab, iyo Pharmacy — hal file HTML ah, oo hadda ku xidhan Supabase si
device-yada oo dhan (kombuyuutar/mobile kasta) ay isla wadaagaan xogta
si toos ah (multi-device sync).

## Waxa ku jira ZIP-kan

| Fayl | Faahfaahin |
|---|---|
| `index.html` | Nidaamka oo dhan — fur browser-ka gudihiisa, wax lama rakibo. **Supabase-ku horay ayuu ugu xidhan yahay** (URL + Key). |
| `supabase_setup.sql` | SQL-ka LAGAMA MAARMAANKA AH — abuuraya table-ka `bax_app_data` ee app-ku isticmaalo si toos ah si loo wadaago xogta device-yada dhexdooda. **Waa inaad run garaysaa kani marka hore.** |
| `supabase_schema.sql` | SQL dheeraad ah (ikhtiyaari) — abuuraya table-yo dhab ah (relational: patients, appointments, prescriptions, iwm) oo loogu talagalay SQL reports/queries toos ah. Ma aha mid uu app-ku hadda si toos ah u isticmaalo. |
| `.env` | Diiwaanka qiimayaasha Supabase (URL + Key) — halka reference/backup ah. Browser-ku si toos ah uma akhriyo fayl-kan (fiiro gaar ah fayl-ka dhexdiisa ku qoran). |

## Tallaabooyinka Bilowga (marka hore kaliya)

1. Aad Supabase.com → project-kaaga (`tpmsyyhrnciqqcxlfamr`).
2. Fur **SQL Editor** → **New query**.
3. Ku dheji dhammaan SQL-ka `supabase_setup.sql` → riix **Run**.
   *(Kani wuxuu abuurayaa table-ka `bax_app_data` ee lagama maarmaanka
   ah — haddii aadan samayn tallaabadan, multi-device sync ma shaqeyn
   doono.)*
4. (Ikhtiyaari) Haddii aad rabto SQL reports/tables dhab ah, ku dheji
   sidoo kale `supabase_schema.sql`.
5. Fur `index.html` — wax dheeraad ah looma baahna, Supabase-ku horay
   ayuu u xidhan yahay.

## Sida loo isticmaalo dhowr Device (Kombuyuutar/Mobile)

- Kombuyuutarka/mobile-ka kasta, `index.html` isla file-kan ku fur
  (browser kasta — Chrome, Safari, iwm).
- Marka mid ka mid ah wax keydiyo (ballan, iib, bukaan, iwm), kuwa kale
  si toos ah ayay u arki doonaan (Realtime sync — waxbadan majirto
  refresh-ku wuxuu isu cusboonaysiiyaa).
- Haddii internet la waayo, nidaamku wuu sii shaqeynayaa (local-only)
  — marka internet-ku soo noqdo, wuu isla sameeyaa (sync) mar kale.

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

**Muhiim:** Fadlan beddel password-yadan default-ka ah marka hore
(Users → Shaqaalaha) si loo ilaaliyo ammaanka xogta bukaannada.

## Talooyin

- Doorka **admin** wuxuu leeyahay awood buuxa laakiin **ma bedeli
  karo** diiwaanka caafimaad ee dhakhtarada (view-only oversight) —
  kaliya dhakhtarku wuu bedeli karaa xogtiisa.
- Dhakhtar kasta wuxuu arkaa **kaliya bukaannadiisa** — ma arko kuwa
  dhakhtarrada kale.
- Haddii aad u baahato caawimo dheeraad ah ama features cusub, soo
  wac session-ka Claude ee aad ku dhistay nidaamkan.

&copy; 2026 Baxnaano Medical Systems
