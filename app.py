"""
 No doc
"""

from os import curdir, sep as os_sep
import sqlite3
import pandas as pd
import streamlit as st
import plotly.express as px
import plotly.graph_objects as go
from PIL import Image
from calculation import Calculation


con = sqlite3.connect(f'{curdir}{os_sep}DB_TEST')
calc = Calculation(
            file_extension='xls')


def add_line_chart(
        _data: pd.DataFrame,
        x='dates',
        y="sf",
        title=None):
    """
    No Doc
    """
    fig = go.Figure()
    if isinstance(y, list):
        for i in y:
            fig.add_trace(
                go.Scatter(
                    x=_data[x],
                    y=_data[i],
                    text=_data[i],
                    name=i,
                    textposition="top center",
                    mode="lines + markers + text",
                ))
    else:
        fig.add_trace(
            go.Scatter(
                x=_data[x],
                y=_data[y],
                name=y,
                text=_data[y],
                textposition="top center",
                mode="lines + markers + text",
            ))
    # Reward for success in

    return fig


def aum_eof(_data: pd.DataFrame, title):
    """
    No DOc
    """
    fig = add_line_chart(
        _data,
        y=["aum_bop", "eof_bop"],
        x="dates_d",
        title=f"income output for {title}")
    return fig


def perf_gross(_data: pd.DataFrame, title):
    """
    No DOc
    """
    fig = add_line_chart(
        _data,
        y=["perf_gross", "perf_gross_p_a"],
        x="dates_d",
        title=f"net profit percentage {title}")
    return fig


def bar_chart(_data: pd.DataFrame, title):
    """
    No DOc
    """
    fig = px.bar(
        _data,
        x="dates",
        y=["profit_month",
           'aum_bop',
           'assets_gross'],
        barmode='group',
        title=f"data for {title}")
    return fig


def set_tabs(_data: pd.DataFrame):
    """
    No doc
    """
    _data['dates_d'] = pd.to_datetime(_data['dates'])

    tabs_name = [str(i) for i in _data['dates_d'].dt.year.unique().tolist()]
    tab = st.tabs(tabs=tabs_name)
    for num_tab, year_df in enumerate(tabs_name):
        data_tmp = _data.loc[
            _data['dates_d'].dt.year == int(year_df)]
        data_tmp["incom_cum"] = data_tmp["incom"].cumsum()
        data_tmp = data_tmp.round({
            "incom_cum": 2,
            "eof_bop": 2,
            "aum_change_net": 2,
            "sf": 2, "mf": 2,
            "aum_bop": 2
        })
        data_tmp.sort_values(
            by=['dates_d'],
            ascending=True,
            inplace=True)
        start = 0

        len_all = data_tmp.dropna().shape[0]
        step = 1
        len_row = 4
        with tab[num_tab]:
            while True:
                if len_all - step * len_row < 0:
                    len_row = len_all - (step - 1) * len_row
                columns_frame = st.columns(len_row)

                for num in range(start, start + len_row, 1):

                    columns_frame[num - start].metric(
                        data_tmp.iloc[num]["dates_d"].month_name(),
                        data_tmp.iloc[num]["eof_bop"],
                        data_tmp.iloc[num]["aum_change_net"],
                        label_visibility="visible")
                start, step = start + len_row, step + 1
                if len_all <= start:
                    break
            st.write(f"income output for {year_df}")

            st.plotly_chart(
                aum_eof(data_tmp, year_df), use_container_width=True)

            st.write(f"net profit percentage {year_df}")
            st.plotly_chart(
                perf_gross(data_tmp, year_df), use_container_width=True)

            st.plotly_chart(
                bar_chart(
                    data_tmp,
                    title=year_df),
                use_container_width=True)

            st.write("profit")
            st.plotly_chart(
                add_line_chart(
                    data_tmp,
                    x='dates_d',
                    y=["sf", "mf", 'incom_cum'],
                    title=year_df),
                use_container_width=True)
            st.write("данные за отчетный/выбранный период")

            st.write(
                data_tmp.set_index(
                    keys=["id_contract", "Currency_code_SF", 'type'],),
            )


def get_excel_tabs(class_calc):
    """
    No Doc
    """
    try:
        for dick in class_calc.excel_table:
            for num, items in enumerate(
                class_calc.excel_table[dick]["Currency"]
            ):
                curensy = class_calc.excel_table[dick]["Currency"][items]
                sf_act = class_calc.calculation_new(
                    curensy=curensy,
                    date=class_calc.excel_table[dick]['EOP'][num],
                    perf_gross=float(class_calc.excel_table[dick]
                                     ['Perf Gross'][num]))
                if not sf_act:
                    continue
                for item in sf_act:
                    class_calc.insert_in_calc(
                        perf_gross=(class_calc.excel_table[dick]
                                    ['Perf Gross'][num]),
                        sf_act=item,
                        date_eop=class_calc.get_dates(
                            class_calc.excel_table[dick]['EOP'][num]))
    except TypeError:
        return False

    return True


def save_file(_file):
    """
    No DOC
    """
    path_f = f'{curdir}{os_sep}input{os_sep}'
    with open(path_f + _file.name, "wb") as f:
        f.write(_file.read())


