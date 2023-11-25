import mysql.connector
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


def behaviourAnalysis():
    while(True):
        print("--------------------------------------------------------------------------")
        print('''
            Select An option: 
            1. Gender Trends Across Platforms
            2. Age Trends Across Platforms
            3. Age X Genre Analysis
            4. Gender X Genre Analysis
            5. Go back
            ''')
        print("--------------------------------------------------------------------------")
        choice2=int(input())
        if(choice2==1):
            query= '''SELECT Song_Platform,
                    ROUND((SUM(CASE WHEN User_Gender = 'M' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS Male_Percentage,
                    ROUND((SUM(CASE WHEN User_Gender = 'F' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS Female_Percentage
                    FROM Song_Record
                    GROUP BY Song_Platform;
                    '''

            cursor=connection.cursor()
            cursor.execute(query)
            result=cursor.fetchall()
            
            platforms = [row[0] for row in result]
            male_counts = [row[1] for row in result]
            female_counts = [row[2] for row in result]
            
            bar_width = 0.35
            index = np.arange(len(platforms))

            plt.bar(index, male_counts, bar_width, label='Male')
            plt.bar(index + bar_width, female_counts, bar_width, label='Female')

            plt.xlabel('Platforms')
            plt.ylabel('Percentage')
            plt.title('CPercentage of Males and Females across Music Platforms')
            plt.xticks(index + bar_width / 2, platforms)
            plt.legend()

            plt.tight_layout()
            plt.show()
            
        elif(choice2==2):
            cursor=connection.cursor()
            query = '''
                SELECT Song_Platform,
                    SUM(CASE WHEN AGE >= 18 AND AGE <= 30 THEN 1 ELSE 0 END) AS Young_Count,
                    SUM(CASE WHEN AGE > 30 AND AGE <= 50 THEN 1 ELSE 0 END) AS Middle_Aged_Count,
                    SUM(CASE WHEN AGE > 50 THEN 1 ELSE 0 END) AS Older_Count
                FROM (
                    SELECT Song_Platform, 
                        FLOOR(DATEDIFF(CURRENT_DATE, User_DOB) / 365) AS AGE
                    FROM Song_Record
                ) AS AgeData
                GROUP BY Song_Platform;
            '''
            cursor.execute(query)

            # Fetch the result
            results = cursor.fetchall()

            # Separate the data for plotting
            platforms = [row[0] for row in results]
            young_counts = [row[1] for row in results]
            middle_aged_counts = [row[2] for row in results]
            older_counts = [row[3] for row in results]

            # Plotting the bar chart
            bar_width = 0.25
            index = range(len(platforms))

            plt.bar(index, young_counts, bar_width, label='Young (18-30)')
            plt.bar([i + bar_width for i in index], middle_aged_counts, bar_width, label='Middle-Aged (31-50)')
            plt.bar([i + 2 * bar_width for i in index], older_counts, bar_width, label='Older (50+)')

            plt.xlabel('Platforms')
            plt.ylabel('Count')
            plt.title('Age Group Analysis across Music Platforms')
            plt.xticks([i + bar_width for i in index], platforms)
            plt.legend()
            plt.tight_layout()
            plt.show()
        elif(choice2==3):
            cursor=connection.cursor()
            query = '''
                SELECT User_DOB, Song_Genre 
                FROM Song_Record;
            '''

            cursor.execute(query)
            data=cursor.fetchall()
            result=pd.DataFrame(data,columns=["User_DOB","Song_Genre"])

            # Define age groups
            def get_age_group(birth_year):
                age = pd.Timestamp('now').year - pd.to_datetime(birth_year).year
                if age < 18:
                    return 'Under 18'
                elif 18 <= age < 30:
                    return '18-29'
                elif 30 <= age < 45:
                    return '30-44'
                else:
                    return '45+'

            # Create 'Age_Group' column based on User_DOB
            result['Age_Group'] = result['User_DOB'].apply(get_age_group)

            # Group by Age_Group and Song_Genre and count occurrences
            grouped_data = result.groupby(['Age_Group', 'Song_Genre']).size().reset_index(name='Genre_Count')

            # Plotting pie charts for each age group
            age_groups = grouped_data['Age_Group'].unique()
            for age_group in age_groups:
                data = grouped_data[grouped_data['Age_Group'] == age_group]
                plt.figure(figsize=(8, 6))
                plt.pie(data['Genre_Count'], labels=data['Song_Genre'], autopct='%1.1f%%', startangle=140)
                plt.title(f'Genre Distribution for {age_group} Age Group')
                plt.axis('equal')  # Equal aspect ratio ensures that pie is drawn as a circle.
                plt.show()

            
            
        elif(choice2==4):
            # Create a cursor to execute queries
            cursor = connection.cursor()

            # SQL query to get total plays per gender
            total_plays_query = '''
                SELECT User_Gender, COUNT(*) AS Total_Plays
                FROM Song_Record
                GROUP BY User_Gender
            '''

            # Execute query to get total plays per gender
            cursor.execute(total_plays_query)
            total_plays_data = cursor.fetchall()

            # Create a dictionary to store total plays for each gender
            total_plays = {gender: plays for gender, plays in total_plays_data}

            # SQL query to get genre-wise plays per gender
            query = '''
                SELECT sr.User_Gender,
                    sr.Song_Genre,
                    COUNT(*) AS Genre_Plays
                FROM Song_Record sr
                GROUP BY sr.User_Gender, sr.Song_Genre
                ORDER BY sr.User_Gender, Genre_Plays DESC;
            '''

            # Execute query
            cursor.execute(query)

            # Fetch all results
            data = cursor.fetchall()

            # Create a DataFrame from fetched data
            df = pd.DataFrame(data, columns=['User_Gender', 'Song_Genre', 'Genre_Plays'])

            # Close cursor and database connection
            cursor.close()

            # Calculate percentages for each genre within each gender category
            df['Percentage'] = df.apply(lambda x: (x['Genre_Plays'] / total_plays[x['User_Gender']]) * 100, axis=1)

            # Filter data for male and female separately
            male_data = df[df['User_Gender'] == 'M']
            female_data = df[df['User_Gender'] == 'F']

            # Create figure and subplots for both pie charts
            fig, axes = plt.subplots(nrows=1, ncols=2, figsize=(14, 6))

            # Create pie chart for Male
            axes[0].pie(male_data['Percentage'], labels=male_data['Song_Genre'], autopct='%1.1f%%', startangle=140)
            axes[0].set_title('Genre Popularity Among Males')
            axes[0].axis('equal')  # Equal aspect ratio ensures that pie is drawn as a circle

            # Create pie chart for Female
            axes[1].pie(female_data['Percentage'], labels=female_data['Song_Genre'], autopct='%1.1f%%', startangle=140)
            axes[1].set_title('Genre Popularity Among Females')
            axes[1].axis('equal')  # Equal aspect ratio ensures that pie is drawn as a circle

            # Adjust layout and display pie charts
            plt.tight_layout()
            plt.show()

        elif(choice2==5):
            return
        else:
            print("Invalid Choice!")
    
