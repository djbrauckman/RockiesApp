import requests
import pandas as pd
from pandas import DataFrame
from os import path
import datetime
import sys

def gameday_info_csv():
    # Set data directory to same path as this file for output placement

    ### MODIFY THIS TO YOUR DESIRED PATH ###
    DATA_DIR = 'C:/Users/djbra/PycharmProjects/RockiesDataEngineerEx'

    # Prompt for date input and validate format
    date_input = input("Enter date for game information as YYYY-MM-DD: ")
    format = "%Y-%m-%d"
    try:
        datetime.datetime.strptime(date_input, format)
    except ValueError:
        print('Invalid date string! Please enter as YYYY-MM-DD')
        sys.exit(1)

    # Strip date input into separate variables to fit URL formatting
    year = (date_input[:4])
    month = (date_input[5:7])
    day = (date_input[8:])

    # Set the data's base URL to use in concatenation with parameters later
    base_url = 'https://gd2.mlb.com/components/game/mlb/'

    # Concatenate the base URL with the parameter portion
    gmday_url = (base_url + f'year_{year}/month_{month}/day_{day}/grid.json')

    # Extract data from API URL built out above
    resp_gmdayurl = requests.get(gmday_url)

    # Use pandas to create a dataframe from json data
    df_gmday = DataFrame(resp_gmdayurl.json()['data']['games'])

    # Use pandas .json_normalize to break out the rest of the nested json data into a new dataframe
    df_gmday_flatten = pd.json_normalize(df_gmday["game"])

    # Drop unneccessary column prior to CSV creation when inserted
    df_gmday_flatten = df_gmday_flatten.drop('game_media.homebase.media', axis=1, errors='ignore')

    # Convert DataFrame to csv file in desired directory specified above
    df_gmday_flatten.to_csv(path.join(DATA_DIR, f'{year}-{month}-{day}_gameday_info.txt'), index=False)


if __name__ == '__main__':
    gameday_info_csv()
