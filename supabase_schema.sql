-- ============================================================
-- BAXNAANO HMS — Relational SQL Schema (Supabase / PostgreSQL)
-- ============================================================
-- Faahfaahin: Fayl-kan wuxuu abuurayaa TABLE-yo dhab ah (relational)
-- oo u dhigma qaab-dhismeedka xogta ee app-ka — bukaanka, ballamaha,
-- dawooyinka, baaritaanada shaybaarka, alaabta farmashiga/shaybaarka,
-- iibka, la-soo-noqoshada, iyo kharashaadka — halkii ay ka ahaan
-- lahaayeen hal table oo "key/value" ah (bax_app_data).
--
-- SIDEE LOO ISTICMAALAA:
--   1. Supabase SQL Editor → New query → ku dheji dhammaan SQL-kan → Run.
--   2. Fayl-kan wuxuu ISTICMAALI KARAA si madax-banaan (reports/backup/
--      SQL queries toos ah) xitaa haddii aad wali isticmaasho
--      supabase_setup.sql (bax_app_data) ee horay kuu la siiyay ee ah
--      kan uu app-ku (index.html) hadda si toos ah ugu qorayo/akhriyo
--      (real-time sync-ka device-yada dhexdooda).
--   3. Haddii aad rabto in app-ku si toos ah ugu qorto TABLE-yadan
--      (halkii uu ku qori lahaa bax_app_data blob-ka), taasi waa
--      mashruuc kale (dib-u-dhis JS-ka) — ii sheeg haddii aad rabto,
--      waan kuu sameyn karnaa tallaabo-tallaabo.
--
-- Isla habka bax_app_data (RLS + anon access + Realtime) ayaan
-- ku sii adeegsanay halkan sidoo kale, si loo hubiyo in reports-yada
-- iyo la-xiriirka SQL toos ah ay u shaqeeyaan si fudud.
-- ============================================================

-- ------------------------------------------------------------
-- 1) USERS — shaqaalaha nidaamka (admin, reception, doctor, lab, pharmacy)
-- ------------------------------------------------------------
create table if not exists public.users (
  id            text primary key,
  username      text unique not null,
  password_hash text not null,
  role          text not null check (role in ('admin','reception','doctor','lab','pharmacy')),
  doctor_name   text,
  created_at    timestamptz not null default now()
);

-- ------------------------------------------------------------
-- 2) PATIENTS — diiwaanka guud ee bukaannada
-- ------------------------------------------------------------
create table if not exists public.patients (
  id         text primary key,
  name       text not null,
  mobile     text,
  sex        text,
  age        text,
  created_at timestamptz not null default now()
);
create index if not exists idx_patients_mobile on public.patients (mobile);
create index if not exists idx_patients_name on public.patients (lower(name));

-- ------------------------------------------------------------
-- 3) APPOINTMENTS — ballamaha (Cashier/Reception + Doctor)
-- ------------------------------------------------------------
create table if not exists public.appointments (
  id             text primary key,
  appt_num       text,
  queue_num      integer default 0,
  patient_id     text references public.patients(id) on delete set null,
  patient_name   text not null,
  mobile         text,
  age            text,
  sex            text,
  patient_type   text default 'OPD',
  appt_type      text default 'New',
  department     text,
  doctor         text,
  charge_type    text,
  amount         numeric(10,2) default 0,
  branch         text default 'HQ',
  state          text not null default 'draft' check (state in ('draft','paid')),
  paid           numeric(10,2) default 0,
  discount       numeric(10,2) default 0,
  payment_method text,
  consulted      boolean not null default false,
  history        text,
  diagnosis      text,
  direct_visit   boolean not null default false,
  cashier        text,
  created_at     timestamptz not null default now(),
  paid_at        timestamptz,
  consulted_at   timestamptz
);
create index if not exists idx_appts_patient on public.appointments (patient_id);
create index if not exists idx_appts_doctor on public.appointments (doctor);
create index if not exists idx_appts_state on public.appointments (state);
create index if not exists idx_appts_created on public.appointments (created_at);

-- ------------------------------------------------------------
-- 4) PRESCRIPTIONS — dawooyinka dhakhtarku qoro (+ qodobada/medicines)
-- ------------------------------------------------------------
create table if not exists public.prescriptions (
  id            text primary key,
  appt_id       text references public.appointments(id) on delete cascade,
  patient_id    text references public.patients(id) on delete set null,
  patient_name  text,
  phone         text,
  doctor        text,
  date          timestamptz not null default now(),
  status        text not null default 'pending' check (status in ('pending','dispensed','partially_dispensed')),
  dispensed_at  timestamptz,
  dispensed_by  text,
  sale_id       text
);
create index if not exists idx_rx_appt on public.prescriptions (appt_id);
create index if not exists idx_rx_patient on public.prescriptions (patient_id);
create index if not exists idx_rx_status on public.prescriptions (status);