def artistPopularity():
    while(True):
        print("--------------------------------------------------------------------------")
        print('''
              Select an option:
              1. Top 3 most followed Artist across all platform
              2. Top 3 most followed Artist on each platform
              3. Go Back
              ''')
        choice3=int(input())
        if(choice3==1):
            cursor = connection.cursor()

            # SQL query to get top 3 most followed artists
            query = '''
                SELECT Artist_Name, 
                    (followers_spotify + followers_ressso + followers_youtube + followers_apple) AS Total_Followers
                FROM Artist
                ORDER BY Total_Followers DESC
                LIMIT 3;
            '''

            # Execute query
            cursor.execute(query)

            # Fetch all results
            data = cursor.fetchall()

            # Create a DataFrame from fetched data
            df = pd.DataFrame(data, columns=['Artist_Name', 'Total_Followers'])

            # Close cursor and database connection
            cursor.close()

            # Plotting
            plt.figure(figsize=(10, 6))
            plt.bar(df['Artist_Name'], df['Total_Followers'], color='skyblue')
            plt.xlabel('Artist')
            plt.ylabel('Total Followers')
            plt.title('Top 3 Most Followed Artists Across Platforms')
            plt.xticks(rotation=45, ha='right')
            plt.tight_layout()

            # Show plot
            plt.show()
        elif(choice3==2):
            cursor = connection.cursor()

            # Define queries for each platform
            spotify_query = "SELECT Artist_Name, followers_spotify AS followers FROM Artist ORDER BY followers_spotify DESC LIMIT 3;"
            resso_query = "SELECT Artist_Name, followers_ressso AS followers FROM Artist ORDER BY followers_ressso DESC LIMIT 3;"
            youtube_query = "SELECT Artist_Name, followers_youtube AS followers FROM Artist ORDER BY followers_youtube DESC LIMIT 3;"
            apple_query = "SELECT Artist_Name, followers_apple AS followers FROM Artist ORDER BY followers_apple DESC LIMIT 3;"

            # Execute queries
            cursor.execute(spotify_query)
            spotify_results = cursor.fetchall()

            cursor.execute(resso_query)
            resso_results = cursor.fetchall()

            cursor.execute(youtube_query)
            youtube_results = cursor.fetchall()

            cursor.execute(apple_query)
            apple_results = cursor.fetchall()

            # Close cursor and database connection
            cursor.close()

            # Process the results for plotting
            platforms = ['Spotify', 'Resso', 'YouTube', 'Apple']
            results = [spotify_results, resso_results, youtube_results, apple_results]

            # Plotting bar charts for each platform
            plt.figure(figsize=(12, 8))
            for i in range(len(platforms)):
                artists = [row[0] for row in results[i]]
                followers = [row[1] for row in results[i]]

                plt.subplot(2, 2, i + 1)
                plt.barh(artists, followers, color='skyblue')
                plt.xlabel('Followers')
                plt.title(f'Top 3 Artists on {platforms[i]}')

            plt.tight_layout()
            plt.show()
        elif(choice3==3):
            return
        else:
            print("Invalid Choice !")
    return
