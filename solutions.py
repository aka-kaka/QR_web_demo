"""_summary_
Returns:
    _type_: _description_
"""

import re
import sqlite3
from os import curdir, sep as os_sep


from my_exception import MyException
from my_iter import GetData


class InsertDataBD(GetData):
    """
    NO doc
    """
    def __init__(
            self, data=None,
            connections=f'{curdir}{os_sep}DB_TEST',
            file_extension='doc',
            file_name=None,
            ):
        self.data = data if data else {}
        self.file_extension = file_extension
        self.connections = sqlite3.connect(connections)
        self.key_account_numb = None
        self.key_bank_name = None
        self.key_contract = None
        self.contract_komment = ''
        self.key_client = '123'
        super().__init__(
            file_extension=file_extension,
            file_name=file_name)

    @staticmethod
    def get_for_db(sql: str,
                   task: tuple,
                   conn: sqlite3.Connection) -> list:
        """
        Create a new task
        :param conn:
        :param task:
        :return: key_
        """
        cur = conn.cursor()
        cur.execute(sql, task)
        return cur.fetchall()

    @staticmethod
    def save_in_database(sql: str,
                         task: tuple,
                         conn: sqlite3.Connection) -> int:

        """
        No Doc

        """
        pass

    def __exit__(self, types, value, traceback):
        self.connections.close()

    def insert_in_bank_name(self):
        """
        No Doc

        """
        pass

    def insert_in_bank_account_number(self):
        """
        No Doc

        """
        pass

    def insert_in_contract(self):
        """
        No Doc

        """
        pass

    def insert_in_currency(self, items):
        """
        No Doc

        """
        pass

    def insert_in_client_fl(self):
        """
        No Doc

        """
        pass

    def insert_in_client_yl(self):
        """
        No Doc

        """
        pass

    def str_float(self, tmp: str):
        """
        No DOc
        """
        return re.sub("[^0-9.]", "", tmp).strip(".")

    def only_digit(self, tmp: str):
        """
        No DOc
        """
        return int(re.sub("[^0-9]", "", tmp))

    def get_dates(self, date_str: str):
        """
        No DOc
        """
        return '-'.join([
            i for i in self.str_float(date_str).split(".")[-1::-1]
            if i.isdigit()])

    def insert_in_email(self, key_client=None):
        """
        No Doc

        """
        pass

    def insert_in_phone(self, key_client=None):
        """
        No Doc

        """
        pass

    def insert_in_passport(self, key_client=None):
        """
        No Doc

        """
        pass

    def insert_in_addres(self, key_client=None):
        """
        No Doc

        """
        pass

    def insert_in_sf_type(self, type_sf: str):
        """
        NO DOC
        """
        if not type_sf:
            en = ["Strategy",]
            ru = ["Вознаграждение Success Fee",]

            if en[0] in self.data:
                type_sf = self.data[en[0]].strip().capitalize()

            elif ru[0] in self.data:
                type_sf = self.data[ru[0]].strip().capitalize()
            else:
                return 111111111111
        else:
            type_sf = type_sf.strip().capitalize()
        key = self.get_for_db(
            sql="""
            SELECT key_success_fee_type
            FROM Success_Fee_Type
            WHERE type = ?;
                """,
            task=(type_sf,),
            conn=self.connections)
        if key:
            return key[0][0]
        else:
            raise MyException('нет такого типа для SF',
                              "insert_in_sf_type",
                              "Проверьте поле \"Вознаграждение Success Fee\"")

    def insert_in_groups(self,
                         id_success_fee_currency=None,
                         id_success_fee_type=None) -> int:
        """
        No DOc
        """
        if not all((id_success_fee_currency,
                    id_success_fee_type)):
            en = ["Strategy",]
            ru = ["Валюта ставки для Success Fee",
                  "Вознаграждение Success Fee",]

            if en[0] in self.data:
                tmp = en
            elif ru[0] in self.data:
                tmp = ru
            else:
                return 111111111111

        id_success_fee_currency = self.insert_in_currency(self.data[tmp[0]])

        id_success_fee_type = self.insert_in_sf_type(self.data[tmp[1]])
        key = self.get_for_db(
            sql="""
            SELECT key_groups
            FROM Groups
            WHERE id_success_fee_currency = ? AND
                  id_success_fee_type = ?;
                """,
            task=(id_success_fee_currency,
                  id_success_fee_type,),
            conn=self.connections)
        if key:
            return key[0][0]
        else:
            return self.save_in_database(
                sql="""
                INSERT INTO Groups
                (id_success_fee_currency, id_success_fee_type)
                VALUES(?, ?);""",
                task=(id_success_fee_currency,
                      id_success_fee_type,),
                conn=self.connections)

    def insert_in_calc(self,
                       sf_act,
                       perf_gross,
                       date_eop):
        """
        no doc
        """

        success_fee_act, key_groups, _, perf_gross_p_a = sf_act

        key = self.get_for_db(
            sql="""
            SELECT key_calculation
            FROM Calculation
            WHERE dates = ? and id_group = ?""",
            task=(date_eop, key_groups),
            conn=self.connections)

        if key:
            return key[0][0]

        _ = self.save_in_database(
            sql="""INSERT INTO Calculation
            (success_fee_act, perf_gross_p_a, perf_gross, dates, id_group)
            VALUES(?, ?, ?, ?, ?);""",

            task=(success_fee_act,
                  perf_gross_p_a,
                  perf_gross,
                  date_eop,
                  key_groups),

            conn=self.connections)