s = con.execute("SELECT * FROM View_Calculate_Pred")
min_max_df = pd.DataFrame.from_dict(
    calc.calculation_all(val_to_pred=s.fetchall()),
    orient="index", columns=[
        'id_contract',
        'dates',
        'aum_bop',
        'profit_month',
        'aum_change',
        'aum_eop_gross',
        'avg_dep',
        'mf',
        'sf',
        'incom',
        'aum_eop_net',
        'qr_perf_share',
        'aum_change_net',
        'type',
        'Currency_code_SF',
        'gr_cur_name'
    ])
#
#
#

st.set_page_config(
    page_title="Test App",
    # page_icon=f'{curdir}{os_sep}QR_ico.png',
    layout="wide",
    initial_sidebar_state="auto",
    menu_items={
        'Get Help': 'https://google.com/',
        'About': "# https://google.com/"
    })
st.title(':blue[Horns and Hooves]')

data = pd.read_sql(
    """select * from View_Nate""",
    con=sqlite3.connect(f'{curdir}{os_sep}DB_TEST'),
    )

d = list(data['id_contract'].unique())
d.append("All")
st.sidebar.markdown("Контракта")
select_contract = st.sidebar.selectbox(
    'выберите номер контракта',
    d)

with st.sidebar:
    uploaded_files = st.file_uploader(
        label='Загрузка файлов',
        accept_multiple_files=False,
        type=["xls", "xlsx"])

    if uploaded_files:

        save_file(uploaded_files)
        calc.file_name = (
            curdir + os_sep + "input" +
            os_sep + uploaded_files.name)
        st.write('DONE')
        st.write('ни чего не произойдет)')
        # calc.get_data()

        # if get_excel_tabs(calc):
        #     while True:
        #         if not calc.calculation_all():
        #             break

    # if st.button('get'):
    #     st.write("dfsdf")
    # else:
    #     st.write('нажми меня')
st.write('Demo')
if select_contract != "All":
    data = data.loc[data['id_contract'] == select_contract]
    set_tabs(data)
    pred_data = min_max_df.query(f"id_contract == {select_contract}")
else:
    col = [i for i in data.columns
           if (data[i].dtypes != object or
               i == "dates")]
    print(col)
    pred_data = min_max_df
    set_tabs(
        data[col].pivot_table(
            aggfunc="sum",
            index="dates").reset_index())

pred_data['sf_perc'] = pred_data["sf"] * 100 / pred_data["aum_eop_net"]
h = data.pivot_table(
    index=['id_contract', "Currency_code_SF", 'type'],
    values=['sf',],
    aggfunc='sum')

# st.write("success fee on the contract")
st.write("Полные данные")
st.write(data.set_index(
        keys=["id_contract", "Currency_code_SF", 'type'],))

st.write("Расчитанные данные по всем \"стратегиям\"")
st.write(pred_data.set_index(
        keys=["id_contract", "Currency_code_SF", 'type'],))

st.write("\"Вознаграждение за успех\" для всех групп контрактов\
         (разделенных по использованной стратегии и способа расчета комиссий)\
         в процентах")
d = pred_data.pivot_table(
    index=["id_contract", "Currency_code_SF", 'type'],
    columns="dates",
    values='sf_perc',
    )

d['sum_sf_perc'] = d.agg(axis=1, func='sum')
d.sort_values(
    by='sum_sf_perc',
    ascending=False,
    inplace=True)
d = d.join(h, how="left")
st.write(
    d.style
    .apply(
        func=lambda x: [
            'background-color:grey;'
            if x['sf'] in h.values else '' for i in x], axis=1)
    .format('{:.2f}', subset=["sf"])
)

d.reset_index(inplace=True)
if d['sf'].isna().values[0]:

    st.write('максимально возможный процент вознаграждения,\
при использовании текущих ставок и стратегий')
    st.write('расчитывается как отношение вычесленной суммы\
             вознаграждения  к сумме средств на конец периода,\
             (до вычета комиссий) в процентах.')

    d['sf'] = d.agg(
        axis=1,
        func=lambda x:
        round(
            d.loc[
                (d["id_contract"] == x["id_contract"]) &
                (~d['sf'].isna()), 'sf'].item() *
            x['sum_sf_perc'] /
            d.loc[
                (d["id_contract"] == x["id_contract"]) &
                (~d['sf'].isna()), 'sum_sf_perc'].item(),
            2))
    d.set_index(
        keys=["id_contract", "Currency_code_SF", 'type'],
        inplace=True)
    st.write(
        d.style
        .apply(
            func=lambda x: [
                'background-color:grey;'
                if x['sf'] in h.values else '' for i in x], axis=1)
        .format('{:.2f}', subset=["sf"])
    )

st.write("Если провести аналогидные расчеты для\
         среств находящихся под управлением, их\
         можно предоставить клиенту, как обоснование\
         смены стратегии")
# st.write("При накоплении достатоного числа исторических данных\
#          станет возможным использование модели, для предсказания\
#          результата.")

st.write("структура базы данных:")
st.image(Image.open(f'{curdir}{os_sep}DB_TEST.png'),)
