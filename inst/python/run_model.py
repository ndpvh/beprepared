def run_model(model, 
              configs, 
              keys):
    
    # Transform the configuration dataframes to an object
    config = dfs_to_object(
        configs, 
        keys
    )

    # Within these configurations, change some of the values so that they adhere
    # to the types imposed by QVEmod. 
    columns = [
        'AirCellSize', 
        'MobilityCellSize',
        'AgentReach',
        'CleaningInterval',
        'Diffusivity',
        'CoughingRate',
        'CoughingFactor'
    ]
    for column in columns:
        config['env'][column] = int(np.round(config['env'][column]))

    columns = [
        'AerosolContaminationWriteInterval', 
        'AerosolContaminationPrecision',
        'DropletContaminationWriteInterval',
        'DropletContaminationPrecision',
        'SurfaceContaminationWriteInterval',
        'SurfaceContaminationPrecision'
    ]
    for column in columns:
        config['output'][column] = int(np.round(config['output'][column]))

    # Run the model
    model.run(config)