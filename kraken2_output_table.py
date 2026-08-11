import pandas as pd

df = pd.read_csv('combined_table.tsv', sep='\t')
df.head()

# Split into separate columns based on the '|' delimiter
split_df = df['#Classification'].str.split('|', expand=True)
split_df.columns = ['Phylum', 'Class', 'Order', 'Family', 'Genus', 'Species'][:split_df.shape[1]]

# Combine back with the rest of your data (sample columns)
df = pd.concat([split_df, df.drop(columns=['#Classification'])], axis=1)
df.head()

df_species = df[df['Species'].notna()]
df_species