def trendingMusic():
    cursor = connection.cursor()
    query ='''SELECT
    Song_Name,
        COUNT(*) AS Play_Count
        FROM
        Song_Record
        GROUP BY
        Song_Name
        ORDER BY
        Play_Count DESC
        LIMIT 10;'''

    cursor.execute(query)

# Fetch the results
    result = cursor.fetchall()

    # Separate the results into lists for plotting
    song_names = [row[0] for row in result]
    play_counts = [row[1] for row in result]

    # Plotting the data
    plt.figure(figsize=(10, 6))
    plt.bar(song_names, play_counts, color='skyblue')
    plt.title('Top 10 Trending Songs - Play Count')
    plt.xlabel('Song Name')
    plt.ylabel('Play Count')
    plt.xticks(rotation=45, ha='right')  # Rotate x-axis labels for better visibility
    plt.tight_layout()

    # Show the plot
    plt.show()

    # Close cursor and connection
    cursor.close()
            
    return
def emergingArtist():
    cursor=connection.cursor()
    # Get user input for n
    n = int(input("Enter the value of n: "))

    # SQL query to find the top n artists
    sql_query = f'''
        SELECT Song_Artist, COUNT(*) AS Artist_Count
        FROM Song_Record
        GROUP BY Song_Artist
        ORDER BY Artist_Count DESC
        LIMIT {n};
    '''

    # Execute the query and fetch results
    cursor.execute(sql_query)
    results = cursor.fetchall()
    print(f"Top {n} Artists:")
    for artist, count in results:
        print(f"{artist}: {count} plays")

    # Draw a pie chart
    labels = [artist for artist, _ in results]
    sizes = [count for _, count in results]

    plt.pie(sizes, labels=labels, autopct='%1.1f%%', startangle=140)
    plt.axis('equal')  # Equal aspect ratio ensures that pie is drawn as a circle.
    plt.title(f'Top {n} Artists')
    plt.show()
    return

    
