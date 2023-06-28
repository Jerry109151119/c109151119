import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    User.isLogin = _auth.currentUser != null? true : false;
    return MaterialApp(
      home: Scaffold(
        body: User.isLogin ? GameLib() : LoginScreen(),
      ),
    );
  }
}

class User{
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static String? name = "";
  static String uid = "";
  static bool isLogin = false;

  //Sign up method
  Future<String?> signup({required String email, required String password, required String nickName}) async {
    try {
      print("email:$email");
      print("password:$password");
      await auth.createUserWithEmailAndPassword(email: email, password: password);
      uid  = auth.currentUser!.uid;
      await firestore.collection('users').doc(uid).set({'nickName': nickName});
      name = await getUserData("nickName");
      print(name);
      return null;
    }
    on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  //Sign in method
  Future<String?> signIn({required String email, required String password}) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      uid  = auth.currentUser!.uid;
      name = await getUserData("nickName");
      return null;
    }
    on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  //Sign out method (memorized)
  Future<void> signOut() async {
    await auth.signOut();
    name = "";
    uid = "";
  }

  Future<String?> getUserData(String item) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return data[item];
      }
      else {
        return null;
      }
    }
    catch (e) {
      return null;
    }
  }
}


class GameLib extends StatefulWidget{
  @override
  _GameLib createState() => _GameLib();
}

class _GameLib extends State<GameLib>{
  final tabs = [
    Center(child: TicTacToePage()),
    Center(child: FiveInARow()),
  ];
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: tabs[_currentIndex],
          appBar: AppBar(
            title: const Text('小遊戲庫'),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '登出',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      User.isLogin = false;
                      _auth.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.red,
            selectedItemColor: Colors.white,
            selectedFontSize: 16.0,
            unselectedFontSize: 12.0,
            iconSize: 20.0,
            currentIndex: _currentIndex,
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
                _currentIndex = index;
              });},
          ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final User user = User();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  Future<void> _login() async {
    try {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();
      await user.signIn(email: email, password: password );
      User.isLogin = true;

    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('登入失敗'),
            content: Text('請確認帳號密碼是否正確。'),
            actions: [
              TextButton(
                child: Text('確定'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('登入'),
      ),

      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: '電子郵件'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: '密碼'),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Register()),
                      );
                    },
                    child: const Text('註冊'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await _login();
                      if(User.isLogin){
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => GameLib()),
                        );
                      }
                    },
                    child: const Text('登入'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Register extends StatefulWidget{
  @override
  _Register createState() => _Register();
}

class _Register extends State<Register>{
  final User user = User();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _nickName = TextEditingController();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('註冊帳號'),
      ),

      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _email,
              decoration: InputDecoration(labelText: '電子郵件'),
            ),
            TextField(
              controller: _password,
              decoration: InputDecoration(labelText: '密碼'),
              obscureText: true,
            ),
            TextField(
              controller: _nickName,
              decoration: InputDecoration(labelText: '暱稱'),
            ),
            SizedBox(height: 16.0),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await user.signup(
                          email: _email.text.trim(),
                          password: _password.text.trim(),
                          nickName: _nickName.text.trim()
                      );
                      if(User.isLogin){
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => GameLib()),
                        );
                      }
                    },
                    child: const Text('註冊'),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            )
          ],
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
  List<String> player = [User.name.toString(), "玩家2"];
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
            padding: EdgeInsets.all(20),
            child: Row(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "${player[0]}：Ｏ　${player[1]}：Ｘ",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                Flexible(fit: FlexFit.tight, child: SizedBox(),),
                Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "勝場：${player[0]}：${countWin[0]}    ${player[1]}：${countWin[1]}",
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
                          win = "${player[winner-1]} wins";
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
  List<String> players = [User.name.toString(), "玩家2"];
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
            "目前玩家：${_currentPlayer == 1 ? players[0] : players[1]}",
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "${players[0]}：yellow　${players[1]}：red",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const Flexible(fit: FlexFit.tight, child: SizedBox(),),
                Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "勝場：${players[0]}：${countWin[0]}    ${players[1]}：${countWin[1]}",
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
                      word = '${players[_gameState-1]} 贏了!';
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

