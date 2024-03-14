-- /*
DROP TRIGGER IF EXISTS DELETE_contract_log;
DROP TRIGGER IF EXISTS insert_contract_Income;
DROP TRIGGER IF EXISTS insert_contract_Period_lo;
DROP TRIGGER IF EXISTS insert_contract_log;
DROP TRIGGER IF EXISTS update_contract_log;
DROP TRIGGER IF EXISTS AFTER_insert_email;
DROP TRIGGER IF EXISTS AFTER_insert_phone;
DROP TRIGGER IF EXISTS AFTER_insert_adress;
DROP TRIGGER IF EXISTS AFTER_insert_passport;
DROP TRIGGER IF EXISTS update_on_Period_Exis;
DROP TRIGGER IF EXISTS update_on_Period_Not_Exis;
DROP TRIGGER IF EXISTS update_on_Period_SF_1;
-- */

CREATE TRIGGER DELETE_contract_log AFTER DELETE ON Contract
	BEGIN 
		INSERT INTO Log_Contract (
			date_change,
			old_value,
			new_value,
			id_contract,
			difference,
			action_cont
		)
		VALUES (
			datetime("now"),
			OLD.aum_bop,
			0,
			OLD.key_contract,
			ROUND(-OLD.aum_bop, 2),
			'DELETE ON Contract'
		);

END;


CREATE TRIGGER insert_contract_Income after INSERT ON Contract
WHEN NOT EXISTS (SELECT id_contract from Income
         WHERE  income = ROUND((NEW.aum_bop*NEW.upfront_fee)+(NEW.aum_bop*NEW.redepton_fee), 2) and
         id_contract = NEW.key_contract and id_period ISNULL)
BEGIN
         INSERT INTO Income (
          Income,
          id_contract
          )
          VALUES (
           ROUND((NEW.aum_bop*NEW.upfront_fee)+(NEW.aum_bop*NEW.redepton_fee), 2),
           NEW.key_contract);
END;


CREATE TRIGGER insert_contract_Period_lo AFTER INSERT ON Contract 
WHEN NOT EXISTS (SELECT id_contract from Period as p
         WHERE id_contract = NEW.key_contract AND
         p.aum_bop = ROUND(NEW.aum_bop - ((NEW.aum_bop * NEW.upfront_fee) + (NEW.aum_bop * NEW.redepton_fee)), 2) AND
         p.dates = date(NEW.contract_date, 'start of month', '+1 month', '-1 day') AND
         p.day_of_month = strftime('%d', date(NEW.contract_date, 'start of month', '+1 month', '-1 day'))
                      - strftime('%d', date(NEW.contract_date)) + 1)
	BEGIN
		INSERT INTO Period (
			dates, -- дата расчета
			day_of_month,
			aum_bop,
			id_contract
		)
		VALUES (
			date(NEW.contract_date, 'start of month', '+1 month', '-1 day'),
            strftime('%d', date(NEW.contract_date, 'start of month', '+1 month', '-1 day')) - strftime('%d', date(NEW.contract_date)) + 1,
			ROUND(NEW.aum_bop - ((NEW.aum_bop * NEW.upfront_fee) + (NEW.aum_bop * NEW.redepton_fee)), 2),
			NEW.key_contract
		);
    END;
    
   CREATE TRIGGER insert_contract_log AFTER INSERT ON Contract 
	BEGIN
		INSERT INTO Log_Contract (
			date_change,
			old_value,
			new_value,
			id_contract,
			difference,
			action_cont
		)
		VALUES (
			datetime("now"),
			NEW.aum_bop,
			ROUND(NEW.aum_bop-((NEW.aum_bop*NEW.upfront_fee)+(NEW.aum_bop*NEW.redepton_fee)), 2),
			NEW.key_contract,
			ROUND((NEW.aum_bop-((NEW.aum_bop*NEW.upfront_fee)+(NEW.aum_bop*NEW.redepton_fee)))-NEW.aum_bop, 2),
			'INSERT ON Contract'
		);
	END;


CREATE TRIGGER update_contract_log AFTER UPDATE OF aum_bop ON Contract
	BEGIN 
		INSERT INTO Log_Contract (
			date_change,
			old_value,
			new_value,
			id_contract,
			difference,
			action_cont
		)
		VALUES (
			datetime("now"),
			OLD.aum_bop,
			NEW.aum_bop,
			NEW.key_contract,
			ROUND(NEW.aum_bop - OLD.aum_bop, 2),
			'UPDATE ON Contract'
		);

END;


CREATE TRIGGER AFTER_insert_email AFTER INSERT ON Email 
WHEN EXISTS (SELECT Email.key_email from Email
         WHERE Email.id_client = NEW.id_client AND Email.key_email!= NEW.key_email AND Email.cur_email=1)
	BEGIN
		UPDATE Email
		SET cur_email=0
        WHERE Email.id_client = NEW.id_client AND Email.key_email!= NEW.key_email AND Email.cur_email=1;
    END;


CREATE TRIGGER AFTER_insert_phone AFTER INSERT ON Phone 
WHEN EXISTS (SELECT Phone.key_phone from Phone
         WHERE Phone.id_client = NEW.id_client AND Phone.key_phone!= NEW.key_phone AND Phone.cur_phone=1)
	BEGIN
		UPDATE Phone
		SET cur_phone=0
        WHERE Phone.id_client = NEW.id_client AND Phone.key_phone!= NEW.key_phone AND Phone.cur_phone=1;
    END;
   
   
