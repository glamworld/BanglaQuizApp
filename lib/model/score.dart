class Score{
  int _id;
  String _name;
  String _score;
  int _income;

  Score(this._name, this._score, this._income);

  int get id => _id;
  String get name => _name;
  String get score => _score;
  int get income => _income;

  set name(String newName){
    if(newName.length <= 200){
      this._name = newName;
    }
  }

  set score(String newScore){
      this._score = newScore;
  }

  set income(int newIncome){
      this._income= newIncome;
  }

  Map<String,dynamic> toMap(){
    var map = Map<String,dynamic>();
    if(id!=null){
      map['id']= _id;
    }
    map['name'] = _name;
    map['score'] = _score;
    map['income'] = _income;

    return map;
  }

  Score.fromMapObject(Map<String,dynamic> map){
    this._id = map['id'];
    this._name = map['name'];
    this._score = map['score'];
    this._income = map['income'];
  }
}