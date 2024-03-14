--/*
DROP VIEW IF EXISTS View_Calculate_Pred;
DROP VIEW IF EXISTS View_Calculate3;
DROP VIEW IF EXISTS View_Ins_Calc;
DROP VIEW IF EXISTS View_Client;
DROP VIEW IF EXISTS View_Nate;
--*/

CREATE VIEW View_Calculate3 AS SELECT
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


CREATE VIEW View_Calculate_Pred AS SELECT
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
     cur.code as gr_cur_code,
     cur.currency_name as gr_cur_name
FROM Calculation as clc LEFT JOIN Groups as g ON g.key_groups = clc.id_group
                          LEFT JOIN Success_Fee_Type AS sft ON sft.key_success_fee_type = g.id_success_fee_type
                          LEFT JOIN Currency as cur ON cur.key_currency = g.id_success_fee_currency
                          FULL JOIN View_Nate as vn ON vn.dates = clc.dates                     
WHERE clc.dates IS NOT NULL;


CREATE VIEW View_Ins_Calc AS SELECT
     sft.diff,
     sft.type,
     sft.key_success_fee_type,
     g.id_success_fee_type,
     g.id_success_fee_currency,
     g.key_groups,
     c.code,
     ql.min_val,
     ql.max_val
 FROM Success_Fee_Type AS sft LEFT JOIN Groups AS g ON sft.key_success_fee_type = g.id_success_fee_type
                              LEFT JOIN Currency AS c ON g.id_success_fee_currency = c.key_currency 
                              LEFT JOIN QR_Limit AS ql ON c.key_currency = ql.key_currency;



CREATE VIEW View_Nate AS SELECT
    sft."type",
    p.*,
    clc.success_fee_act,
    clc.perf_gross,clc.perf_gross_p_a,
    cr.code as Currency_code_SF,
    cr.currency_name AS currency_name_SF
FROM Contract AS c LEFT JOIN Groups as g ON c.id_groups = g.key_groups 
                   LEFT JOIN Success_Fee_Type AS sft ON g.id_success_fee_type = sft.key_success_fee_type
                   LEFT JOIN Currency AS cr ON cr.key_currency = g.id_success_fee_currency
                   LEFT JOIN Period as p on  p.id_contract  = c.key_contract
                   JOIN Calculation AS clc ON clc.id_group = g.key_groups AND clc.dates = p.dates;

                  
