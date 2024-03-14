/*
DROP TABLE IF EXISTS Passport;
DROP TABLE IF EXISTS Client;
DROP TABLE IF EXISTS Adress;
DROP TABLE IF EXISTS Phone;
DROP TABLE IF EXISTS Email;
DROP TABLE IF EXISTS Company;
DROP TABLE IF EXISTS Contract;
DROP TABLE IF EXISTS Period;
DROP TABLE IF EXISTS Bank_Account_Number;
DROP TABLE IF EXISTS Bank_Name;
DROP TABLE IF EXISTS Calculation;

-- DROP TABLE IF EXISTS Currency;
-- DROP TABLE IF EXISTS Success_Fee;
-- DROP TABLE IF EXISTS Success_Fee_Type
-- DROP TABLE IF EXISTS QR_Limit;
-- DROP TABLE IF EXISTS Client_Type;

DROP TABLE IF EXISTS Log_Contract;
DROP TABLE IF EXISTS Income;
DROP TABLE IF EXISTS Groups;

DROP TABLE IF EXISTS Client;
*/

CREATE TABLE Client (
	key_client INTEGER PRIMARY KEY AUTOINCREMENT,
	name TEXT(50) NOT NULL,
	last_name TEXT(20),
	middle_name TEXT(20),
	date_of_birth TEXT,
	place_of_birth TEXT,
	tin TEXT(20) NOT NULL,
	id_client_type INTEGER DEFAULT 0
);


CREATE TABLE Passport (
	key_passport INTEGER PRIMARY KEY AUTOINCREMENT,
	passp_series TEXT(20), -- в отдельную таблицу паспорт
	passp_number TEXT(20) NOT NULL, -- в отдельную таблицу паспорт
	place_passport_issue TEXT(20), -- в отдельную таблицу паспорт
	date_passport_issue TEXT NOT NULL, -- в отдельную таблицу паспорт
	code_division_issue TEXT(10), -- в отдельную таблицу паспорт
	cur_passport INTEGER NOT NULL CHECK(cur_passport == 0 OR cur_passport == 1) DEFAULT 1,
	id_client INTEGER,
	FOREIGN KEY (id_client)  REFERENCES Client (key_client)
);


CREATE table Adress(
	key_adress INTEGER PRIMARY KEY AUTOINCREMENT,
	zip_code INTEGER, -- в отдельную таблицу адрес
	country_registered TEXT(15), -- в отдельную таблицу адрес
	region_registered TEXT(20), -- в отдельную таблицу адрес
	city_registered TEXT(20), -- в отдельную таблицу адрес
	strit_registered TEXT(20), -- в отдельную таблицу адрес
	house_registered TEXT(5), -- в отдельную таблицу адрес
	building_registered TEXT(20), -- в отдельную таблицу адрес
	appartament_registered TEXT(5), -- в отдельную таблицу адрес
	cur_adress INTEGER CHECK(cur_adress == 0 OR cur_adress == 1) DEFAULT 1,
	id_client INTEGER,
	FOREIGN KEY (id_client)  REFERENCES Client (key_client)
);


CREATE TABLE Phone(
	key_phone INTEGER PRIMARY KEY AUTOINCREMENT,
	phone TEXT(20) NOT NULL, -- в отдельную таблицу телефон
	cur_phone INTEGER NOT NULL CHECK(cur_phone == 0 OR cur_phone == 1) DEFAULT 1,
	id_client integer,
	FOREIGN KEY (id_client)  REFERENCES Client (key_client)
);


CREATE TABLE Email(
	key_email INTEGER PRIMARY KEY AUTOINCREMENT,
	email TEXT(25) NOT NULL, -- в отдельную таблицу телефон
	cur_email INTEGER NOT NULL CHECK(cur_email == 0 OR cur_email == 1) DEFAULT 1,
	id_client INTEGER,
	FOREIGN KEY (id_client)  REFERENCES Client (key_client)
);


CREATE TABLE Company (
	key_company INTEGER PRIMARY KEY AUTOINCREMENT,
	registration_number TEXT(50) NOT NULL,
	country_of_registration TEXT(20),
	legal_address TEXT,
	date_of_registration TEXT(10),
	CEO TEXT(50),
	id_client INTEGER,
	FOREIGN KEY (id_client)  REFERENCES Client (key_client)
);


CREATE TABLE Contract (
	key_contract INTEGER PRIMARY KEY,
	upfront_fee REAL NOT NULL DEFAULT 0.01, 
	managment_fee REAL NOT NULL DEFAULT 0.015,
	redepton_fee REAL NOT NULL  DEFAULT 0,
	success_fee_start INTEGER NOT NULL DEFAULT 0.05, -- в процентах
	contract_date TEXT(10) NOT NULL,
	cash INTEGER NOT NULL CHECK(cash == 0 OR cash == 1) DEFAULT 1, -- bool
	comments TEXT(250),
	id_client INTEGER,
	aum_bop REAL NOT NULL,
	id_currency INTEGER,
	id_groups INTEGER,
	FOREIGN KEY (id_currency)  REFERENCES Currency (key_currency),
	FOREIGN KEY (id_client)  REFERENCES Client (key_client),
	FOREIGN KEY (id_groups)  REFERENCES Groups (key_groups)
);


