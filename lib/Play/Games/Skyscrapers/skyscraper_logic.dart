import 'dart:io';
import 'dart:math';
import 'package:trotter/trotter.dart';

void main(){
}

generateGame(int size, String difficulty){
  var field = generateField(size);
  Map<String, dynamic> result = {"field": field};
  var sides = sideCounts(field, size);
  var rand = new Random();
  var splitSides;
  if(size == 4){
    int amountOfTips = rand.nextInt(3)+6;
    splitSides = generateLimitedAmountOfSideValues(sides, amountOfTips);
  }else if(size == 5){
    if(difficulty == "Easy"){
      int amountOfTips = rand.nextInt(2) + 11;
      splitSides = generateLimitedAmountOfSideValues(sides, amountOfTips);
    }else if(difficulty == "Medium"){
      int amountOfTips = rand.nextInt(2) + 9;
      splitSides = generateLimitedAmountOfSideValues(sides, amountOfTips);
    }else{
      int amountOfTips = rand.nextInt(2) + 11;
      splitSides = generateLimitedAmountOfSideValues(sides, amountOfTips);
    }
  }else{
    if(difficulty == "Easy"){
      int amountOfTips = rand.nextInt(3) + 19;
      splitSides = generateLimitedAmountOfSideValues(sides, amountOfTips);
    }else if(difficulty == "Medium"){
      int amountOfTips = rand.nextInt(3) + 17;
      splitSides = generateLimitedAmountOfSideValues(sides, amountOfTips);
    }else if(difficulty == "Hard"){
      int amountOfTips = rand.nextInt(3) + 13;
      splitSides = generateLimitedAmountOfSideValues(sides, amountOfTips);
    }
  }
  result["SideTips"] = splitSides;
  return result;
}

// A function that generates field
List<List<int>> generateField(int n){
  List<List<int>> field;
  field = List.generate(n, (i) => List.generate(n, (j) => (i+j)%n + 1));
  var rand = new Random();
  int timesToChange = rand.nextInt(1000);
  for(int i = 0; i < timesToChange; i++){
    int rowOrColumn = rand.nextInt(1000);
    if(rowOrColumn % 2 == 0){
      int row1 = rand.nextInt(n);
      int row2 = rand.nextInt(n);
      field = changeRow(field, row1, row2, n);
    }else{
      int col1 = rand.nextInt(n);
      int col2 = rand.nextInt(n);
      field = changeCol(field, col1, col2, n);
    }
  }
  return field;
}

// Functions that count side numbers
List<int> seenFromLeft(var field, int length){
  List<int> left = [];
  for(int i = 0; i < length; i++){
    int t = 1;
    int max = field[i][0];
    for(int j = 1; j < length; j++){
      if(field[i][j] > max && field[i][j]>field[i][j-1]){
        t++;
        max = field[i][j];
      }
    }
    left.add(t);
  }
  return left;
}
List<int> seenFromRight(var field, int length){
  List<int> right = [];
  for(int i = 0; i < length; i++){
    int t = 1;
    int max = field[i][length - 1];
    for(int j = length - 2; j >= 0; j--){
      if(field[i][j] > max && field[i][j]>field[i][j+1]){
        t++;
        max = field[i][j];
      }
    }
    right.add(t);
  }
  return right;
}
List<int> seenFromTop(var field, int length){
  List<int> top = [];
  for(int i = 0; i < length; i++){
    int t = 1;
    int max = field[0][i];
    for(int j = 0; j < length; j++){
      if(field[j][i] > max && field[j][i]>field[j-1][i]){
        t++;
        max = field[j][i];
      }
    }
    top.add(t);
  }
  return top;
}
List<int> seenFromBottom(var field, int length){
  List<int> top = [];
  for(int i = 0; i < length; i++){
    int t = 1;
    int max = field[length - 1][i];
    for(int j = length - 2; j >= 0; j--){
      if(field[j][i] > max && field[j][i]>field[j+1][i]){
        t++;
        max = field[j][i];
      }
    }
    top.add(t);
  }
  return top;
}
// A Function that unites answers of previous four functions in one array
List<List<int>> sideCounts(var field, int length){
  return [
    seenFromTop(field, length),
    seenFromRight(field, length),
    seenFromBottom(field, length),
    seenFromLeft(field, length)
  ];
}

