---
-- Tests
---

SELECT DISTINCT vic.code
FROM View_Ins_Calc as vic;

SELECT *
FROM Client as c  LEFT JOIN Email as e ON c.key_client = e.id_client
                  LEFT JOIN Passport as p ON c.key_client = p.id_client
                  LEFT JOIN Phone as ph  ON c.key_client = ph.id_client
                  LEFT JOIN Adress as a ON c.key_client = a.id_client
;


SELECT c.code as success_fee_currency, cc.code as currency, g.*, sft.*
FROM Groups as g JOIN Currency as cc ON g.id_currency = cc.key_currency
                 JOIN Currency as c ON g.id_success_fee_currency = c.key_currency
                 JOIN Success_Fee_Type AS sft ON g.id_success_fee_type = sft.key_success_fee_type
WHERE success_fee_currency = 'RUB';


SELECT c.code as success_fee_currency, g.*, sft.*
FROM Groups as g JOIN Currency as c ON g.id_currency = c.key_currency
                 JOIN Success_Fee_Type AS sft ON g.id_success_fee_type = sft.key_success_fee_type 
WHERE c.code = 'USD'
;

SELECT *
FROM Success_Fee
ORDER BY percent;


SELECT
    p.day_of_month,
    p.aum_bop,
    clc.success_fee_act,
    clc.perf_gross,
    p.key_period,
    c.managment_fee,
    p.dates,
    clc.id_group,
    p.id_contract,
    p.assets_gross,
    p.eof_bop
FROM (Period as p INNER JOIN Contract as c ON c.key_contract = p.id_contract) 
                  LEFT JOIN Groups as g ON g.key_groups = c.id_groups
                  JOIN Calculation as clc ON g.key_groups = clc.id_group
WHERE p.assets_gross ISNULL and p.dates = clc.dates;



SELECT
     p.day_of_month,
     p.aum_bop,
     clc.success_fee_act,
     clc.perf_gross,
     p.key_period,
     c.managment_fee,
     p.dates,
     clc.id_group,
     p.id_contract,
     p.assets_gross,
     p.eof_bop
 FROM (Period as p INNER JOIN Contract as c ON c.key_contract = p.id_contract) 
                   LEFT JOIN Groups as g ON g.key_groups = c.id_groups
                   JOIN Calculation as clc ON g.key_groups = clc.id_group
 WHERE p.assets_gross ISNULL and p.dates = clc.dates;

SELECT
    p.day_of_month,
    p.aum_bop,
    p.key_period,
    p.dates as _p_dates,
    c.managment_fee,
    p.id_contract,
    clc.id_group,
    clc.*
FROM (Period as p LEFT JOIN Contract as c ON c.key_contract = p.id_contract) 
                  LEFT JOIN Groups as g ON g.key_groups = c.id_groups
                  FULL JOIN  Calculation as clc ON clc.dates = p.dates
WHERE c.key_contract = 13456 AND clc.dates IS NOT NULL;


SELECT
     p.day_of_month,
     p.aum_bop,
     clc.success_fee_act,
     clc.perf_gross,
     p.key_period,
     c.managment_fee,
     p.dates,
     clc.id_group,
     p.id_contract,
     p.assets_gross,
     p.eof_bop
 FROM (Period as p INNER JOIN Contract as c ON c.key_contract = p.id_contract) 
                   LEFT JOIN Groups as g ON g.key_groups = c.id_groups
                   FULL JOIN  Calculation as clc ON clc.dates = p.dates
WHERE clc.dates IS NOT NULL;



SELECT
     vn.day_of_month,
     vn.aum_bop,
     clc.success_fee_act,
     clc.perf_gross,
     vn.key_period,
     vn.managment_fee,
     vn.dates,
     clc.id_group,
     vn.id_contract,
     vn.assets_gross,
     vn.eof_bop,
     sft."type",
     cur.currency_name,
     cur.code
