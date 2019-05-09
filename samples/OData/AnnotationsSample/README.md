Extracting OData V4 Annotations
============================

This sample shows how to read OData V4 annotations using the OData connector. 
Custom OData annotations are interpreted and exposed as "metadata" by the M language,
but there is still often a question of "metadata on what?", with a nontrivial answer.
Thus, the main goal of this sample is to show the various places that metadata can get placed 
by the OData connector.

> Note that standard OData annotations used by OData connector, such as from the `Core` and `Capabilities` vocabularies,
> are not guaranteed to be exposed.

Prerequisites
-------------

Some OData services may choose to omit some annotations unless they are explicitly requested using the `Include-Annotations` preference. 
The OData connector in M takes this a step further and, in addition to sending the preference, *explicitly filters* annotations locally according to the `OData.Feed` options 
`IncludeAnnotations` and `IncludeMetadataAnnotations`. If neither of these options is provided, then the OData connector will not expose *any* custom OData annotations, regardless of what annotations the service returned (standard metadata, such as documentation, may also be placed differently). Thus, users intending to extract OData annotations **must** set one of these options.

> The difference between `IncludeAnnotations` and `IncludeMetadataAnnotations` is that the value of `IncludeMetadataAnnotations` will only be sent as the `Include-Annotations` preference 
> for the metadata document. Thus, if you're only interested in metadata annotations, you can often save some performance by setting only `IncludeMetadataAnnotations` and not 
> `IncludeAnnotations`.

Navigating to Annotations
-------------------------

The OData V4 protocol allows for annotating many different kinds of items, each of which has a different place to put annotations in the protocol. Each of these locations corresponds to a different placement of annotation metadata in the M language. The general theme is that *annotations of an item will get placed as metadata on the value corresponding to that item.* In particular, this means that metadata annotations on an entity *type* will get placed not as metadata of a table value of entities nor as metadata on the record value of an individual entity, but rather as metadata on the **row type** value of such a table or record.

Annotations targeting | Get placed in
----------------------|--------------
Entity Containers     | Metadata of the Service Root Navigation Table
Entity Sets and Singletons | Metadata of the corresponding `Data` table value in the Service Root Navigation Table
Function Imports | Metadata of the function type value of the corresponding `Data` function value in the Service Root Navigation Table
Entity Types and Complex Types | The field `OData.Annotations` in the Metadata of the corresponding *record type* value (see below)
Properties of an Entity Type or Complex Type | The corresponding field of the property in the field `OData.FieldAnnotations` in the Metadata of the corresponding *record type* value of the entity type or complex type (see below)
Functions bound to an Entity Type | Metadata of the field type corresponding to the Function on the *record type* value corresponding to its respective bound Entity Type (see below). Alternatively, if you have a table type, the field type can more easily be obtained as the corresponding column type on the table type.
Function Parameters | Metadata of the parameter type in the function type (whether that is the type of a function value as in Function Imports or a field's type as in Bound Functions)
Properties of an Entity or Complex Value (Instance Annotations) | Metadata of the property value

Navigating to many of these locations requires first obtaining the record/row type of an entity or complex type. Since the process of doing so varies by context, we've split those guidelines into a separate table:

The record/row type value of an | Is
--------------------------------|---
Entity Set or Singleton         | The *row type* of the table type of the corresponding table value
1:1 Navigation Property or Single-Valued Complex Property | Just the Property type
1:N Navigation Property or Collection-Valued Complex Property | The *row type* of the property table type
Single-Valued Function Parameter | Just the parameter type
Collection-Valued Function Parameter | The *item type* of the parameter list type
Single-Valued Function Return Type | Just the return type
Collection-Valued Function Return Type | The *row type* of the returned table type
Entity | Just the record type of the Entity record value
Other collection/table of Entities | The *row type* of the table type of the collection/table value
