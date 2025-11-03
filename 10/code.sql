
CREATE OR REPLACE VIEW personal.v_actual_ils
AS WITH lb AS (
         SELECT v_latest_balances.account_id,
            v_latest_balances.account_name,
            v_latest_balances.account_type,
            v_latest_balances.currency_code,
            v_latest_balances.amount,
            v_latest_balances.recorded_at
           FROM personal.v_latest_balances
        )
 SELECT lb.account_id,
    lb.account_name,
    lb.account_type,
    lb.currency_code,
    lb.amount,
    lb.recorded_at,
    COALESCE(
        CASE
            WHEN lb.currency_code = 'ILS'::bpchar THEN 1::numeric
            ELSE er.rate_to_ils
        END, 1::numeric) AS rate_to_ils,
    lb.amount * COALESCE(
        CASE
            WHEN lb.currency_code = 'ILS'::bpchar THEN 1::numeric
            ELSE er.rate_to_ils
        END, 1::numeric) AS amount_ils
   FROM lb
     LEFT JOIN LATERAL ( SELECT er1.rate_to_ils
           FROM personal.exchange_rates er1
             JOIN personal.currencies cur ON cur.id = er1.currency_id
          WHERE cur.code = lb.currency_code AND er1.rate_date <= lb.recorded_at
          ORDER BY er1.rate_date DESC
         LIMIT 1) er ON true;
