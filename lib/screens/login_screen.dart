import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:productes_app/services/login_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  GlobalKey<FormState> _key = GlobalKey();

  RegExp emailRegExp =
      new RegExp(r'^\w+[\w-\.]*\@\w+((-\w+)|(\w*))\.[a-z]{2,3}$');
  RegExp contRegExp = new RegExp(r'^([1-zA-Z0-1@.\s]{1,255})$');
  String? _correu;
  String? _passwd;
  String errorCode = '';
  bool _isChecked = false;

  late var loginService;

  initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);

    //Descomentar las siguientes lineas para generar un efecto de "respiracion"
    /*animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });*/
    controller.forward();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    loginService = Provider.of<LoginService>(context);
  }

  @override
  dispose() {
    // Es important SEMPRE realitzar el dispose del controller.
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 120,
              child: AnimatedLogo(animation: animation),
            ),
            if (loginService.isLoginOrRegister) loginOrRegisterForm(),
            SizedBox(height: 10),
            loginOrRegisterButtons()
          ],
        ),
      ),
    );
  }

  Widget loginOrRegisterButtons() {
    return ToggleButtons(
      direction: Axis.horizontal,
      onPressed: (int index) {
        loginService.opcioMenu(index);
      },
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      selectedBorderColor: Colors.indigo,
      selectedColor: Colors.white,
      fillColor: Colors.indigo,
      color: Colors.indigo,
      constraints: const BoxConstraints(
        minHeight: 40.0,
        minWidth: 120.0,
      ),
      isSelected: loginService.selectedEvent,
      children: events,
    );
  }

  Widget loginOrRegisterForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(loginService.isLogin ? 'Inicia sessió' : 'Registra\'t'),
        Container(
          width: 300.0,
          child: Form(
            key: _key,
            child: Column(
              children: <Widget>[
                TextFormField(
                  initialValue: '',
                  validator: (text) {
                    if (text!.length == 0) {
                      return "Correu es obligatori";
                    } else if (!emailRegExp.hasMatch(text)) {
                      return "Format correu incorrecte";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  maxLength: 50,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    hintText: 'john.doe@gmail.com',
                    labelText: 'Correu',
                    counterText: '',
                    icon: Icon(Icons.email, size: 32.0, color: Colors.indigo),
                  ),
                  onSaved: (text) => _correu = text,
                ),
                TextFormField(
                  initialValue: '',
                  obscureText: true,
                  validator: (text) {
                    if (text!.length == 0) {
                      return "Contrasenya és obligatori";
                    } else if (text.length <= 5) {
                      return "Contrasenya mínim de 5 caràcters";
                    } else if (!contRegExp.hasMatch(text)) {
                      return "Contrasenya incorrecte";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  maxLength: 20,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    hintText: '*****',
                    labelText: 'Contrasenya',
                    counterText: '',
                    icon: Icon(Icons.lock, size: 32.0, color: Colors.indigo),
                  ),
                  onSaved: (text) => _passwd = text,
                ),
                loginService.isLogin
                    ? CheckboxListTile(
                        value: _isChecked,
                        onChanged: (value) {
                          _isChecked = value!;
                          setState(() {});
                        },
                        title: Text('Recorda\'m'),
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: Colors.indigo,
                      )
                    : SizedBox(height: 10),
                IconButton(
                  onPressed: () => _loginRegisterRequest(),
                  icon: Icon(
                    Icons.arrow_forward,
                    size: 42.0,
                    color: Colors.indigo,
                  ),
                ),
                loginService.isLoading
                    ? CircularProgressIndicator()
                    : Container(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _loginRegisterRequest() async {
    if (_key.currentState!.validate()) {
      _key.currentState!.save();
      // Aquí es realitzaria la petició de login a l'API o similar
      await loginService.loginOrRegister(_correu, _passwd);
      if (loginService.accesGranted) {
        Navigator.pushReplacementNamed(context, 'home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(loginService.errorMessage),
        ));
      }
    }
  }
}

class AnimatedLogo extends AnimatedWidget {
  // Maneja los Tween estáticos debido a que estos no cambian.
  static final _opacityTween = Tween<double>(begin: 0.1, end: 1.0);
  static final _sizeTween = Tween<double>(begin: 0.0, end: 100.0);

  AnimatedLogo({Key? key, required Animation<double> animation})
      : super(key: key, listenable: animation);

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable as Animation<double>;
    return Opacity(
      opacity: _opacityTween.evaluate(animation),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        height: _sizeTween.evaluate(animation), // Aumenta la altura
        width: _sizeTween.evaluate(animation), // Aumenta el ancho
        child: Icon(Icons.shopping_bag,
            size: 100, color: Colors.indigo), //FlutterLogo(),
      ),
    );
  }
}

const List<Widget> events = <Widget>[
  Text('Inicia sessió'),
  Text('Registra\'t'),
];