FROM Calculation as clc LEFT JOIN Groups as g ON g.key_groups = clc.id_group
                          LEFT JOIN Success_Fee_Type AS sft ON sft.key_success_fee_type = g.id_success_fee_type
                          LEFT JOIN Currency as cur ON cur.key_currency = g.id_success_fee_currency
                          FULL JOIN View_Nate as vn ON vn.dates = clc.dates                     
WHERE clc.dates IS NOT NULL;


-- select julianday('2024-01-01') - julianday('2023-01-01')

-- SELECT julianday(date('2024-12-01', 'start of year', '+1 year')) - julianday(date('2024-12-01', 'start of year')) 


/*SELECT
round((clc.perf_gross * p.aum_bop)/100, 2) as profit_month,
round(((clc.perf_gross * p.aum_bop)/100) * p.day_of_month / strftime('%d', p.dates) , 2) as profit_per,
round(((clc.perf_gross * p.aum_bop)/100) * p.day_of_month / strftime('%d', p.dates) + p.aum_bop, 2) as ass_gros_per,
round(((clc.perf_gross * p.aum_bop)/100) + p.aum_bop, 2) as ass_gros,
round((p.aum_bop + round((clc.perf_gross * p.aum_bop)/100, 2) + p.aum_bop)/2, 2) as avg_dep,
round(((clc.success_fee_act/100) + c.managment_fee) * ((clc.perf_gross * p.aum_bop)/100) * p.day_of_month / strftime('%d', p.dates), 2) as incom,
p.aum_bop, p.id_contract, clc.perf_gross, p.dates,
g.strategy, clc.key_calculation as clc_key, clc.success_fee_act as clc_suc_act, clc.perf_gross, clc.dates, clc.id_group, c.managment_fee
FROM Contract c, Groups as g , Calculation as clc, Period as p
WHERE c.key_contract = p.id_contract AND g.key_groups = c.id_groups  AND g.key_groups = clc.id_group
*/

