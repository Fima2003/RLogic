import 'dart:math';

const numbers = [1234, 1235, 1236, 1237, 1238, 1239, 1245, 1246, 1247, 1248, 1249, 1256, 1257, 1258, 1259, 1267, 1268, 1269, 1278, 1279, 1289, 1345, 1346, 1347, 1348, 1349, 1356, 1357, 1358, 1359, 1367, 1368, 1369, 1378, 1379, 1389, 1456, 1457, 1458, 1459, 1467, 1468, 1469, 1478, 1479, 1489, 1567, 1568, 1569, 1578, 1579, 1589, 1678, 1679, 1689, 1789, 2345, 2346, 2347, 2348, 2349, 2356, 2357, 2358, 2359, 2367, 2368, 2369, 2378, 2379, 2389, 2456, 2457, 2458, 2459, 2467, 2468, 2469, 2478, 2479, 2489, 2567, 2568, 2569, 2578, 2579, 2589, 2678, 2679, 2689, 2789, 3456, 3457, 3458, 3459, 3467, 3468, 3469, 3478, 3479, 3489, 3567, 3568, 3569, 3578, 3579, 3589, 3678, 3679, 3689, 3789, 4567, 4568, 4569, 4578, 4579, 4589, 4678, 4679, 4689, 4789, 5678, 5679, 5689, 5789, 6789];

class BullsCows{

  BullsCows();

  int generateHidden(){
    var rng = new Random();
    int random = numbers[rng.nextInt(numbers.length)];
    List<int> number = intToList(random);
    number.shuffle();
    int hiddenNumber = listToInt(number);
    return hiddenNumber;
  }

  Pair check(int guess, int number){
    Pair a = Pair(0, 0);
    if(guess == number){
      a.bulls = 4;
      a.cows = 0;
      return a;
    }
    List<int> gs = intToList(guess);
    List<int> nm = intToList(number);
    List<int> bulls = [];
    for(int i = 0; i < gs.length; i++){
      if(gs[i] == nm[i]) {
        a.bulls++;
        bulls.add(gs[i]);
      }
    }
    for(int i = 0; i < gs.length; i++){
      for(int j = 0; j < nm.length; j++){
        if (gs[i] == nm[j] && !bulls.contains(nm[j])) {
          a.cows++;
        }
      }
    }
    return a;
  }
}

int listToInt(List<int> a){
  int res = 0;
  for(int i = 0; i < a.length; i++){
    res+=a[i]*pow(10, a.length - i - 1).toInt();
  }
  return res;
}

List<int> intToList(int a){
  int aa = a;
  List<int> number = [];
  while(aa != 0){
    number.add(aa%10);
    aa~/=10;
  }
  number = number.reversed.toList();
  return number;
}

class Pair {
  Pair(this.bulls, this.cows);

  int bulls;
  int cows;

  @override
  String toString() => 'Pair[$bulls, $cows]';
}