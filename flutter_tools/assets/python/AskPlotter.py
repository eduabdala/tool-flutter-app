import argparse
import os
import sys
import csv
from dataclasses import dataclass
from typing import List
import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots

@dataclass
class Sensor:
    sensor_type: str 
    sensor_index: int
    status: str      
    min_value: float 
    value: float     
    max_value: float 

@dataclass
class Leitura:
    date: str
    time: str
    sensors: List[Sensor]

def ler_csv(file_name: str) -> List[Leitura]:
    leituras = []
    try:
        with open(file_name, 'r', newline='', encoding='utf-8') as csvfile:
            reader = csv.reader(csvfile, delimiter=';')
            for row in reader:
                tokens = [token for token in row if token]
                if len(tokens) < 2:
                    continue
                data, hora = tokens[0], tokens[1]
                sensores = []
                for i in range(2, len(tokens), 6):
                    grupo = tokens[i:i+6]
                    if len(grupo) < 6:
                        continue
                    try:
                        sensor = Sensor(
                            sensor_type=grupo[0],
                            sensor_index=int(grupo[1]),
                            status=grupo[2],
                            min_value=float(grupo[3]),
                            value=float(grupo[4]),
                            max_value=float(grupo[5])
                        )
                        sensores.append(sensor)
                    except ValueError as e:
                        print(f"Erro ao converter os dados do grupo {grupo}: {e}")
                        continue
                leitura = Leitura(date=data, time=hora, sensors=sensores)
                leituras.append(leitura)
    except Exception as e:
        print(f"Erro ao ler o arquivo {file_name}: {e}")
    return leituras

def command(args=None):
    parser = argparse.ArgumentParser(
        description="Lê e plota o gráfico de um ou mais arquivos CSV com a resposta de status do Antiskimming(SU)."
    )
    parser.add_argument("files", nargs="*", help="Um ou mais arquivos CSV para processar")
    parser.add_argument(
        "-a",
        "--all",
        action="store_true",
        help="Processa todos os arquivos .csv do diretório"
    )
    parser.add_argument(
        "-f",
        "--file",
        help="Processa um único arquivo CSV"
    )
    parser.add_argument(
        "-w",
        "--weiss",
        help="Caminho para o arquivo CSV de referência Weiss",
        default="weiss.csv"
    )
    parsed = parser.parse_args(args)
    return parser, vars(parsed)

