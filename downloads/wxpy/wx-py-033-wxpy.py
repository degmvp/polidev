5 - Group Normalization
def group_normalize(data, groups):

    unique_groups = np.unique(groups)

    result = np.zeros_like(data, dtype=float)

    for g in unique_groups:

        mask = groups == g

        group_data = data[mask]

        result[mask] = (
            group_data - group_data.mean()
        ) / (
            group_data.std() + 1e-8
        )

    return result