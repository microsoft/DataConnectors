let
    source = TripPin.Contents(),
    data = source{[Name = "People"]}[Data],
    withRowCount = Table.AddIndexColumn(data, "Index")
in
    withRowCount
