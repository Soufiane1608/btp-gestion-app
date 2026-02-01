-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- 1. Clients Table
create table clients (
  id uuid default uuid_generate_v4() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  name text not null,
  address text,
  phone text,
  email text
);

-- 2. Products (Inventory) Table
create table products (
  id uuid default uuid_generate_v4() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  name text not null,
  category text default 'Materiaux',
  quantity numeric default 0,
  unit text default 'Unité',
  min_quantity numeric default 10 -- For low stock alerts
);

-- 3. Invoices Table
create table invoices (
  id uuid default uuid_generate_v4() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  date date default current_date,
  client_id uuid references clients(id),
  client_name text, -- De-normalized for easier display if client deleted
  subtotal numeric default 0,
  total numeric default 0,
  advance numeric default 0, -- Avance payée
  balance numeric generated always as (total - advance) stored, -- Auto-calculated
  status text default 'En attente' -- Payée, En attente, Retard
);

-- 4. Invoice Items (Line items)
create table invoice_items (
  id uuid default uuid_generate_v4() primary key,
  invoice_id uuid references invoices(id) on delete cascade,
  description text not null,
  quantity numeric default 1,
  price numeric default 0,
  total numeric generated always as (quantity * price) stored
);

-- Row Level Security (RLS) - Optional for now but recommended
alter table clients enable row level security;
alter table products enable row level security;
alter table invoices enable row level security;
alter table invoice_items enable row level security;

-- Policies (Allow public access for MVP simplicity, lock down later)
create policy "Allow all access" on clients for all using (true);
create policy "Allow all access" on products for all using (true);
create policy "Allow all access" on invoices for all using (true);
create policy "Allow all access" on invoice_items for all using (true);
