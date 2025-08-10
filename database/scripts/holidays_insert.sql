DO $$
DECLARE
  yr INT;
  e DATE;
BEGIN
  FOR yr IN 2025..2050 LOOP
    e := easter_date(yr);
    INSERT INTO holidays (holiday_name, holiday_date, year, description) VALUES
      ('Nytårsdag', MAKE_DATE(yr, 1, 1), yr, 'Nytår'),
      ('Skærtorsdag', e - INTERVAL '3 days', yr, 'Torsdag før påske'),
      ('Langfredag', e - INTERVAL '2 days', yr, 'Fredag før påske'),
      ('Påske', e, yr, 'Påske søndag'),
      ('2. påske dag', e + INTERVAL '1 day', yr, 'Mandag efter påske'),
      ('Kristi himmelfartsdag', e + INTERVAL '39 days', yr, 'Kristi himmelfartsdag 40 dage efter påske, falder en torsdag'),
      ('Pinse', e + INTERVAL '49 days', yr, 'Pinse søndag, 7. søndag efter påske'),
      ('2. pinsedag', e + INTERVAL '50 days', yr, 'Mandag efter pinse'),
      ('Juleaften', MAKE_DATE(yr, 12, 24), yr, 'Juleaften, fast 24 december'),
      ('Juledag', MAKE_DATE(yr, 12, 25), yr, '1. juledag, fast 25 december'),
      ('2. juledag', MAKE_DATE(yr, 12, 26), yr, '2. juledag, fast 26 december')
    ON CONFLICT DO NOTHING;
  END LOOP;
END;
$$ LANGUAGE plpgsql;
