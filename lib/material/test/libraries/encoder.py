def encoder(data) -> bytes:
    """
    funcao para preferir sempre dados brutos.
    """

    if isinstance(data, str):
        data = data.encode('raw-unicode-escape')

    return bytes(data)