def geoAnalysis():
    while(True):
        print("--------------------------------------------------------------------------")
        print('''
              Select an option :
              1. Location X Genre Analysis
              2. Location X Music Analysis
              3. Go Back
              ''')
        choice4=int(input())
        if(choice4==1):
            cursor=connection.cursor()
            query = '''
                SELECT SR.User_Location, SR.Song_Genre, COUNT(*) AS Genre_Count
                FROM Song_Record SR
                GROUP BY SR.User_Location, SR.Song_Genre
                ORDER BY SR.User_Location, Genre_Count DESC;
            '''
            cursor.execute(query)
            data=cursor.fetchall()

            result = pd.DataFrame(data, columns=['User_Location', 'Song_Genre', 'Genre_Count'])

            # Pivot the data for plotting
            pivot_data = result.pivot(index='User_Location', columns='Song_Genre', values='Genre_Count')

            # Plotting
            pivot_data.plot(kind='bar', stacked=True)
            plt.xlabel('User Location')
            plt.ylabel('Genre Count')
            plt.title('Genre Distribution Across Locations (from Song_Record)')
            plt.legend(title='Genre')
            plt.xticks(rotation=45)
            plt.tight_layout()
            plt.show()
            
        elif(choice4==2):
            cursor=connection.cursor()
            query = '''
                SELECT User_Location, Song_Name, Song_Count
                FROM (
                    SELECT 
                        User_Location,
                        Song_Name,
                        COUNT(*) AS Song_Count,
                        ROW_NUMBER() OVER (PARTITION BY User_Location ORDER BY COUNT(*) DESC) AS rn
                    FROM Song_Record
                    GROUP BY User_Location, Song_Name
                ) t
                WHERE rn <= 10
                ORDER BY User_Location, Song_Count DESC;
            '''
            cursor.execute(query)
            data=cursor.fetchall()
            result=pd.DataFrame(data, columns=['User_Location','Song_Name','Song_Count'])
            pivot_data = result.pivot(index='User_Location', columns='Song_Name', values='Song_Count')

            # Plotting (you might want to adjust the plotting type depending on the number of songs)
            pivot_data.plot(kind='bar', stacked=True, figsize=(12, 8))  # Adjust figsize if needed
            plt.xlabel('User Location')
            plt.ylabel('Song Count')
            plt.title('Top 10 Song Names Distribution Across Locations (from Song_Record)')
            plt.legend(title='Song Name', bbox_to_anchor=(1.05, 1), loc='upper left')  # Adjust legend position
            plt.xticks(rotation=45)
            plt.tight_layout()
            plt.show()

        elif(choice4==3):
            return
        else:
            print("Invalid Choice !")
    return