CREATE TRIGGER AFTER_insert_adress AFTER INSERT ON Adress 
WHEN EXISTS (SELECT Adress.key_adress from Adress
         WHERE Adress.id_client = NEW.id_client AND Adress.key_adress!= NEW.key_adress AND Adress.cur_adress=1)
	BEGIN
		UPDATE Adress
		SET cur_adress=0
        WHERE Adress.id_client = NEW.id_client AND Adress.key_adress!= NEW.key_adress AND Adress.cur_adress=1;
    END;


CREATE TRIGGER AFTER_insert_passport AFTER INSERT ON Passport
WHEN EXISTS (SELECT Passport.key_passport from Passport
         WHERE Passport.id_client = NEW.id_client AND Passport.key_passport!= NEW.key_passport AND Passport.cur_passport=1)
	BEGIN
		UPDATE Passport
		SET cur_passport=0
         WHERE Passport.id_client = NEW.id_client AND Passport.key_passport!= NEW.key_passport AND Passport.cur_passport=1;
    END;

   
CREATE TRIGGER update_on_Period_Exis AFTER UPDATE OF eof_bop ON Period
WHEN EXISTS (SELECT p.key_period
             FROM Period AS p
             WHERE dates = date(OLD.dates, 'start of month', '+2 month', '-1 day') AND
                   id_contract = OLD.id_contract) AND
         NEW.eof_bop IS NOT NULL
	BEGIN 
		UPDATE Period SET
		    aum_bop = NEW.eof_bop,
            assets_gross = NULL ,
            eof_bop = NULL,
            profit_month = NULL,
            aum_change = NULL,
            aum_eop_gross = NULL,
            avg_dep = NULL,
            mf = NULL,
            sf = NULL,
            incom = NULL,
            aum_eop_net = NULL,
            aum_change_net = NULL,
            perf_net = NULL,
            perf_net_mothly = NULL,
            perf_net_annualized = NULL,
            level_0_sf = NULL,
            level_1_sf = NULL,
            qr_sf = NULL
		 WHERE dates = date(OLD.dates, 'start of month', '+2 month', '-1 day') AND
                                   id_contract = OLD.id_contract;
		 DELETE FROM Period
		 WHERE dates > date(OLD.dates, 'start of month', '+2 month', '-1 day') AND
                                   id_contract = OLD.id_contract;
	     UPDATE Period SET
	        perf_net = ((NEW.eof_bop / NEW.aum_bop) - 1) * 100,
            perf_net_mothly = 
            (((NEW.eof_bop / NEW.aum_bop) - 1) * 100) / day_of_month * strftime('%d', NEW.dates),
            perf_net_annualized = (((NEW.eof_bop / NEW.aum_bop) - 1) * 100) / NEW.day_of_month *
            		(julianday(date(NEW.dates, 'start of year', '+1 year')) - julianday(date(NEW.dates, 'start of year')))
        WHERE key_period = new.key_period;
END;


CREATE TRIGGER update_on_Period_Not_Exis BEFORE UPDATE OF eof_bop ON Period
WHEN NOT EXISTS (SELECT p.key_period
                 FROM Period AS p
                 WHERE dates = date(OLD.dates, 'start of month', '+2 month', '-1 day') AND
                       id_contract = OLD.id_contract) AND
         NEW.eof_bop IS NOT NULL
	BEGIN 
		INSERT INTO Period (
			dates,
            day_of_month,
            aum_bop,
            id_contract
		)
		VALUES (
            date(OLD.dates, 'start of month', '+2 month', '-1 day'),
            strftime('%d', date(OLD.dates, 'start of month', '+2 month', '-1 day')),
			NEW.eof_bop,
			OLD.id_contract
		);
	
	    UPDATE Period SET
	        perf_net = ((NEW.eof_bop / NEW.aum_bop) - 1) * 100,
            perf_net_mothly = 
            (((NEW.eof_bop / NEW.aum_bop) - 1) * 100) / day_of_month * strftime('%d', NEW.dates),
            perf_net_annualized = (((NEW.eof_bop / NEW.aum_bop) - 1) * 100) / NEW.day_of_month *
            		(julianday(date(NEW.dates, 'start of year', '+1 year')) - julianday(date(NEW.dates, 'start of year')))
        WHERE key_period = new.key_period;
END;

CREATE TRIGGER update_on_Period_SF_1 AFTER UPDATE OF sf ON Period
WHEN NEW.sf IS NOT NULL
	BEGIN 
		UPDATE Period SET
            level_0_sf = ROUND(NEW.sf * 0.03, 2),
            level_1_sf = ROUND(NEW.sf * 0.1, 2),
            qr_sf = ROUND(NEW.sf - (NEW.sf * 0.13), 2)
        WHERE key_period = new.key_period;
END;

CREATE TRIGGER update_incom AFTER UPDATE OF incom ON Period
WHEN NEW.incom IS NOT NULL
	BEGIN 
		INSERT INTO Income
		(income, id_contract, id_period)
		VALUES(NEW.incom, NEW.id_contract, NEW.key_period);
END;