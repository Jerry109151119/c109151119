import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final tabs = [
    Center(child: TicTacToePage()),
    Center(child: FiveInARow()),
  ];

  int _currentindex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('小遊戲庫'),
        ),
        body: tabs[_currentindex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.red,
          selectedItemColor: Colors.white,
          selectedFontSize: 16.0,
          unselectedFontSize: 12.0,
          iconSize: 20.0,
          currentIndex: _currentindex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '井字遊戲',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.access_alarm),
              label: '五子棋',
            ),
          ],
          onTap: (index) {
            setState(() {
              _currentindex = index;
            });
          },
        ),
      ),
    );
  }
}

class TicTacToePage extends StatefulWidget {
  @override
  _TicTacToePageState createState() => _TicTacToePageState();
}

class _TicTacToePageState extends State<TicTacToePage> {
  // 0: empty, 1: circle, 2: cross
  List<List<int>> board = [[0, 0, 0], [0, 0, 0], [0, 0, 0]];
  List<String> player = ["玩家1", "玩家2"];
  int currentPlayer = 1;
  int winner = 0; //  0:無  1:玩家1   2:玩家2  3:平手
  List<int> countWin = [0, 0];

  void checkWin() {
    // check rows
    for (int i = 0; i < 3; i++) {
      if (board[i][0] == board[i][1] && board[i][1] == board[i][2] && board[i][0] != 0) {
        winner = board[i][0];
      }
    }
    // check columns
    for (int i = 0; i < 3; i++) {
      if (board[0][i] == board[1][i] && board[1][i] == board[2][i] && board[0][i] != 0) {
        winner = board[0][i];
      }
    }
    // check diagonals
    if (board[0][0] == board[1][1] && board[1][1] == board[2][2] && board[0][0] != 0) {
      winner = board[0][0];
    }
    if (board[2][0] == board[1][1] && board[1][1] == board[0][2] && board[2][0] != 0) {
      winner = board[2][0];
    }
    //check tie
    int tie_check = 0;
    for(int i = 0;i < 3;i++){
      for(int j = 0;j < 3;j++){
        if(board[i][j] != 0) {
          tie_check++;
        }
      }
    }
    if(tie_check == 9){
      winner=3;
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "井字遊戲   -->   目前玩家：${currentPlayer == 1 ? player[0] : player[1]}",
          style: const TextStyle(fontSize: 20),
        ),
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: <Widget>[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "玩家1：Ｏ　玩家２：Ｘ",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                const Flexible(fit: FlexFit.tight, child: SizedBox(),),
                Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "勝場：玩家1：${countWin[0]}    玩家２：${countWin[1]}",
                      style: const TextStyle(fontSize: 12),
                    )
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              children: List.generate(9, (index) {
                int row = index ~/ 3;
                int col = index % 3;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (board[row][col] == 0) {
                        board[row][col] = currentPlayer;
                        currentPlayer = currentPlayer == 1 ? 2 : 1;
                        checkWin();
                        String win = '';
                        if(winner == 3){
                          win = '平手';
                        }
                        else if(winner==1 || winner==2){
                          win = "玩家 $winner wins";
                          countWin[winner-1] += 1;
                        }
                        if (winner != 0) {
                          showDialog(context: context,
                              builder: (context) => AlertDialog(
                                title: Text(win),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text("OK"),
                                    onPressed: () {
                                      setState(() {
                                        winner = 0;
                                        currentPlayer = 1;
                                        board = [[0, 0, 0], [0, 0, 0], [0, 0, 0]];
                                      });
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              )
                          );
                        }
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 1),
                    ),
                    child: Center(
                      child: _getPlayerIcon(board[row][col]),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getPlayerIcon(int player) {
    if (player == 1) {
      return const Icon(Icons.panorama_fish_eye);
    } else if (player == 2) {
      return const Icon(Icons.clear);
    } else {
      return Container();
    }
  }
}

class FiveInARow extends StatefulWidget {
  @override
  _FiveInARowState createState() => _FiveInARowState();
}

class _FiveInARowState extends State<FiveInARow> {
  List<List<int>> _board = List.generate(15, (_) => List.generate(15, (_) => 0));
  int _currentPlayer = 1;
  int _gameState = 0;
  List<int> countWin = [0, 0];

  @override
  void initState() {
    super.initState();
    _initBoard();
  }

  void _initBoard() {
    _board = List.generate(15, (_) => List.generate(15, (_) => 0));
    _currentPlayer = 1;
    _gameState = 0;
  }

  void _playMove(int x, int y) {
    setState(() {
      _board[x][y] = _currentPlayer;
      if (checkForWinner(_board, x, y)) {
        _gameState = _currentPlayer;
      } else if (_isBoardFull()) {
        _gameState = 3;
      } else {
        _currentPlayer = _currentPlayer == 1 ? 2 : 1;
      }
    });
  }

  bool _isBoardFull() {
    for (int i = 0; i < 15; i++) {
      for (int j = 0; j < 15; j++) {
        if (_board[i][j] == 0) {
          return false;
        }
      }
    }
    return true;
  }
  bool checkForWinner(List<List<int>> board, int x, int y) {
    int player = board[x][y];
    int count = 1;
    // Check horizontal
    for (int i = 1; i < 5; i++) {
      if (x + i < board.length && board[x + i][y] == player) {
        count++;
      } else {
        break;
      }
    }
    for (int i = 1; i < 5; i++) {
      if (x - i >= 0 && board[x - i][y] == player) {
        count++;
      } else {
        break;
      }
    }
    if (count >= 5) {
      return true;
    }
    count = 1;
    // Check vertical
    for (int i = 1; i < 5; i++) {
      if (y + i < board[x].length && board[x][y + i] == player) {
        count++;
      } else {
        break;
      }
    }
    for (int i = 1; i < 5; i++) {
      if (y - i >= 0 && board[x][y - i] == player) {
        count++;
      } else {
        break;
      }
    }
    if (count >= 5) {
      return true;
    }
    count = 1;
    // Check diagonal (top-left to bottom-right)
    for (int i = 1; i < 5; i++) {
      if (x + i < board.length && y + i < board[x].length && board[x + i][y + i] == player) {
        count++;
      } else {
        break;
      }
    }
    for (int i = 1; i < 5; i++) {
      if (x - i >= 0 && y - i >= 0 && board[x - i][y - i] == player) {
        count++;
      } else {
        break;
      }
    }
    if (count >= 5) {
      return true;
    }
    count = 1;
    // Check diagonal (top-right to bottom-left)
    for (int i = 1; i < 5; i++) {
      if (x + i < board.length && y - i >= 0 && board[x + i][y - i] == player) {
        count++;
      } else {
        break;
      }
    }
    for (int i = 1; i < 5; i++) {
      if (x - i >= 0 && y + i < board[x].length && board[x - i][y + i] == player) {
        count++;
      } else {
        break;
      }
    }
    if (count >= 5) {
      return true;
    }
    // No winner
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("五子棋  -->  "
            "目前玩家：${_currentPlayer == 1 ? '玩家1' : '玩家2'}",
          style: const TextStyle(fontSize: 20),
        ),
        backgroundColor: Colors.red,

      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: <Widget>[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "玩家1：yellow　玩家２：red",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                const Flexible(fit: FlexFit.tight, child: SizedBox(),),
                Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "勝場：玩家1：${countWin[0]}    玩家２：${countWin[1]}",
                      style: const TextStyle(fontSize: 12),
                    )
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 15,
              children: List.generate(225, (index) {
                int x = index ~/ 15;
                int y = index % 15;
                return InkWell(
                  onTap: () {
                    if (_board[x][y] == 0 && _gameState == 0) {
                      _playMove(x, y);
                    }
                    String word = '';
                    if(_gameState == 1 || _gameState == 2){
                      countWin[_gameState-1] += 1;
                      word = '玩家 $_gameState 贏了!';
                    }
                    else if(_gameState == 3){
                      word = '平手';
                    }
                    if(_gameState != 0){
                      showDialog(context: context,
                          builder: (context) => AlertDialog(
                            title: Text(word),
                            actions: <Widget>[
                              TextButton(
                                child: const Text("Restart"),
                                onPressed: () {
                                  setState(() {
                                    _initBoard();
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          )
                      );

                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      color: _getColor(x, y),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(int x, int y) {
    if (_board[x][y] == 0) {
      return Colors.white;
    } else if (_board[x][y] == 1) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }
}