SELECT
ROUND((clc.perf_gross * p.aum_bop) / 100, 2) as profit_month,
ROUND(((clc.perf_gross * p.aum_bop) / 100) / strftime('%d', p.dates) * p.day_of_month, 2) as profit_per,
ROUND(((clc.perf_gross * p.aum_bop) / 100) * p.day_of_month / strftime('%d', p.dates) + p.aum_bop, 2) as ass_gros_per,
ROUND(((clc.perf_gross * p.aum_bop) / 100) + p.aum_bop, 2) as ass_gros,
ROUND(((p.aum_bop + (((clc.perf_gross * p.aum_bop)/100) + p.aum_bop))) / 2, 2) as avg_dep,
--
ROUND(ROUND((((p.aum_bop + ((clc.perf_gross * p.aum_bop)/100) + p.aum_bop)/2) * (c.managment_fee / 366 * p.day_of_month)) ,2) +
 ROUND((((clc.perf_gross * p.aum_bop) / 100) / strftime('%d', p.dates) * p.day_of_month / 100)*
ROUND(ROUND(clc.success_fee_act / 366 * strftime('%d', p.dates),2) / clc.perf_gross * 100, 2), 2), 2)
as incom,
--
ROUND(((((p.aum_bop + ((clc.perf_gross * p.aum_bop)/100) + p.aum_bop)/2) * (c.managment_fee / 366 * p.day_of_month))) +
 ((((clc.perf_gross * p.aum_bop) / 100) / strftime('%d', p.dates) * p.day_of_month / 100)*
((clc.success_fee_act / 366 * strftime('%d', p.dates)) / clc.perf_gross * 100)),2)
as incom2,
/*
ROUND(((clc.perf_gross * p.aum_bop) / 100) * p.day_of_month / strftime('%d', p.dates) + p.aum_bop, 2) - (
 ROUND((((clc.perf_gross * p.aum_bop) / 100) / strftime('%d', p.dates) * p.day_of_month / 100)*
ROUND(ROUND(clc.success_fee_act / 366 * strftime('%d', p.dates),2) / clc.perf_gross * 100, 2), 2) +
ROUND((((((clc.perf_gross * p.aum_bop)/100) / strftime('%d', p.dates)) * p.day_of_month) * (clc.success_fee_act / 100)) +
     (
     ((p.aum_bop + ((clc.perf_gross * p.aum_bop)/100) + p.aum_bop)/2) * (c.managment_fee / 366 * p.day_of_month)) ,2))
*/ 
ROUND(((clc.perf_gross * p.aum_bop) / 100) * p.day_of_month / strftime('%d', p.dates) + p.aum_bop, 2) - 
ROUND(ROUND((((p.aum_bop + ((clc.perf_gross * p.aum_bop)/100) + p.aum_bop)/2) * (c.managment_fee / 366 * p.day_of_month)) ,2) +
 ROUND((((clc.perf_gross * p.aum_bop) / 100) / strftime('%d', p.dates) * p.day_of_month / 100)*
ROUND(ROUND(clc.success_fee_act / 366 * strftime('%d', p.dates),2) / clc.perf_gross * 100, 2), 2), 2) as next_month1,
--
ROUND(((clc.perf_gross * p.aum_bop) / 100) * p.day_of_month / strftime('%d', p.dates) + p.aum_bop, 2) - 
ROUND(((((p.aum_bop + ((clc.perf_gross * p.aum_bop)/100) + p.aum_bop)/2) * (c.managment_fee / 366 * p.day_of_month))) +
 ((((clc.perf_gross * p.aum_bop) / 100) / strftime('%d', p.dates) * p.day_of_month / 100)*
((clc.success_fee_act / 366 * strftime('%d', p.dates)) / clc.perf_gross * 100)),2) as next_month2,
--
 ROUND((((clc.perf_gross * p.aum_bop) / 100) / strftime('%d', p.dates) * p.day_of_month / 100)*
ROUND(ROUND(clc.success_fee_act / 366 * strftime('%d', p.dates),2) / clc.perf_gross * 100, 2), 2) as SF_earned,
--
ROUND(ROUND(clc.success_fee_act / 366 * strftime('%d', p.dates),2) / clc.perf_gross * 100, 2) as QR_Perf_Share,
--
ROUND((((p.aum_bop + ((clc.perf_gross * p.aum_bop)/100) + p.aum_bop)/2) * (c.managment_fee / 366 * p.day_of_month)) ,2) as MF_earned,
p.aum_bop, clc.perf_gross, p.dates, p.day_of_month as days,
c.aum_bop,
--clc.key_calculation as clc_key,
clc.success_fee_act as clc_suc_act,
--clc.dates,
c.managment_fee
FROM (Period as p INNER JOIN Contract as c ON c.key_contract = p.id_contract) 
                  LEFT JOIN Groups as g ON g.key_groups = c.id_groups
                  JOIN Calculation as clc ON g.key_groups = clc.id_group
