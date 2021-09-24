import 'dart:io';
import 'dart:math';
import 'package:trotter/trotter.dart';

void main(){
  final field = generateField(4);
  final allPossibleFields = allFields(field);
  for(int i = 0; i < field.length; i++){
    for(int j = 0; j < field[i].length; j++){
      stdout.write("${field[i][j]} ");
    }
    stdout.write('\n');
  }
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
    seenFromLeft(field, length),
    seenFromTop(field, length),
    seenFromRight(field, length),
    seenFromBottom(field, length)
  ];
}

generateLimitedAmountOfSideValues(List<List<int>> field, List<List<int>> sides, int minAmountOfHints){
  var rand = new Random();
  List<List<List<int>>> fields = allFields(field);
  int amountOfDoublesInARow = 0;
  while(amountOfLeft(sides) > minAmountOfHints && amountOfDoublesInARow < amountOfLeft(sides)){
    late int rowForElimination, colForElimination;
    int nextForDeletion = rand.nextInt(sides[0].length*sides[0].length) + 1;
    while(nextForDeletion > 0){
      for(int i = 0; i < sides.length; i++){
        for(int j = 0; j < sides[i].length; j++){
          if(nextForDeletion > 0 && sides[i][j] != 0){
            nextForDeletion--;
            rowForElimination = i;
            colForElimination = j;
          }
        }
      }
    }
    int value = sides[rowForElimination][colForElimination];
    if(correctFieldsWithoutOneSideValue(rowForElimination, colForElimination, fields, sides) == 1){
      sides[rowForElimination][colForElimination] = 0;
      amountOfDoublesInARow = 0;
    }else{
      sides[rowForElimination][colForElimination] = value;
      amountOfDoublesInARow++;
    }
  }
  return sides;
}

generateGame(int size, String difficulty){
  var field = generateField(size);
  Map<String, dynamic> result = {"field": field};
  var sides = sideCounts(field, size);
  var rand = new Random();
  var splitSides;
  if(size == 4){
    int amountOfTips = rand.nextInt(3)+6;
    splitSides = generateLimitedAmountOfSideValues(field, sides, amountOfTips);
  }else if(size == 5){
    if(difficulty == "Easy"){
      int amountOfTips = rand.nextInt(2) + 11;
      splitSides = generateLimitedAmountOfSideValues(field, sides, amountOfTips);
    }else if(difficulty == "Medium"){
      int amountOfTips = rand.nextInt(2) + 9;
      splitSides = generateLimitedAmountOfSideValues(field, sides, amountOfTips);
    }else{
      int amountOfTips = rand.nextInt(2) + 11;
      splitSides = generateLimitedAmountOfSideValues(field, sides, amountOfTips);
    }
  }else{
    if(difficulty == "Easy"){
      int amountOfTips = rand.nextInt(2) + 19;
      splitSides = generateLimitedAmountOfSideValues(field, sides, amountOfTips);
    }else if(difficulty == "Medium"){
      int amountOfTips = rand.nextInt(2) + 17;
      splitSides = generateLimitedAmountOfSideValues(field, sides, amountOfTips);
    }else if(difficulty == "Hard"){
      int amountOfTips = rand.nextInt(2) + 13;
      splitSides = generateLimitedAmountOfSideValues(field, sides, amountOfTips);
    }
  }
  result["SideTips"] = splitSides;
  return result;
}