List<List<int>> generateLimitedAmountOfSideValues(List<List<int>> sides, int minAmountOfTips){
  print(sides);
  int size = sides[0].length;
  Random rand = new Random();
  int inARow = 0;
  while(amountOfHints(sides) > minAmountOfTips && inARow < size*size){
    int nextForDeletion = rand.nextInt(4*size);
    int row = nextForDeletion~/size;
    int col = nextForDeletion%size;
    int val = sides[row][col];
    sides[row][col] = 0;
    List<List<int>> field = List.generate(size, (index) => List.generate(size, (index) => 0));
    List<List<List<int>>> possibleValues = List.generate(size, (index) => List.generate(size, (index) => List.generate(size, (index) => index+1)));
    firstSteps(sides, field, possibleValues);
    mainCycle(field, possibleValues);
    solver(possibleValues, field, sides);
    print(fields);
    print(1);
    if(fields.length > 1){
      print(2);
      print(sides);
      inARow++;
      sides[row][col] = val;
    }else{
      print(sides);
      inARow = 0;
    }
    fields.clear();
  }
  print(sides);
  return sides;
}

int amountOfHints(List<List<int>> sides){
  int amount = 0;
  for(int i = 0; i < sides.length; i++){
    for(int j = 0; j < sides[i].length; j++){
      if(sides[i][j] != 0) amount++;
    }
  }
  return amount;
}

List<List<int>> changeRow(var field1, int row1, int row2, int length){
  var field = field1;
  for(int i = 0; i < length; i++){
    int t = field[row1][i];
    field[row1][i] = field[row2][i];
    field[row2][i] = t;
  }
  return field;
}

List<List<int>> changeCol(var field1, col1, col2, int length){
  var field = field1;
  for(int i = 0; i < length; i++){
    int t = field[i][col1];
    field[i][col1] = field[i][col2];
    field[i][col2] = t;
  }
  return field;
}

void mainCycle(List<List<int>> field, List<List<List<int>>> possibleValues){
  while(eliminatePossibleValues(possibleValues, field) || fillOneLeft(possibleValues, field) || oneLeftInRowOrColumn(possibleValues, field));
}

void firstSteps(List<List<int>> sides, List<List<int>> field, List<List<List<int>>> possibleValues){
  int size = field.length;
  for(int i = 0; i < sides.length; i++){
    for(int j = 0; j < sides[i].length; j++){
      if(sides[i][j] == 1){
        switch(i){
          case 0:
            field[0][j] = size;
            break;
          case 1:
            field[j][size - 1] = size;
            break;
          case 2:
            field[size - 1][j] = size;
            break;
          case 3:
            field[j][0] = size;
            break;
          default:
            print("Error occurred during main(). ${StackTrace.current}");
            break;
        }
      }else if(sides[i][j] == size){
        switch (i){
          case 0:
            for(int k = 0; k < field.length; k++){
              field[k][j] = k + 1;
            }
            break;
          case 1:
            for(int k = 0; k < field[j].length; k++){
              field[j][k] = field[j].length - k;
            }
            break;
          case 2:
            for(int k = 0; k < field.length; k++){
              field[k][j] = field.length - k;
            }
            break;
          case 3:
            for(int k = 0; k < field[j].length; k++){
              field[j][k] = k + 1;
            }
            break;
          default:
            print("Error occurred during main(). ${StackTrace.current}");
            break;
        }
      }else if(sides[i][j] != 0){
        int min = sides[i][j] - 1;
        int minForPreMax = sides[i][j] - 2;
        switch(i){
          case 0:
            for(int k = 0; k < min; k++){
              possibleValues[k][j].removeWhere((element) => element == size);
            }
            for(int k = 0; k < minForPreMax; k++){
              possibleValues[k][j].removeWhere((element) => element == (size - 1));
            }
            break;
          case 1:
            for(int k = 0; k < min; k++){
              possibleValues[j][size - k - 1].removeWhere((element) => element == size);
            }
            for(int k = 0; k < minForPreMax; k++){
              possibleValues[j][size - k - 1].removeWhere((element) => element == (size - 1));
            }
            break;
          case 2:
            for(int k = 0; k < min; k++){
              possibleValues[size-k-1][j].removeWhere((element) => element == size);
            }
            for(int k = 0; k < minForPreMax; k++){
              possibleValues[size-k-1][j].removeWhere((element) => element == (size - 1));
            }
            break;
          case 3:
            for(int k = 0; k < min; k++){
              possibleValues[j][k].removeWhere((element) => element == size);
            }
            for(int k = 0; k < minForPreMax; k++){
              possibleValues[j][k].removeWhere((element) => element == (size - 1));
            }
            break;
          default:
            print("Error occurred during main(). ${StackTrace.current}");
            break;
        }
      }
    }
  }
}

bool eliminatePossibleValues(List<List<List<int>>> possibleValues, List<List<int>> field){
  bool changed = false;
  for(int i = 0; i < field.length; i++){
    for(int j = 0; j < field[i].length; j++){
      if(field[i][j] != 0){
        var value = field[i][j];
        possibleValues[i][j] = [];
        for(int k = 0; k < possibleValues.length; k++){
          possibleValues[k][j].removeWhere((element) {
            if(element == value){
              changed = true;
              return true;
            }else{
              return false;
            }
          });
        }
        for(int k = 0; k < possibleValues[i].length; k++){
          possibleValues[i][k].removeWhere((element) {
            if(element == value){
              changed = true;
              return true;
            }else{
              return false;
            }
          });
        }
      }
    }
  }
  return changed;
}

