-- ============================================================
-- BAXNAANO HMS — Supabase Multi-Device Sync Setup
-- ============================================================
-- Sida loo isticmaalo:
--   1. Aad Supabase.com, samee account/project cusub (bilaash ayay ku filan
--      tahay HMS yar ilaa dhexdhexaad ah).
--   2. Project-ka gudihiisa fur "SQL Editor" (bidixda) → "New query".
--   3. Ku dheji dhammaan SQL-ka hoose → riix "Run".
--   4. Aad Project Settings → API, ka koobiyee:
--        - "Project URL"       → geli SUPABASE_URL ee index.html
--        - "anon public" key   → geli SUPABASE_ANON_KEY ee index.html
--   5. index.html soo dhig/refresh — dhammaan device-yada (Reception,
--      Doctor, Lab, Pharmacy) hadda isla xog bay wadaagi doonaan.
--
-- SIDA NIDAAMKU U SHAQEEYO:
--   Habka la isticmaalay waa "key/value sync": nidaamka HTML-ka wuxuu si
--   caadi ah u isticmaalaa localStorage (si degdeg ah loo shaqeeyo,
--   xitaa internet la'aan), laakiin markasta oo xog la keydiyo, waxaa la
--   diraa (background) hal saf oo ku jira table-kan hoose. Device kale oo
--   isla project-ka Supabase isticmaala wuxuu si toos ah u helaa isbeddel-
--   kaas iyadoo la adeegsanayo "Realtime" (subscription).
-- ============================================================

-- 1) Table-ka xogta guud (hal saf = hal storage key, tusaale: bax_appointments)
create table if not exists public.bax_app_data (
  key         text primary key,
  value       jsonb not null,
  updated_at  timestamptz not null default now()
);

-- 2) Kororsiga (index) taariikhda cusboonaysiinta si reports/debugging fudud u noqoto
create index if not exists bax_app_data_updated_idx on public.bax_app_data (updated_at desc);

-- 3) Row Level Security — waajib u ah Supabase, laakiin annagu waxaan u
--    oggolaanaynaa dhammaan (anon key) inay akhriyaan/qoraan, sababtoo ah
--    nidaamkani wuxuu leeyahay login-kiisa gudaha (username/password) oo
--    ku shaqeeya app-ka dhexdiisa, ee ma aha xaqiijin heer-Supabase ah.
--    HABKAN KU FIICAN YAHAY: kaliya la wadaag SUPABASE_URL/ANON_KEY
--    shaqaalaha aad isku halayn karto — anon key-gu wuu awoodaa inuu
--    akhriyo/qoro dhammaan xogta.
alter table public.bax_app_data enable row level security;

drop policy if exists "bax_allow_select" on public.bax_app_data;
create policy "bax_allow_select" on public.bax_app_data
  for select using (true);

drop policy if exists "bax_allow_insert" on public.bax_app_data;
create policy "bax_allow_insert" on public.bax_app_data
  for insert with check (true);

drop policy if exists "bax_allow_update" on public.bax_app_data;
create policy "bax_allow_update" on public.bax_app_data
  for update using (true);

drop policy if exists "bax_allow_delete" on public.bax_app_data;
create policy "bax_allow_delete" on public.bax_app_data
  for delete using (true);

-- 4) Realtime — si device-yada kale ay "toos" ugu arkaan isbeddelka
alter table public.bax_app_data replica identity full;

-- Haddii uu horey u jiray publication-ka default-ka ah "supabase_realtime",
-- kani wuu ku darayaa table-keena; haddii ay dhaceyso khalad ah "already
-- a member" waa caadi, iska dhaaf.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and tablename = 'bax_app_data'
  ) then
    alter publication supabase_realtime add table public.bax_app_data;
  end if;
end $$;

-- ============================================================
-- DIB U DEJIN (haddii aad rabto inaad ka bilowdo bilow cusub):
--   truncate table public.bax_app_data;
-- ============================================================