def marketShare():
    # cursor = connection.cursor()

    # # Define the query
    # query = '''
    #     SELECT Song_Platform,
    #         ROUND((SUM(CASE WHEN Song_Platform = 'spotify' THEN 1 ELSE 0 END) * 100.0) / (SELECT COUNT(*) FROM Song_Record), 2) AS SPOTIFY,
    #         ROUND((SUM(CASE WHEN Song_Platform = 'resso' THEN 1 ELSE 0 END) * 100.0) / (SELECT COUNT(*) FROM Song_Record), 2) AS RESSO,
    #         ROUND((SUM(CASE WHEN Song_Platform = 'apple_music' THEN 1 ELSE 0 END) * 100.0) / (SELECT COUNT(*) FROM Song_Record), 2) AS APPLE_MUSIC,
    #         ROUND((SUM(CASE WHEN Song_Platform = 'YouTube Music' THEN 1 ELSE 0 END) * 100.0) / (SELECT COUNT(*) FROM Song_Record), 2) AS YOUTUBE_MUSIC
    #     FROM Song_Record
    #     GROUP BY Song_Platform;
    # '''

    # # Execute the query
    # cursor.execute(query)

    # # Fetch all results
    # results = cursor.fetchall()

    # # Close cursor and database connection
    # cursor.close()

    # # Extract platform names and percentages
    # labels = ['Spotify', 'Resso', 'Apple Music', 'YouTube Music']
    # sizes = [row[1:] for row in results]

    # platform_percentages = list(map(list, zip(*sizes)))

    # # Plotting the pie chart
    # explode = (0.1, 0, 0, 0)  # explode 1st slice
    # plt.pie(platform_percentages[0], explode=explode, labels=labels, autopct='%1.1f%%', shadow=True, startangle=140)
    # plt.axis('equal')  # Equal aspect ratio ensures that pie is drawn as a circle.
    # plt.title('Market Share of Music Platforms')
    # plt.show()

    cursor = connection.cursor()


    # Define the query
    query = '''
            SELECT 
                Song_Platform,
                ROUND((COUNT(CASE WHEN Song_Platform = 'spotify' THEN 1 END) * 100.0) / (SELECT COUNT(*) FROM Song_Record), 2) AS Spotify,
                ROUND((COUNT(CASE WHEN Song_Platform = 'resso' THEN 1 END) * 100.0) / (SELECT COUNT(*) FROM Song_Record), 2) AS Resso,
                ROUND((COUNT(CASE WHEN Song_Platform = 'Youtube_Music' THEN 1 END) * 100.0) / (SELECT COUNT(*) FROM Song_Record), 2) AS YouTube,
                ROUND((COUNT(CASE WHEN Song_Platform = 'apple_music' THEN 1 END) * 100.0) / (SELECT COUNT(*) FROM Song_Record), 2) AS Apple
            FROM Song_Record
            GROUP BY Song_Platform;
    '''

    # Execute the query
    cursor.execute(query)

    # Fetch all results
    results = cursor.fetchall()



    # Close cursor and database connection
    cursor.close()

    # Extract platform names and percentages
    platforms = [row[0] for row in results]
    percentages = [list(row[1:]) for row in results]

    # Transpose the percentages list for proper data representation in bar chart
    platform_percentages = list(map(list, zip(*percentages)))

    # Plotting the bar chart
    labels = ['Spotify', 'Resso', 'YouTube', 'Apple']
    x = range(len(labels))

    plt.figure(figsize=(10, 6))
    for i, platform in enumerate(platforms):
        plt.bar(x, platform_percentages[i], label=platform)

    plt.xlabel('Platforms')
    plt.ylabel('Percentage of Plays')
    plt.title('Market Share of Music Platforms')
    plt.xticks(x, labels)
    plt.legend()
    plt.tight_layout()
    plt.show()
    
    
import mysql.connector


if __name__=='__main__':
    # Replace these with your MySQL database credentials
    hostname = "localhost"
    username = "root"
    password = "root"
    database_name = "global_music"

    try:
        # Establishing a connection to the database
        connection = mysql.connector.connect(
            host=hostname,
            user=username,
            password=password,
            database=database_name
        )

    except mysql.connector.Error as e:
        print(f"Error connecting to global_music database")
    
    print("==============================================================================")
    print("=======================  Welcome to Music Analyzer  ==========================")
    while(True):
        print('''
            Select An Option : 
            1. Behaviour Analysis
            2. Artist Wise Popularity
            3. Trending Music
            4. Emerging Artist
            5. Geographical Analysis
            6. Market Share Analysis
            7. Exit
            ''')
        print("--------------------------------------------------------------------------")
        choice=int(input())
        if(choice==1):
            behaviourAnalysis()
        elif(choice ==2):
            artistPopularity()
        elif(choice==3):
            trendingMusic()
        elif(choice==4):
            emergingArtist()
        elif(choice==5):
            geoAnalysis()
        elif(choice==6):
            marketShare()
        elif(choice==7):
            break
        else:
            print("Invalid Choice! ")