bool fillOneLeft(List<List<List<int>>> possibleValues, List<List<int>> field){
  bool changed = false;
  for(int i = 0; i < possibleValues.length; i++){
    for(int j = 0; j < possibleValues[i].length; j++){
      if(possibleValues[i][j].length == 1){
        field[i][j] = possibleValues[i][j][0];
        changed = true;
      }
    }
  }
  return changed;
}

bool oneLeftInRowOrColumn(List<List<List<int>>> possibleValues, List<List<int>> field){
  bool changed = false;
  int size = possibleValues.length;
  for(int r = 0; r < possibleValues.length; r++){
    List<int> valuesInRow = List.generate(size, (index) => 0);
    for(int i = 0; i < possibleValues[r].length; i++){
      for(int j = 0; j < possibleValues[r][i].length; j++){
        valuesInRow[possibleValues[r][i][j]-1]++;
      }
    }
    if(valuesInRow.indexWhere((element) => element == 1) != -1){
      List<int> values = [];
      changed = true;
      for(int i = 0; i < valuesInRow.length; i++){
        if(valuesInRow[i] == 1) values.add(i+1);
      }
      for(int i = 0; i < possibleValues[r].length; i++){
        for(int j = 0; j < possibleValues[r][i].length; j++){
          if(values.contains(possibleValues[r][i][j])) field[r][i] = possibleValues[r][i][j];
        }
      }
    }
  }

  for(int c = 0; c < possibleValues[0].length; c++){
    List<int> valuesInCol = List.generate(size, (index) => 0);
    for(int r = 0; r < possibleValues[0].length; r++){
      for(int i = 0; i < possibleValues[r][c].length; i++){
        valuesInCol[possibleValues[r][c][i]-1]++;
      }
    }
    if(valuesInCol.indexWhere((element) => element == 1) != -1){
      List<int> values = [];
      changed = true;
      for(int i = 0; i < valuesInCol.length; i++){
        if(valuesInCol[i] == 1) values.add(i+1);
      }
      for(int r = 0; r < possibleValues[0].length; r++){
        for(int i = 0; i < possibleValues[r][c].length; i++){
          if(values.contains(possibleValues[r][c][i])) field[r][c] = possibleValues[r][c][i];
        }
      }
    }
  }
  return changed;
}

List<List<List<int>>> fields = [];

int solver(List<List<List<int>>> possibleValues, List<List<int>> field, List<List<int>> sides){
  if(fields.length > 1) return 0;
  int row = -1, col = -1;
  for(int i = 0; i < field.length; i++){
    bool found = false;
    for(int j = 0; j < field[i].length; j++){
      if(field[i][j] == 0){
        found = true;
        row = i;
        col = j;
        break;
      }
    }
    if(found) break;
  }
  if(row == -1 && col == -1){
    if(_check(field, sides)){
      fields.add(field);
      return 1;
    }
    else{
      return 0;
    }
  }else{
    for(final val in possibleValues[row][col]){
      field[row][col] = val;
      List<List<int>> _field = [];
      for(int i = 0; i < field.length; i++){
        List<int> temp = [];
        for(int j = 0; j < field[i].length; j++){
          temp.add(field[i][j]);
        }
        _field.add(temp);
      }


      List<List<List<int>>> _possibleValues = [];
      for(int i = 0; i < possibleValues.length; i++){
        List<List<int>> temps = [];
        for(int j = 0; j < possibleValues[i].length; j++){
          List<int> temp = [];
          for(int k = 0; k < possibleValues[i][j].length; k++){
            temp.add(possibleValues[i][j][k]);
          }
          temps.add(temp);
        }
        _possibleValues.add(temps);
      }

      mainCycle(_field, _possibleValues);
      solver(_possibleValues, _field, sides);
    }
    return 0;
  }
}

bool _check(List<List<int>> field, List<List<int>> sides){
  var side = sideCounts(field, field.length);
  for(int i = 0; i < sides.length; i++){
    for(int j = 0; j < sides[i].length; j++){
      if(sides[i][j] != 0 && sides[i][j]!=side[i][j]){
        return false;
      }
    }
  }
  return true;
}





// Functions that are used in UI

