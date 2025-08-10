CREATE TABLE holidays (
  holiday_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  holiday_name VARCHAR(255) NOT NULL,
  holiday_date DATE NOT NULL,
  year INT NOT NULL,
  description TEXT
);

CREATE UNIQUE INDEX uq_holidays_year_name ON holidays (year, holiday_name);