create table if not exists public.prescription_items (
  id               bigserial primary key,
  prescription_id  text references public.prescriptions(id) on delete cascade,
  name             text not null,
  frequency        text,
  duration         text,
  qty              integer default 1
);
create index if not exists idx_rx_items_rx on public.prescription_items (prescription_id);

-- ------------------------------------------------------------
-- 5) LAB REQUESTS — baaritaanada dhakhtarku codsaday (+ tests + results)
-- ------------------------------------------------------------
create table if not exists public.lab_requests (
  id           text primary key,
  appt_id      text references public.appointments(id) on delete cascade,
  patient_id   text references public.patients(id) on delete set null,
  patient_name text,
  phone        text,
  age          text,
  sex          text,
  doctor       text,
  date         timestamptz not null default now(),
  status       text not null default 'pending' check (status in ('pending','completed'))
);
create index if not exists idx_labreq_appt on public.lab_requests (appt_id);
create index if not exists idx_labreq_patient on public.lab_requests (patient_id);
create index if not exists idx_labreq_status on public.lab_requests (status);

create table if not exists public.lab_request_tests (
  id           text primary key,
  request_id   text references public.lab_requests(id) on delete cascade,
  test_name    text not null,
  is_panel     boolean default false,
  status       text not null default 'pending' check (status in ('pending','completed')),
  technician   text,
  result_date  timestamptz,
  notes        text
);
create index if not exists idx_labtests_request on public.lab_request_tests (request_id);

create table if not exists public.lab_request_results (
  id       bigserial primary key,
  test_id  text references public.lab_request_tests(id) on delete cascade,
  name     text not null,
  unit     text,
  range    text,
  value    text
);
create index if not exists idx_labresults_test on public.lab_request_results (test_id);

-- ------------------------------------------------------------
-- 6) PHARMACY — alaabta, iibka (POS + dispense), iyo deynta
-- ------------------------------------------------------------
create table if not exists public.pharmacy_products (
  id      text primary key,
  name    text not null,
  price   numeric(10,2) not null default 0,
  cost    numeric(10,2) not null default 0,
  qty     integer not null default 0,
  low     integer not null default 5,
  expiry  date
);
create index if not exists idx_ph_products_name on public.pharmacy_products (lower(name));

create table if not exists public.pharmacy_sales (
  id            text primary key,
  receipt_no    text,
  date          timestamptz not null default now(),
  subtotal      numeric(10,2),
  discount      numeric(10,2) default 0,
  total         numeric(10,2) not null default 0,
  profit        numeric(10,2) default 0,
  payment       text,
  user_name     text,
  rx_id         text references public.prescriptions(id) on delete set null,
  patient_name  text,
  patient_age   text,
  patient_sex   text,
  doctor        text,
  customer      text,
  phone         text
);
create index if not exists idx_ph_sales_date on public.pharmacy_sales (date);
create index if not exists idx_ph_sales_rx on public.pharmacy_sales (rx_id);

create table if not exists public.pharmacy_sale_items (
  id          bigserial primary key,
  sale_id     text references public.pharmacy_sales(id) on delete cascade,
  product_id  text,
  name        text not null,
  qty         integer not null default 1,
  price       numeric(10,2) not null default 0,
  cost        numeric(10,2) default 0
);
create index if not exists idx_ph_sale_items_sale on public.pharmacy_sale_items (sale_id);

create table if not exists public.pharmacy_credit_accounts (
  id       text primary key,
  name     text not null,
  phone    text,
  balance  numeric(10,2) not null default 0
);
create index if not exists idx_ph_credit_phone on public.pharmacy_credit_accounts (phone);

-- ------------------------------------------------------------
-- 7) LAB — alaabta/tests, iibka walk-in POS
-- ------------------------------------------------------------
create table if not exists public.lab_products (
  id      text primary key,
  name    text not null,
  qty     integer not null default 0,
  cost    numeric(10,2) not null default 0,
  sell    numeric(10,2) not null default 0,
  expiry  date
);

create table if not exists public.lab_sales (
  id              text primary key,
  receipt_no      text,
  date            timestamptz not null default now(),
  customer        text,
  subtotal        numeric(10,2),
  discount        numeric(10,2) default 0,
  total           numeric(10,2) not null default 0,
  profit          numeric(10,2) default 0,
  payment_method  text,
  cashier         text
);
create index if not exists idx_lab_sales_date on public.lab_sales (date);

create table if not exists public.lab_sale_items (
  id          bigserial primary key,
  sale_id     text references public.lab_sales(id) on delete cascade,
  product_id  text,
  name        text not null,
  qty         integer not null default 1,
  price       numeric(10,2) not null default 0,
  cost        numeric(10,2) default 0
);
create index if not exists idx_lab_sale_items_sale on public.lab_sale_items (sale_id);

