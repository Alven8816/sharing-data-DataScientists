%$SPARK_HOME/bin/pyspark  --packages graphframes:graphframes:0.1.0-spark1.6

from graphframes import *
import pandas as pd
import os
import json

os.chdir(WD)

# GSW player IDs
playerids = [201575,201578,2738,202691,101106,2760,2571,203949,203546,
203110,201939,203105,2733,1626172,203084]

# Calling API and store the results as JSON
for playerid in playerids:
    os.system('curl "http://stats.nba.com/stats/playerdashptpass?'
        'DateFrom=&'
        'DateTo=&'
        'GameSegment=&'
        'LastNGames=0&'
        'LeagueID=00&'
        'Location=&'
        'Month=0&'
        'OpponentTeamID=0&'
        'Outcome=&'
        'PerMode=Totals&'
        'Period=0&'
        'PlayerID={playerid}&'
        'Season=2015-16&'
        'SeasonSegment=&'
        'SeasonType=Regular+Season&'
        'TeamID=0&'
        'VsConference=&'
        'VsDivision=" > {playerid}.json'.format(playerid=playerid))


# Parse JSON files and create pandas DataFrame
raw = pd.DataFrame()
for playerid in playerids:
    with open("{playerid}.json".format(playerid=playerid)) as json_file:
        parsed = json.load(json_file)['resultSets'][0]
        raw = raw.append(
            pd.DataFrame(parsed['rowSet'], columns=parsed['headers']))

raw = raw.rename(columns={'PLAYER_NAME_LAST_FIRST': 'PLAYER'})

# Save passes.csv for plotting
raw[raw['PASS_TO']
.isin(raw['PLAYER'])][['PLAYER', 'PASS_TO','PASS']].to_csv(
	'passes.csv', index=False)

raw['id'] = raw['PLAYER'].str.replace(', ', '')

# Make raw vertices
pandas_vertices = raw[['PLAYER', 'id']].drop_duplicates()
pandas_vertices.columns = ['name', 'id']

# Make raw edges
pandas_edges = pd.DataFrame()
for passer in raw['id'].drop_duplicates():
    for receiver in raw[(raw['PASS_TO'].isin(raw['PLAYER'])) &
     (raw['id'] == passer)]['PASS_TO'].drop_duplicates():
        pandas_edges = pandas_edges.append(pd.DataFrame(
        	{'passer': passer, 'receiver': receiver
        	.replace(  ', ', '')}, 
        	index=range(int(raw[(raw['id'] == passer) &
        	 (raw['PASS_TO'] == receiver)]['PASS'].values))))

pandas_edges.columns = ['src', 'dst']

# Bring the local vertices and edges to Spark
vertices = sqlContext.createDataFrame(pandas_vertices)
edges = sqlContext.createDataFrame(pandas_edges)

# Analysis part
g = GraphFrame(vertices, edges)
print("vertices")
g.vertices.show()
print("edges")
g.edges.show()
print("inDegrees")
g.inDegrees.sort('inDegree', ascending=False).show()
print("outDegrees")
g.outDegrees.sort('outDegree', ascending=False).show()
print("degrees")
g.degrees.sort('degree', ascending=False).show()
print("labelPropagation")
g.labelPropagation(maxIter=5).show()
g.labelPropagation(maxIter=5).toPandas().to_csv("groups.csv", index=False)
print("pageRank")
g.pageRank(resetProbability=0.15, tol=0.01).vertices.sort(
    'pagerank', ascending=False).show()
g.pageRank(resetProbability=0.15, tol=0.01).vertices.toPandas().to_csv(
    "size.csv", index=False)