def main(args):
    if args.get("all"):
        sensor_files = [f for f in os.listdir('.') if f.endswith('.csv') and f != args["weiss"]]
        if not sensor_files:
            print("Nenhum arquivo CSV encontrado no diretório.")
            return
    elif args.get("file"):
        sensor_files = [args["file"]]
    elif args.get("files") and len(args["files"]) > 0:
        sensor_files = args["files"]
    else:
        sensor_files = []

    weiss_file = args.get("weiss", "weiss.csv")

    for sensor_file in sensor_files:
        if not os.path.isfile(sensor_file):
            print(f"Arquivo {sensor_file} não encontrado.")
            continue

        leituras = ler_csv(sensor_file)
        sensor_data = []
        status_map = {"A": 0, "S": 1, "D": 2}

        for leitura in leituras:
            try:
                timestamp = pd.to_datetime(f"{leitura.date} {leitura.time}", format="%d/%m/%Y %H:%M:%S")
            except Exception as e:
                print(f"Erro na conversão da data/hora {leitura.date} {leitura.time}: {e}")
                continue
            
            for sensor in leitura.sensors:
                sensor_data.append({
                    'datetime': timestamp,
                    'sensor_type': sensor.sensor_type,
                    'sensor_index': sensor.sensor_index,
                    'status': sensor.status,
                    'status_numeric': status_map.get(sensor.status, None),
                    'min': sensor.min_value,
                    'value': sensor.value,
                    'max': sensor.max_value
                })
        df_sensor = pd.DataFrame(sensor_data)
        
        if df_sensor.empty:
            print(f"Nenhum dado de sensores foi carregado para o arquivo {sensor_file}.")
            continue

        df_weiss = None
        reference_exists = False
        if os.path.isfile(weiss_file):
            column_names2 = ["date", "time", "temperature", "humidity"]
            try:
                df_weiss = pd.read_csv(weiss_file, sep=";", header=None,
                                       names=column_names2, usecols=[0, 1, 2, 3])
                df_weiss["DateTime"] = df_weiss[["date", "time"]].apply(" ".join, axis=1)
                df_weiss["datetime"] = pd.to_datetime(df_weiss["DateTime"], format="%d/%m/%Y %H:%M:%S")
                reference_exists = True
            except Exception as e:
                print(f"Erro ao ler {weiss_file}: {e}")
                df_weiss = None
        else:
            print(f"Arquivo {weiss_file} não encontrado.")

        base_folder = os.path.splitext(sensor_file)[0]
        os.makedirs(base_folder, exist_ok=True)
        capacitive_folder = os.path.join(base_folder, "capacitive")
        optic_folder = os.path.join(base_folder, "optic")

        sensor_groups = list(df_sensor.groupby(['sensor_type', 'sensor_index']))
        
        for (stype, sindex), group in sensor_groups:
            stype_lower = stype.lower()
            if stype_lower == 'c':
                sensor_folder = capacitive_folder
                prefix = "Capacitive"
            elif stype_lower == 'o':
                sensor_folder = optic_folder
                prefix = "Otico"
            else:
                sensor_folder = os.path.join(base_folder, "others")
                prefix = "Tipo_desconhecido"
            os.makedirs(sensor_folder, exist_ok=True)

            if reference_exists:
                rows = 2
                specs = [[{"secondary_y": True}], [{"secondary_y": True}]]
                subplot_titles = [f"Dados do sensor", "Referência Weiss (Temperatura e Umidade)"]
            else:
                rows = 1
                specs = [[{"secondary_y": True}]]
                subplot_titles = [f"Dados do sensor"]

            fig = make_subplots(rows=rows, cols=1,
                                subplot_titles=subplot_titles,
                                specs=specs,
                                shared_xaxes=True)
            
            row = 1
            fig.add_trace(
                go.Scatter(
                    x=group['datetime'],
                    y=group['status_numeric'],
                    mode="lines",
                    name="Status",
                    line=dict(color='black', dash='dash')
                ),
                row=row,
                col=1,
                secondary_y=False
            )
            for trace_label, col_name in zip(["Value", "Min", "Max"], ["value", "min", "max"]):
                fig.add_trace(
                    go.Scatter(
                        x=group['datetime'],
                        y=group[col_name],
                        mode="lines",
                        name=trace_label
                    ),
                    row=row,
                    col=1,
                    secondary_y=True
                )
            fig.update_yaxes(
                range=[-0.2, 2.2],
                tickvals=[0, 1, 2],
                ticktext=["A", "S", "D"],
                title_text="Status",
                row=row,
                col=1,
                secondary_y=False
            )
            ad_min = group[['value', 'min', 'max']].min().min()
            ad_max = group[['value', 'min', 'max']].max().max()
            margin = (ad_max - ad_min) * 0.1 if (ad_max - ad_min) != 0 else 1
            fig.update_yaxes(
                range=[ad_min - margin, ad_max + margin],
                title_text="AD",
                row=row,
                col=1,
                secondary_y=True
            )
            
            if reference_exists:
                row = 2
                fig.add_trace(
                    go.Scatter(
                        x=df_weiss['datetime'],
                        y=df_weiss['temperature'],
                        mode="lines+markers",
                        name="Temperatura",
                        line=dict(color='red')
                    ),
                    row=row,
                    col=1,
                    secondary_y=False
                )
                fig.add_trace(
                    go.Scatter(
                        x=df_weiss['datetime'],
                        y=df_weiss['humidity'],
                        mode="lines+markers",
                        name="Umidade",
                        line=dict(color='green')
                    ),
                    row=row,
                    col=1,
                    secondary_y=True
                )
                fig.update_yaxes(title_text="Temperatura", row=row, col=1, secondary_y=False)
                fig.update_yaxes(title_text="Umidade", row=row, col=1, secondary_y=True)
            
            fig.update_layout(
                title_text=f"{prefix}_{sindex}",
                template="plotly_white",
                legend=dict(
                    x=1.02,
                    y=1,
                    xanchor="left",
                    yanchor="top"
                ),
                margin=dict(r=150)
            )
            
            fig.update_layout(
                xaxis=dict(
                    rangeslider=dict(visible=True),
                    type="date"
                )
            )
            
            html_filename = os.path.join(sensor_folder, f"{prefix}_{sindex}.html")
            png_filename = os.path.join(sensor_folder, f"{prefix}_{sindex}.png")
            
            fig.write_html(html_filename)
            
            fig_png = go.Figure(fig)
            fig_png.update_layout(
                xaxis=dict(
                    rangeslider=dict(visible=False)
                )
            )
            try:
                fig_png.write_image(png_filename)
            except Exception as e:
                print(f"Erro ao salvar a imagem {png_filename}: {e}")

if __name__ == "__main__":
    parser, args = command()
    if not (args.get("all") or args.get("file") or (args.get("files") and len(args.get("files")) > 0)):
        parser.print_help()
        sys.exit(0)
    main(args)
