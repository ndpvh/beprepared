# Utility function for transforming a dataframe to an object. Is used on several
# occasions to ensure the data.frame that we are giving from R is correctly 
# interpreted as containing the arguments for the underlying Python functions.
def df_to_object(df):
    """"Transform dataframe to object

    Parameters
    ----------
    df : pd.DataFrame
        Pandas dataframe with a single row containing all values to the arguments
        you want to pass along.

    Return
    ------
    object : 
        Object containing the argument names as keys and the values of the 
        dataframe as its values.
    """

    # Get the column names, which will serve as keys to the object
    keys = df.columns

    # Loop over all keys and create the object of interest
    obj = {}
    for i in keys:
        obj[i] = df[i].values[0]

    return obj

# Utility function for transforming multiple dataframes to a single object with 
# the specified keys. Is used as a replacement of the json-based configurations
# so that we can use data.frames for the configuration instead.
def dfs_to_object(df, keys):
    """"Transform dataframes to object

    Parameters
    ----------
    df : list
        List of R data.frames with a single row containing all values to the 
        arguments you want to pass along.
    keys : array
        Array of keys to use for the data.frames in df. Should be of the same 
        size as df

    Return
    ------
    object : 
        Object containing the objects with the argument names as keys and the 
        values of the dataframe as its values under the specified values of 
        keys.
    """

    # Loop over all keys and create the object of interest
    obj = {}
    for i in range(len(keys)):
        obj[keys[i]] = df_to_object(df[i])

    return obj

# Simple function that will select the row with the correct id and then 
# manipulate it in such a way that it will lead for easy calling of the 
# arguments in the translation functions
def select(df, id):
    """"Select values related to id from dataframe

    Besides selecting a specific row, this function will also transform all 
    values of the selected arguments to floats.

    Parameters
    ----------
    df : pd.DataFrame
        Pandas dataframe containing multiple rows with arguments to pass along 
        to functions defined in QVEmod. 
    id : str
        String denoting the value of column "id" to select on.

    Return
    ------
    pd.DataFrame :
        Pandas dataframe with a single row containing the arguments to pass along
    """

    df = df.loc[df['id'] == id]
    df = df.drop('id', axis = 1)

    for column in df:
        df[column] = df[column].astype(float)

    return df