CREATE TABLE Period(
	key_period INTEGER PRIMARY KEY AUTOINCREMENT,
	dates TEXT(10) NOT NULL,
	day_of_month INTEGER NOT NULL DEFAULT 0,
	aum_bop REAL NOT NULL,
	assets_gross REAL,  -- полная выручка
	eof_bop REAL,
	profit_month REAL,
	aum_change REAL,
	aum_eop_gross REAL,
	avg_dep REAL,
	mf REAL,
	sf REAL,
	incom REAL,
	aum_eop_net REAL,
	aum_change_net REAL,
	id_contract INTEGER,
	perf_net REAL,
	perf_net_mothly REAL,
	perf_net_annualized REAL,
    level_0_sf REAL,
    level_1_sf REAL,
    qr_sf REAL,
	FOREIGN KEY (id_contract)  REFERENCES Contract (key_contract)
);


CREATE TABLE Bank_Account_Number (
	key_account_numb INTEGER PRIMARY KEY AUTOINCREMENT,
	bank_account_numb TEXT NOT NULL, -- в отдельную таблицу банк
	cur_bank_account INTEGER NOT NULL CHECK(cur_bank_account == 0 OR cur_bank_account == 1) DEFAULT 1,
	id_contract INTEGER,
	id_bank INTEGER,
	FOREIGN KEY (id_bank)  REFERENCES Bank_Name (key_bank),
	FOREIGN KEY (id_contract)  REFERENCES Contract (key_contract)
);


CREATE TABLE Bank_Name (
	key_bank INTEGER PRIMARY KEY AUTOINCREMENT,
	name_bank TEXT(20) NOT NULL, -- в отдельную таблицу банк
	bank_BIC INTEGER NOT NULL
);


CREATE TABLE Calculation (
	key_calculation INTEGER PRIMARY KEY AUTOINCREMENT,
	success_fee_act REAL NOT NULL,
	perf_gross REAL NOT NULL, -- процент за месяц
	perf_gross_p_a REAL, 
	dates TEXT NOT NULL,
	id_group INTEGER,
    FOREIGN KEY (id_group)  REFERENCES Groups (key_groups)
);


CREATE TABLE Currency (
	key_currency INTEGER PRIMARY KEY,
	code TEXT(4) NOT NULL,
	currency_name TEXT(50) NOT NULL
);


CREATE TABLE Log_Contract(
	key_log INTEGER PRIMARY KEY AUTOINCREMENT,
	date_change TEXT NOT NULL,
	old_value REAL NOT NULL,
	new_value REAL NOT NULL,
	id_contract INTEGER,
	difference REAL NOT NULL,
	action_cont text,
	FOREIGN KEY (id_contract)  REFERENCES Contract (key_contract)
);

CREATE TABLE Success_Fee(
	key_success_fee INTEGER PRIMARY KEY AUTOINCREMENT,
	percent INTEGER DEFAULT 5 NOT NULL,
	bring INTEGER DEFAULT 5,
	percent_sf REAL,
	id_success_fee_type INTEGER DEFAULT 0,
	FOREIGN KEY (id_success_fee_type)  REFERENCES Success_Fee_Type (key_success_fee_type)
);


CREATE TABLE Income(
	key_incom INTEGER PRIMARY KEY AUTOINCREMENT,
	income REAL NOT NULL,
	id_contract INTEGER,
	id_period INTEGER,
	FOREIGN KEY (id_contract)  REFERENCES Contract (key_contract),
    FOREIGN KEY (id_period)  REFERENCES Period (key_period)
);


CREATE TABLE Groups (
	key_groups INTEGER PRIMARY KEY,
	id_success_fee_currency INTEGER,
	id_success_fee_type INTEGER DEFAULT 0,
	FOREIGN KEY (id_currency)  REFERENCES Currency (key_currency),
	FOREIGN KEY (id_success_fee_type)  REFERENCES Success_Fee_Type (key_success_fee_type)
);


CREATE TABLE Success_Fee_Type (
	key_success_fee_type INTEGER PRIMARY KEY AUTOINCREMENT,
	diff INTEGER CHECK(diff == 0 OR diff == 1) DEFAULT 1,
	type TEXT(50) NOT NULL
);


CREATE TABLE Client_Type (
	key_client_type INTEGER PRIMARY KEY AUTOINCREMENT,
	type TEXT(50) NOT NULL,
	FOREIGN KEY (key_client_type)  REFERENCES Client (id_client_type)
);


CREATE TABLE QR_Limit (
	key_currency INTEGER PRIMARY KEY,
	min_val REAL,
	max_val REAL,
	FOREIGN KEY (key_currency)  REFERENCES Currency (key_currency)
);