// Function that tells if sides of the changed field equal to its actual sides
bool correctnessWithoutOneSideHint(List<List<int>> sides, List<List<int>> field){
  bool correct = true;
  List<List<int>> sidesOfCurrentField = sideCounts(field, field.length);
  for(int i = 0; i < sidesOfCurrentField.length; i++){
    for(int j = 0; j < sidesOfCurrentField[i].length; j++){
      if(sides[i][j] != 0 && sides[i][j] != sidesOfCurrentField[i][j]){
        correct = false;
        break;
      }
    }
    if(!correct)
      break;
  }
  return correct;
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

List<List<int>> transpose(List<List<int>> list){
  List<List<int>> result = List.generate(list.length, (index) => List.generate(list[index].length, (index) => 0));
  for(int i = 0; i < list.length; i++){
    for(int j = 0; j < list[i].length; j++){
      result[i][j] = list[j][i];
    }
  }
  return result;
}

// Function that returns all possible fields switching either two rows or two columns
List<List<List<int>>> allFields(List<List<int>> field){
  List<List<List<int>>> fields = [];
  List<int> listOfNumbersInRangeOfLength = List.generate(field.length, (index) => index);
  var allPermutations = Permutations(field.length, listOfNumbersInRangeOfLength);

  // Adding all possible permutations of rows
  for(final permutation in allPermutations()){
    List<List<int>> nextField = [];
    for(int i = 0; i < permutation.length; i++){
      nextField.add(field[permutation[i]]);
    }
    fields.add(nextField);
  }

  var list = List.generate(field.length, (index) => index);

  // Adding all possible permutations of cols
  for(final permutation in allPermutations()){
    if(!equalLists(permutation, list)) {
      List<List<int>> nextField = [];
      field = transpose(field);
      for (int i = 0; i < permutation.length; i++) {
        nextField.add(field[permutation[i]]);
      }
      field = transpose(field);
      nextField = transpose(nextField);
      fields.add(nextField);
    }
  }
  int r = fields.length;

  for(final _field in fields){
    for(int i = 0; i < _field.length; i++){
      for(int j = 0; j < _field[i].length; j++){
        stdout.write('${_field[i][j]} ');
      }
      stdout.write('\n');
    }
    stdout.write('________________\n');
  }

  print("Field: ");

  for(int i = 0; i < field.length; i++){
    for(int j = 0; j < field[i].length; j++){
      stdout.write('${field[i][j]} ');
    }
    stdout.write('\n');
  }

  print("Adding all possible fields switching two numbers(f.e. all 1's are changed to 2, and all 2's are changed to 1's)");
  // Adding all possible fields switching two numbers(f.e. all 1's are changed to 2, and all 2's are changed to 1's)
  for(final firstNumber in listOfNumbersInRangeOfLength){
    for(final secondNumber in listOfNumbersInRangeOfLength){
      if(secondNumber == firstNumber) continue;
      List<List<int>> nextField = [];
      for(int i = 0; i < field.length; i++){
        List<int> row = [];
        for(int j = 0; j < field[i].length; j++){
          if(field[i][j] == firstNumber + 1){
            row.add(secondNumber + 1);
          }else if(field[i][j] == secondNumber + 1){
            row.add(firstNumber + 1);
          }else{
            row.add(field[i][j]);
          }
        }
        nextField.add(row);
      }
      print("Switching ${firstNumber + 1} and ${secondNumber + 1}");
      for(int i = 0; i < nextField.length; i++){
        for(int j = 0; j < nextField[i].length; j++){
          stdout.write('${nextField[i][j]} ');
        }
        stdout.write('\n');
      }
      stdout.write('________________\n');
      fields.add(nextField);
    }
  }

  return fields;
}


// Function that check the equality of two lists
bool equalLists(List<int> one, List<int> two){
  for(int i = 0; i < one.length; i++){
    if(one[i] != two[i]) return false;
  }
  return true;
}

// Function that returns the amount of correct fields
// with swapped either rows or columns with one side value deleted
int correctFieldsWithoutOneSideValue(int rowOfDeleted, int colOfDeleted, List<List<List<int>>> fields, List<List<int>> sides){
  int res = 0;
  sides[rowOfDeleted][colOfDeleted] = 0;
  for(final field in fields){
    if(correctnessWithoutOneSideHint(sides, field)){
      res++;
    }
  }
  return res;
}


// Function that counts amount of left numbers at sides after deletion
int amountOfLeft(List<List<int>> sides){
  int res = 0;
  for(int i = 0; i < sides.length; i++){
    for(int j = 0; j < sides[i].length; j++){
      if(sides[i][j] != 0) res++;
    }
  }
  return res;
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