-- ------------------------------------------------------------
-- 8) FOLLOW-UPS — fariimaha WhatsApp la-soo-noqoshada
-- ------------------------------------------------------------
create table if not exists public.followups (
  id            text primary key,
  appt_id       text references public.appointments(id) on delete cascade,
  patient_name  text,
  phone         text,
  doctor        text,
  visit_date    timestamptz,
  due_date      timestamptz,
  status        text not null default 'pending' check (status in ('pending','sent')),
  sent_at       timestamptz,
  created_at    timestamptz not null default now()
);
create index if not exists idx_followups_due on public.followups (due_date);
create index if not exists idx_followups_status on public.followups (status);

-- ------------------------------------------------------------
-- 9) EXPENSES — kharashaadka isbitalka (loo baahan yahay Net Profit)
-- ------------------------------------------------------------
create table if not exists public.expenses (
  id          text primary key,
  date        date not null,
  category    text,
  amount      numeric(10,2) not null default 0,
  note        text,
  entered_by  text,
  created_at  timestamptz not null default now()
);
create index if not exists idx_expenses_date on public.expenses (date);

-- ============================================================
-- ROW LEVEL SECURITY — isla habka bax_app_data (anon oggol
-- akhris/qoraal, sababtoo ah app-ku wuxuu leeyahay login-kiisa
-- gudaha ee gaarka ah).
-- ============================================================
do $$
declare
  t text;
begin
  for t in
    select unnest(array[
      'users','patients','appointments','prescriptions','prescription_items',
      'lab_requests','lab_request_tests','lab_request_results',
      'pharmacy_products','pharmacy_sales','pharmacy_sale_items','pharmacy_credit_accounts',
      'lab_products','lab_sales','lab_sale_items','followups','expenses'
    ])
  loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('drop policy if exists "allow_all_select" on public.%I;', t);
    execute format('create policy "allow_all_select" on public.%I for select using (true);', t);
    execute format('drop policy if exists "allow_all_insert" on public.%I;', t);
    execute format('create policy "allow_all_insert" on public.%I for insert with check (true);', t);
    execute format('drop policy if exists "allow_all_update" on public.%I;', t);
    execute format('create policy "allow_all_update" on public.%I for update using (true);', t);
    execute format('drop policy if exists "allow_all_delete" on public.%I;', t);
    execute format('create policy "allow_all_delete" on public.%I for delete using (true);', t);
    execute format('alter table public.%I replica identity full;', t);
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and tablename = t
    ) then
      execute format('alter publication supabase_realtime add table public.%I;', t);
    end if;
  end loop;
end $$;

-- ============================================================
-- HELPFUL REPORTING VIEWS (tusaale — SQL toos ah)
-- ============================================================

-- Dakhliga maalin kasta, qeyb kasta (Cashier / Lab / Pharmacy)
create or replace view public.v_daily_revenue as
select
  d::date as day,
  coalesce((select sum(paid) from public.appointments where state='paid' and paid_at::date = d), 0) as cashier_revenue,
  coalesce((select sum(total) from public.lab_sales where date::date = d), 0) as lab_revenue,
  coalesce((select sum(profit) from public.lab_sales where date::date = d), 0) as lab_profit,
  coalesce((select sum(total) from public.pharmacy_sales where date::date = d), 0) as pharmacy_revenue,
  coalesce((select sum(profit) from public.pharmacy_sales where date::date = d), 0) as pharmacy_profit,
  coalesce((select sum(amount) from public.expenses where date = d), 0) as expenses
from generate_series(current_date - interval '90 days', current_date, interval '1 day') as d;

-- Bukaannada ugu badan booqashada dhakhtar kasta
create or replace view public.v_doctor_patient_counts as
select doctor, count(distinct patient_id) as patient_count, count(*) as visit_count
from public.appointments
where doctor is not null
group by doctor
order by visit_count desc;

-- Alaabta farmashiga ee dhacaysa ama stock-ku yar yahay
create or replace view public.v_pharmacy_alerts as
select id, name, qty, low, expiry,
  case when expiry < current_date then 'expired'
       when expiry < current_date + interval '30 days' then 'expiring_soon'
       when qty <= low then 'low_stock'
       else 'ok' end as alert_type
from public.pharmacy_products
where expiry < current_date + interval '30 days' or qty <= low;

-- ============================================================
-- DIB U DEJIN (haddii loo baahdo bilow cusub — waa mid halis ah!):
--   truncate table public.appointments, public.prescriptions,
--     public.lab_requests, public.pharmacy_sales, public.lab_sales,
--     public.followups, public.expenses cascade;
-- ============================================================
