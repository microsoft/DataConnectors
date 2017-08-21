let
    source = TripPin.Contents(),
    data = source{[Name="People"]}[Data]
in
    Table.Schema(data)