//Logic of delete button
void deleteLogic(List<PreviousMove> pms, List<List<List<String>>> pencilModeInserted, List<List<String>> inserted, List<List<bool>> pencilModeActivated, int row, int col){
  if(pencilModeActivated[row][col]){
    final List<String> valuesOfCell = [];//List.generate(pencilModeInserted[row][col].length, (index) => pencilModeInserted[row][col][index]);
    for(int i = 0; i < pencilModeInserted[row][col].length; i++){
      valuesOfCell.add(pencilModeInserted[row][col][i]);
    }
    pms.add(new PreviousMove(
      move: "Delete",
      row: row,
      col: col,
      value: valuesOfCell,
      deleteCase: "Pencil"
    ));
    pencilModeInserted[row][col].clear();
  }else{
    final String valueOfCell = inserted[row][col];
    pms.add(new PreviousMove(
      move: "Delete",
      row: row,
      col: col,
      value: valueOfCell,
      deleteCase: "Full",
    ));
    inserted[row][col] = "";
  }
}

// Logic of undo button
void undoLogic(List<PreviousMove> pms, List<List<List<String>>> pencilModeInserted, List<List<String>> inserted, List<List<bool>> pencilModeActivated){
  PreviousMove pm = pms.last;
  switch(pm.move){
    case "Delete":
      if(pm.deleteCase?.compareTo("Full") == 0){
        inserted[pm.row][pm.col] = pm.value.toString();
      }else if(pm.deleteCase?.compareTo("Pencil") == 0){
        pencilModeInserted[pm.row][pm.col] = pm.value;
      }else{
        print("Wrong method inserted when undoing \"Delete\" method");
      }
      break;
    case "Pencil":
      bool _beforeFound = false;
      for(int i = pms.length - 2; i >= 0; i--){
        if(pms[i].row == pm.row && pms[i].col == pm.col) {
          if(pms[i].move == "Delete"){
            pencilModeActivated[pm.row][pm.col] = false;
            break;
          }
          if(pms[i].move == "Full"){
            inserted[pm.row][pm.col] = pms[i].value;
            pencilModeActivated[pm.row][pm.col] = false;
            pencilModeInserted[pm.row][pm.col].clear();
            _beforeFound = true;
            break;
          }
          if(pms[i].move == "Pencil"){
            pencilModeInserted[pm.row][pm.col].removeLast();
            _beforeFound = true;
            break;
          }
        }
      }
      if(!_beforeFound){
        inserted[pm.row][pm.col] = "";
        pencilModeInserted[pm.row][pm.col].clear();
      }
      break;
    case "Full":
      bool _beforeFound = false;
      for(int i = pms.length - 2; i >= 0; i--) {
        if(pms[i].row == pm.row && pms[i].col == pm.col) {
          if (pms[i].move == "Delete") {
            pencilModeActivated[pm.row][pm.col] = false;
            break;
          }
          if(pms[i].move == "Full"){
            _beforeFound = true;
            inserted[pm.row][pm.col] = pms[i].value;
            pencilModeInserted[pm.row][pm.col].clear();
            break;
          }
          if(pms[i].move == "Pencil"){
            List<String> valuesOfCell = [];
            _beforeFound = true;
            while(i >= 0 && pms[i].move == "Pencil"){
              valuesOfCell.add(pms[i].value);
              i--;
            }
            valuesOfCell = List.from(valuesOfCell.reversed);
            pencilModeInserted[pm.row][pm.col] = valuesOfCell;
            pencilModeActivated[pm.row][pm.col] = true;
            inserted[pm.row][pm.col] = "";
            break;
          }
        }
      }
      if(!_beforeFound){
        inserted[pm.row][pm.col] = "";
        pencilModeInserted[pm.row][pm.col].clear();
      }
      break;
    default:
      print("Unexpected Expression");
      break;
  }
  pms.removeLast();
}

// Check if the field is filled
bool filled(var inserted){
  for(int i = 0; i < inserted.length; i++){
    for(int j = 0; j < inserted[i].length; j++){
      if(inserted[i][j] == "") return false;
    }
  }
  return true;
}

// Check if the filled field is correct
bool check(List<List<String>> field, var sides){
  List<List<int>> inserted = List.generate(field.length, (index) => List.generate(field.length, (index) => 0));
  for(int i = 0; i < field.length; i++){
    for(int j = 0; j < field[i].length; j++){
      inserted[i][j] = int.tryParse(field[i][j])!;
    }
  }
  var side = sideCounts(inserted, inserted.length);
  for(int i = 0; i < sides.length; i++){
    for(int j = 0; j < sides[i].length; j++){
      if(sides[i][j] != 0 && sides[i][j]!=side[i][j]){
        return false;
      }
    }
  }
  return true;
}





class PreviousMove{
  String move; // "Delete", "PencilMode", "FullMode"
  int row, col;
  var value;
  String? deleteCase;
  PreviousMove({required this.move, required this.row, required this.col, required this.value, this.deleteCase});
}