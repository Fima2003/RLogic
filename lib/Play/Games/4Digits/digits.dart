import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:function_tree/function_tree.dart';
import 'dart:math';

bool check(String expression){
  var lr = expression.split("=");
  String left = lr[0];
  String right = lr[1];
  String leftCorr = remake(left);
  String rightCorr = remake(right);
  if(leftCorr.interpret() == rightCorr.interpret()){
    return true;
  }else{
    return false;
  }
}

String remake(String expression){
  String correct = "";
  int i = 0;
  while(i < expression.length){
    if(expression[i] == "\u221a"){
      correct+="sqrt";
      if (expression[i + 1] != '(') {
        correct += '(';
        i++;
        while(i < expression.length && int.tryParse(expression[i]) != null) {
          correct += expression[i];
          i++;
        }
        correct += ')';
      } else {
        i++;
      }
    }else{
      correct+=expression[i];
      i++;
    }
  }
  return correct;
}

List<int> generateRandom(){
  List<int> nums = [];
  var r = new Random();
  int rand = r.nextInt(9000)+1000;
  while(rand != 0){
    nums.add(rand%10);
    rand ~/=10;
  }
  return nums;
}