WHERE p.dates = clc.dates;
--/*

SELECT
ROUND((clc.perf_gross * p.aum_bop) / 100, 2) as profit_month,
ROUND(((clc.perf_gross * p.aum_bop) / 100) / strftime('%d', p.dates) * p.day_of_month, 2) as profit_per,
ROUND(((clc.perf_gross * p.aum_bop) / 100) * p.day_of_month / strftime('%d', p.dates) + p.aum_bop, 2) as ass_gros_per,
ROUND(((clc.perf_gross * p.aum_bop) / 100) + p.aum_bop, 2) as ass_gros,
ROUND(((p.aum_bop + (((clc.perf_gross * p.aum_bop)/100) + p.aum_bop))) / 2, 2) as avg_per,
--
ROUND(ROUND((((p.aum_bop + ((clc.perf_gross * p.aum_bop)/100) + p.aum_bop)/2) * (c.managment_fee / 366 * p.day_of_month)) ,2) +
 ROUND((((clc.perf_gross * p.aum_bop) / 100) / strftime('%d', p.dates) * p.day_of_month / 100)*
ROUND(ROUND(clc.success_fee_act / 366 * strftime('%d', p.dates),2) / clc.perf_gross * 100, 2), 2), 2)
as incom,
--
ROUND(((((p.aum_bop + ((clc.perf_gross * p.aum_bop)/100) + p.aum_bop)/2) * (c.managment_fee / 366 * p.day_of_month))) +
 ((((clc.perf_gross * p.aum_bop) / 100) / strftime('%d', p.dates) * p.day_of_month / 100)*
((clc.success_fee_act / 366 * strftime('%d', p.dates)) / clc.perf_gross * 100)),2)
as incom2,
--
ROUND(((clc.perf_gross * p.aum_bop) / 100) * p.day_of_month / strftime('%d', p.dates) + p.aum_bop, 2) - 
ROUND(ROUND((((p.aum_bop + ((clc.perf_gross * p.aum_bop)/100) + p.aum_bop)/2) * (c.managment_fee / 366 * p.day_of_month)) ,2) +
 ROUND((((clc.perf_gross * p.aum_bop) / 100) / strftime('%d', p.dates) * p.day_of_month / 100)*
ROUND(ROUND(clc.success_fee_act / 366 * strftime('%d', p.dates),2) / clc.perf_gross * 100, 2), 2), 2) as next_month,
--
 ROUND((((clc.perf_gross * p.aum_bop) / 100) / strftime('%d', p.dates) * p.day_of_month / 100)*
ROUND(ROUND(clc.success_fee_act / 366 * strftime('%d', p.dates),2) / clc.perf_gross * 100, 2), 2) as SF_earned,
--
ROUND(ROUND(clc.success_fee_act / 366 * strftime('%d', p.dates),2) / clc.perf_gross * 100, 2) as QR_Perf_Share,
-- * */

SELECT 
ROUND((clc.perf_gross * p.aum_bop) / 100, 2) as profit_month,
--
ROUND(((clc.perf_gross * p.aum_bop) / 100) / strftime('%d', p.dates) * p.day_of_month, 2) as profit_per,
ROUND(((clc.perf_gross * p.aum_bop) / 100) * p.day_of_month / strftime('%d', p.dates) + p.aum_bop, 2) as ass_gros_per,
ROUND(((clc.perf_gross * p.aum_bop) / 100) + p.aum_bop, 2) as ass_gros,
ROUND(((p.aum_bop + (((clc.perf_gross * p.aum_bop)/100) + p.aum_bop))) / 2, 2) as avg_dep,
ROUND((((((clc.perf_gross * p.aum_bop)/100) / strftime('%d', p.dates)) * p.day_of_month) * (clc.success_fee_act / 100)) +
     (
     ((p.aum_bop + ((clc.perf_gross * p.aum_bop)/100) + p.aum_bop)/2) * (c.managment_fee / 366 * p.day_of_month)) ,2) as incom,
 --
 ROUND(((clc.perf_gross * p.aum_bop) / 100) / strftime('%d', p.dates) * p.day_of_month / 100 *
(clc.success_fee_act / 366 * strftime('%d', p.dates)) / clc.perf_gross * 100, 2) as next_month,
--
ROUND(((clc.perf_gross * p.aum_bop) / 100), 2) / strftime('%d', p.dates) * p.day_of_month / 100 as f,
p.aum_bop, p.id_contract, clc.perf_gross, p.dates, p.day_of_month as d,
clc.key_calculation as clc_key, clc.success_fee_act as clc_suc_act, clc.dates, clc.id_group, c.managment_fee
FROM (Period as p INNER JOIN Contract as c ON c.key_contract = p.id_contract) 
                  LEFT JOIN Groups as g ON g.key_groups = c.id_groups
                  JOIN Calculation as clc ON g.key_groups = clc.id_group
WHERE p.assets_gross ISNULL and p.dates = clc.dates;



