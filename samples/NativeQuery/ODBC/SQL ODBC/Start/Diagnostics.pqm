let
    Diagnostics.LogValue = (prefix, value, optional delayed) => Diagnostics.Trace(TraceLevel.Information, prefix & ": " & (try Diagnostics.ValueToText(value) otherwise "<error getting value>"), value, delayed),
    Diagnostics.LogValue2 = (prefix, value, result, optional delayed) => Diagnostics.Trace(TraceLevel.Information, prefix & ": " & Diagnostics.ValueToText(value), result, delayed),    
    Diagnostics.LogFailure = (text, function) =>
        let
            result = try function()
        in
            if result[HasError] then Diagnostics.LogValue2(text, result[Error], () => error result[Error], true) else result[Value],

    Diagnostics.WrapFunctionResult = (innerFunction as function, outerFunction as function) as function =>
        Function.From(Value.Type(innerFunction), (list) => outerFunction(() => Function.Invoke(innerFunction, list))),

    Diagnostics.WrapHandlers = (handlers as record) as record =>
        Record.FromList(
            List.Transform(
                Record.FieldNames(handlers),
                (h) => Diagnostics.WrapFunctionResult(Record.Field(handlers, h), (fn) => Diagnostics.LogFailure(h, fn))),
            Record.FieldNames(handlers)),

    Diagnostics.ValueToText = (value) =>
        let
            List.TransformAndCombine = (list, transform, separator) => Text.Combine(List.Transform(list, transform), separator),

            Serialize.Binary =      (x) => "#binary(" & Serialize(Binary.ToList(x)) & ") ",

            Serialize.Function =    (x) => _serialize_function_param_type(
                                              Type.FunctionParameters(Value.Type(x)),
                                              Type.FunctionRequiredParameters(Value.Type(x)) ) &
                                           " as " &
                                           _serialize_function_return_type(Value.Type(x)) &
                                           " => (...) ",

            Serialize.List =        (x) => "{" & List.TransformAndCombine(x, Serialize, ", ") & "} ",

            Serialize.Record =      (x) => "[ " &
                                           List.TransformAndCombine(
                                                Record.FieldNames(x), 
                                                (item) => Serialize.Identifier(item) & " = " & Serialize(Record.Field(x, item)),
                                                ", ") &
                                           " ] ",

            Serialize.Table =       (x) => "#table( type " &
                                            _serialize_table_type(Value.Type(x)) &
                                            ", " &
                                            Serialize(Table.ToRows(x)) &
                                            ") ",
                                    
            Serialize.Identifier =  Expression.Identifier,

            Serialize.Type =        (x) => "type " & _serialize_typename(x),
                                    
                             
            _serialize_typename =    (x, optional funtype as logical) =>                        /* Optional parameter: Is this being used as part of a function signature? */
                                        let
                                            isFunctionType = (x as type) => try if Type.FunctionReturn(x) is type then true else false otherwise false,
                                            isTableType = (x as type) =>  try if Type.TableSchema(x) is table then true else false otherwise false,
                                            isRecordType = (x as type) => try if Type.ClosedRecord(x) is type then true else false otherwise false,
                                            isListType = (x as type) => try if Type.ListItem(x) is type then true else false otherwise false
                                        in
                                
                                            if funtype=null and isTableType(x) then _serialize_table_type(x) else
                                            if funtype=null and isListType(x) then "{ " & @_serialize_typename( Type.ListItem(x) ) & " }" else
                                            if funtype=null and isFunctionType(x) then "function " & _serialize_function_type(x) else
                                            if funtype=null and isRecordType(x) then _serialize_record_type(x) else
                                    
                                            if x = type any then "any" else
                                            let base = Type.NonNullable(x) in
                                              (if Type.IsNullable(x) then "nullable " else "") &       
                                              (if base = type anynonnull then "anynonnull" else                
                                              if base = type binary then "binary" else                
                                              if base = type date   then "date"   else
                                              if base = type datetime then "datetime" else
                                              if base = type datetimezone then "datetimezone" else
                                              if base = type duration then "duration" else
                                              if base = type logical then "logical" else
                                              if base = type none then "none" else
                                              if base = type null then "null" else
                                              if base = type number then "number" else
                                              if base = type text then "text" else 
                                              if base = type time then "time" else 
                                              if base = type type then "type" else 
                                      
                                              /* Abstract types: */
                                              if base = type function then "function" else
                                              if base = type table then "table" else
                                              if base = type record then "record" else
                                              if base = type list then "list" else
                                      
                                              "any /*Actually unknown type*/"),

            _serialize_table_type =     (x) => 
                                               let 
                                                 schema = Type.TableSchema(x)
                                               in
                                                 "table " &
                                                 (if Table.IsEmpty(schema) then "" else 
                                                     "[" & List.TransformAndCombine(
                                                         Table.ToRecords(Table.Sort(schema,"Position")),
                                                         each Serialize.Identifier(_[Name]) & " = " & _[Kind],
                                                         ", ") &
                                                     "] "),

            _serialize_record_type =    (x) => 
                                                let flds = Type.RecordFields(x)
                                                in
                                                    if Record.FieldCount(flds)=0 then "record" else
                                                        "[" & List.TransformAndCombine(
                                                            Record.FieldNames(flds),
                                                            (item) => Serialize.Identifier(item) & "=" & _serialize_typename(Record.Field(flds,item)[Type]),
                                                            ", ") & 
                                                        (if Type.IsOpenRecord(x) then ", ..." else "") &
                                                        "]",

            _serialize_function_type =  (x) => _serialize_function_param_type(
                                                  Type.FunctionParameters(x),
                                                  Type.FunctionRequiredParameters(x) ) &
                                                " as " &
                                                _serialize_function_return_type(x),
    
            _serialize_function_param_type = (t,n) => 
                                    let
                                        funsig = Table.ToRecords(
                                            Table.TransformColumns(
                                                Table.AddIndexColumn( Record.ToTable( t ), "isOptional", 1 ),
                                                { "isOptional", (x)=> x>n } ) )
                                    in
                                        "(" & 
                                        List.TransformAndCombine(
                                            funsig,
                                            (item)=>
                                                (if item[isOptional] then "optional " else "") &
                                                Serialize.Identifier(item[Name]) & " as " & _serialize_typename(item[Value], true),
                                            ", ") &
                                         ")",

            _serialize_function_return_type = (x) => _serialize_typename(Type.FunctionReturn(x), true), 

            Serialize = (x) as text => 
                               if x is binary       then try Serialize.Binary(x) otherwise "null /*serialize failed*/"        else 
                               if x is date         then try Expression.Constant(x) otherwise "null /*serialize failed*/"     else 
                               if x is datetime     then try Expression.Constant(x) otherwise "null /*serialize failed*/"     else 
                               if x is datetimezone then try Expression.Constant(x) otherwise "null /*serialize failed*/"     else 
                               if x is duration     then try Expression.Constant(x) otherwise "null /*serialize failed*/"     else 
                               if x is function     then try Serialize.Function(x) otherwise "null /*serialize failed*/"      else 
                               if x is list         then try Serialize.List(x) otherwise "null /*serialize failed*/"          else 
                               if x is logical      then try Expression.Constant(x) otherwise "null /*serialize failed*/"     else
                               if x is null         then try Expression.Constant(x) otherwise "null /*serialize failed*/"     else
                               if x is number       then try Expression.Constant(x) otherwise "null /*serialize failed*/"     else
                               if x is record       then try Serialize.Record(x) otherwise "null /*serialize failed*/"        else 
                               if x is table        then try Serialize.Table(x) otherwise "null /*serialize failed*/"         else 
                               if x is text         then try Expression.Constant(x) otherwise "null /*serialize failed*/"     else 
                               if x is time         then try Expression.Constant(x) otherwise "null /*serialize failed*/"     else 
                               if x is type         then try Serialize.Type(x) otherwise "null /*serialize failed*/"          else 
                               "[#_unable_to_serialize_#]"                     
        in
            try Serialize(value) otherwise "<serialization failed>"
in
    [ 
        LogValue = Diagnostics.LogValue,
        LogValue2 = Diagnostics.LogValue2,
        LogFailure = Diagnostics.LogFailure,
        WrapFunctionResult = Diagnostics.WrapFunctionResult,
        WrapHandlers = Diagnostics.WrapHandlers,
        ValueToText = Diagnostics.ValueToText
    ]