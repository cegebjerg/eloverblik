CREATE TABLE dayaheadprice (
dayaheadprice_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
TimeUTC timestamptz,
TimeDK timestamptz,
PriceArea VARCHAR(5) NOT NULL,
DayAheadPriceEUR NUMERIC(6, 2),
DayAheadPriceDKK  NUMERIC(6, 2),
created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX uq_dayaheadprice_pa_utc ON dayaheadprice (TimeUTC, PriceArea);

-- Trigger to auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_updated_at_dap
BEFORE UPDATE ON dayaheadprice
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();