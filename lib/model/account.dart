class Account{
  int _id;
  String _name;


  Account(this._name);

  int get id => _id;
  String get name => _name;

  set name(String newName){
    if(newName.length <= 200){
      this._name = newName;
    }
  }

  Map<String,dynamic> toMap(){
    var map = Map<String,dynamic>();
    if(id!=null){
      map['id']= _id;
    }
    map['name'] = _name;

    return map;
  }

  Account.fromMapObject(Map<String,dynamic> map){
    this._id = map['id'];
    this._name = map['name'];
  }
}