// ignore_for_file: non_constant_identifier_names
// ignore_for_file: camel_case_types
// ignore_for_file: prefer_single_quotes

// This file is automatically generated. DO NOT EDIT, all your changes would be lost.

class JsonSerializable{
    const JsonSerializable();
}

class JSONField {

  const JSONField({this.name, this.serialize, this.deserialize});
  //Specify the parse field name
  final String? name;

  //Whether to participate in toJson
  final bool? serialize;
  
  //Whether to participate in fromMap
  final bool? deserialize;
}
