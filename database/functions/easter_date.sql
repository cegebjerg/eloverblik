-- Compute Easter Sunday for a given year (Gauss algorithm)
CREATE OR REPLACE FUNCTION easter_date(year INT) RETURNS DATE AS $$
DECLARE
  a INT := year % 19;
  b INT := year / 100;
  c INT := year % 100;
  d INT := b / 4;
  e INT := b % 4;
  f INT := (b + 8) / 25;
  g INT := (b - f + 1) / 3;
  h INT := (19 * a + b - d - g + 15) % 30;
  i INT := c / 4;
  k INT := c % 4;
  l INT := (32 + 2 * e + 2 * i - h - k) % 7;
  m INT := (a + 11 * h + 22 * l) / 451;
  month INT := (h + l - 7 * m + 114) / 31;
  day INT := ((h + l - 7 * m + 114) % 31) + 1;
BEGIN
  RETURN MAKE_DATE(year, month, day);
END;
$$ LANGUAGE plpgsql IMMUTABLE;
