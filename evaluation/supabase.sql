-- Live-Evaluation: Datenbank-Schema für Supabase (einmal im SQL Editor ausführen).
-- Es werden keine Namen gespeichert. Direkter Tabellenzugriff ist gesperrt;
-- die Seite darf nur die unten definierten Funktionen aufrufen.
-- Räume und Antworten werden automatisch nach 24 Stunden gelöscht.

create extension if not exists pgcrypto with schema extensions;

create table if not exists public.eval_rooms (
  room       text primary key,
  host_hash  text not null,
  open       boolean not null default true,
  round      integer not null default 1,
  created_at timestamptz not null default now()
);

create table if not exists public.eval_answers (
  room       text not null references public.eval_rooms(room) on delete cascade,
  token      text not null,
  qid        text not null,
  value      text not null,
  updated_at timestamptz not null default now(),
  primary key (room, token, qid)
);

alter table public.eval_rooms   enable row level security;
alter table public.eval_answers enable row level security;
revoke all on public.eval_rooms, public.eval_answers from anon, authenticated;

-- Lehrkraft: Raum öffnen (oder wieder aufnehmen, wenn der Host-Schlüssel passt)
create or replace function public.open_room(p_room text, p_host_key text)
returns jsonb language plpgsql security definer set search_path = public, extensions as $$
declare h text; r public.eval_rooms;
begin
  if p_room !~ '^[A-Z0-9]{5,12}$' or length(p_host_key) < 16 then raise exception 'invalid_input'; end if;
  delete from public.eval_rooms where created_at < now() - interval '24 hours';
  h := encode(digest(p_host_key, 'sha256'), 'hex');
  insert into public.eval_rooms(room, host_hash) values (p_room, h) on conflict (room) do nothing;
  select * into r from public.eval_rooms where room = p_room;
  if r.host_hash <> h then raise exception 'room_taken'; end if;
  return jsonb_build_object('open', r.open, 'round', r.round);
end $$;

-- Alle: Zustand eines Raums
create or replace function public.room_state(p_room text)
returns jsonb language plpgsql security definer set search_path = public as $$
declare r public.eval_rooms;
begin
  select * into r from public.eval_rooms where room = p_room;
  if not found then return jsonb_build_object('exists', false); end if;
  return jsonb_build_object('exists', true, 'open', r.open, 'round', r.round);
end $$;

-- Teilnehmer: eine Antwort speichern bzw. ändern
create or replace function public.submit_answer(p_room text, p_token text, p_qid text, p_value text)
returns jsonb language plpgsql security definer set search_path = public as $$
declare r public.eval_rooms; n integer;
begin
  if p_room !~ '^[A-Z0-9]{5,12}$' or p_token !~ '^[a-z0-9]{8,64}$' or p_qid !~ '^q[0-9]{1,2}$'
     or p_value not in ('1','2','3','4','5','ja','nein') then raise exception 'invalid_input'; end if;
  select * into r from public.eval_rooms where room = p_room;
  if not found then return jsonb_build_object('ok', false, 'exists', false); end if;
  if not r.open then return jsonb_build_object('ok', false, 'open', false); end if;
  select count(distinct token) into n from public.eval_answers where room = p_room;
  if n >= 400 and not exists (select 1 from public.eval_answers where room = p_room and token = p_token) then
    raise exception 'room_full';
  end if;
  insert into public.eval_answers(room, token, qid, value) values (p_room, p_token, p_qid, p_value)
  on conflict (room, token, qid) do update set value = excluded.value, updated_at = now();
  return jsonb_build_object('ok', true, 'open', true);
end $$;

-- Lehrkraft: Zählstände (nur Summen, keine einzelnen Antworten)
create or replace function public.get_counts(p_room text)
returns jsonb language plpgsql security definer set search_path = public as $$
declare r public.eval_rooms;
begin
  select * into r from public.eval_rooms where room = p_room;
  if not found then return jsonb_build_object('exists', false); end if;
  return jsonb_build_object(
    'exists', true, 'open', r.open, 'round', r.round,
    'participants', (select count(distinct token) from public.eval_answers where room = p_room),
    'counts', coalesce((
      select jsonb_object_agg(qid, c) from (
        select qid, jsonb_object_agg(value, n) as c from (
          select qid, value, count(*) as n from public.eval_answers where room = p_room group by qid, value
        ) a group by qid
      ) b), '{}'::jsonb));
end $$;

-- Lehrkraft: Abstimmung beenden / wieder öffnen
create or replace function public.set_room_open(p_room text, p_host_key text, p_open boolean)
returns jsonb language plpgsql security definer set search_path = public, extensions as $$
begin
  update public.eval_rooms set open = p_open
   where room = p_room and host_hash = encode(digest(p_host_key, 'sha256'), 'hex');
  if not found then raise exception 'not_host'; end if;
  return jsonb_build_object('open', p_open);
end $$;

-- Lehrkraft: neue Runde (Antworten löschen)
create or replace function public.reset_room(p_room text, p_host_key text)
returns jsonb language plpgsql security definer set search_path = public, extensions as $$
begin
  update public.eval_rooms set round = round + 1, open = true
   where room = p_room and host_hash = encode(digest(p_host_key, 'sha256'), 'hex');
  if not found then raise exception 'not_host'; end if;
  delete from public.eval_answers where room = p_room;
  return jsonb_build_object('ok', true);
end $$;

revoke all on function public.open_room(text, text), public.room_state(text),
  public.submit_answer(text, text, text, text), public.get_counts(text),
  public.set_room_open(text, text, boolean), public.reset_room(text, text) from public;
grant execute on function public.open_room(text, text), public.room_state(text),
  public.submit_answer(text, text, text, text), public.get_counts(text),
  public.set_room_open(text, text, boolean), public.reset_room(text, text) to anon;
