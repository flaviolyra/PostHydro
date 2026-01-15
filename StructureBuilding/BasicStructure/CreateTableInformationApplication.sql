CREATE TABLE information_application
(
  gid serial PRIMARY KEY,
  variable text,
  topology text,
  form text,
  accum_table text,
  nonaccum_table text,
  key_table text,
  description_name text,
  value_name text,
  method text,
  locale text
);

