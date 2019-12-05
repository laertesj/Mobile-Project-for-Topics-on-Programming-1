import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gerenciador_contas/helpers/contas_helper.dart';
import 'contas_page.dart';

enum OrderOptions {orderaz, orderza}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContaHelper helper = ContaHelper();

  // lista de contas
  List<Conta> contas = List();
  String valorTotal;
  String showValorTotal;

  // carregar todas as contas já salvas
  @override
  void initState() {
    super.initState();

    _getAllContas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Suas Contas \$"),
        backgroundColor: Colors.green,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de A-Z"),
                value: OrderOptions.orderaz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de Z-A"),
                value: OrderOptions.orderza,
              )
            ],
            onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // aqui ele irá abrir a página para adicionar uma nova conta a lista
          _showContaPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: contas.length,
          itemBuilder: (context, index) {
            return _contaCard(context, index);
          }
      ),
    );
  }

  // widget para exibir o cartão de um contato na lista
  Widget _contaCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        color: Colors.lightGreen[300],
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(contas[index].descricao ?? "",
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 22.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Text("Estabelecimento: " + contas[index].estabelecimento ?? "",
                      style: TextStyle(fontFamily: 'RobotoMono', fontSize: 18.0),
                    ),
                    Text("Valor: R\$" + contas[index].valor ?? "",
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Text("Parcelada: " + contas[index].contaParcelada ?? "",
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Text("Quantidade Parcelas: " + contas[index].qntdParcelas ?? "",
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Text("Situação: " + contas[index].situacao ?? "",
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: () {
        _showOptions(context, index);
      }
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: (){},
          builder: (context) {
            return Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text("Editar",
                      style: TextStyle(color: Colors.teal, fontSize: 20.0),
                      ),
                      onPressed: (){
                        Navigator.pop(context);
                        _showContaPage(conta: contas[index]);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text("Excluir",
                        style: TextStyle(color: Colors.teal, fontSize: 20.0),
                      ),
                      onPressed: (){
                        helper.deleteConta(contas[index].id);
                        setState(() {
                          contas.removeAt(index);
                          Navigator.pop(context);
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }
    );
  }

  void _showContaPage({Conta conta}) async {
    final recConta = await Navigator.push(context,
        MaterialPageRoute(builder: (context)=>ContasPage(conta: conta,))
    );
    if(recConta != null) { // verifica se ele retornou alguma conta
      if(conta != null) { // verifica se ele tinha enviado alguma conta, se sim atualiza as informações da conta enviada
        await helper.updateConta(recConta);
        _getAllContas();
      } else { // se ele recebeu alguma conta, então criamos uma nova conta, ou seja, salvamos uma nova conta
        await helper.saveConta(recConta);
      }
      _getAllContas();
    }
  }

  void _getTotalValue() {
    helper.getTotalValue().then((total) {
      setState(() {
        valorTotal = total;
      });
    });
  }

  void _getAllContas() {
    helper.getAllContas().then((list) {
      setState(() {
        contas = list;
      });
    });
  }

  void _orderList(OrderOptions result) {
    switch(result) {
      case OrderOptions.orderaz:
        contas.sort((a, b) {
          return a.descricao.toLowerCase().compareTo(b.descricao.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        contas.sort((a, b) {
          return b.descricao.toLowerCase().compareTo(a.descricao.toLowerCase());
        });
        break;
    }
    setState(() {

    });
  }
}
