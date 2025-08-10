CREATE OR REPLACE FUNCTION solar_position_calc(
    ts TIMESTAMPTZ,          -- Date/time (timezone-aware)
    latitude DOUBLE PRECISION,  -- Degrees
    longitude DOUBLE PRECISION  -- Degrees (East positive, West negative)
) RETURNS solar_position AS $$
DECLARE
    jd DOUBLE PRECISION;
    jc DOUBLE PRECISION;
    g DOUBLE PRECISION;
    q DOUBLE PRECISION;
    l DOUBLE PRECISION;
    e DOUBLE PRECISION;
    decl DOUBLE PRECISION;
    eqtime DOUBLE PRECISION;
    time_offset DOUBLE PRECISION;
    tst DOUBLE PRECISION;
    ha DOUBLE PRECISION;
    rad_lat DOUBLE PRECISION;
    elev DOUBLE PRECISION;
    az DOUBLE PRECISION;
BEGIN
    -- Julian Day
    jd := EXTRACT(EPOCH FROM ts AT TIME ZONE 'UTC') / 86400.0 + 2440587.5;

    -- Julian Century
    jc := (jd - 2451545.0) / 36525.0;

    -- Geometric Mean Longitude of Sun (deg)
    q := MOD(280.46646 + jc * (36000.76983 + jc * 0.0003032), 360);

    -- Geometric Mean Anomaly of Sun (deg)
    g := 357.52911 + jc * (35999.05029 - 0.0001537 * jc);

    -- Eccentricity of Earth's orbit
    e := 0.016708634 - jc * (0.000042037 + 0.0000001267 * jc);

    -- Sun's equation of center and true longitude
    l := q + (1.914602 - jc * (0.004817 + 0.000014 * jc)) * SIN(RADIANS(g))
           + (0.019993 - 0.000101 * jc) * SIN(RADIANS(2*g))
           + 0.000289 * SIN(RADIANS(3*g));

    -- Sun's declination
    decl := DEGREES(ASIN(SIN(RADIANS(l)) * SIN(RADIANS(23.439 - 0.00000036 * jc))));

    -- Equation of time (minutes)
    eqtime := 229.18 * (0.000075 + 0.001868 * COS(RADIANS(g))
             - 0.032077 * SIN(RADIANS(g))
             - 0.014615 * COS(RADIANS(2*g))
             - 0.040849 * SIN(RADIANS(2*g)));

    -- True solar time (minutes)
    time_offset := eqtime + 4 * longitude - 60 * EXTRACT(TIMEZONE_HOUR FROM ts);
    tst := MOD(EXTRACT(HOUR FROM ts) * 60 + EXTRACT(MINUTE FROM ts) + time_offset, 1440);

    -- Hour angle (deg)
    IF tst / 4 < 0 THEN
        ha := tst / 4 + 180;
    ELSE
        ha := tst / 4 - 180;
    END IF;

    -- Convert latitude to radians
    rad_lat := RADIANS(latitude);

    -- Solar elevation
    elev := DEGREES(ASIN(SIN(rad_lat) * SIN(RADIANS(decl)) +
                         COS(rad_lat) * COS(RADIANS(decl)) * COS(RADIANS(ha))));

    -- Solar azimuth (0° = North, clockwise)
    az := DEGREES(
        ATAN2(
            SIN(RADIANS(ha)),
            COS(RADIANS(ha)) * SIN(rad_lat) - TAN(RADIANS(decl)) * COS(rad_lat)
        )
    ) + 180;  -- Shift range to [0, 360)

    RETURN (elev, az);
END;
$$ LANGUAGE plpgsql IMMUTABLE;
