import 'package:gerenciador_contas/helpers/contas_helper.dart';
import 'package:flutter/material.dart';

class ContasPage extends StatefulWidget {

  final Conta conta;

  ContasPage({this.conta});

  @override
  _ContasPageState createState() => _ContasPageState();
}

class _ContasPageState extends State<ContasPage> {

  bool _contaEdited = false;
  final _descricaoFocus = FocusNode();

  // controladores usados para salvar os novos campos editáveis
  final _descController = TextEditingController();
  final _estabController = TextEditingController();
  final _valorController = TextEditingController();
  final _contaParceladaController = TextEditingController();
  final _qntdParcelasController = TextEditingController();
  final _situacaoController = TextEditingController();

  Conta _editedConta;

  @override
  void initState() {
    super.initState();

    if(widget.conta == null) {
      _editedConta = Conta(); // se ele não for editar uma conta, ele criará uma nova conta
    } else {
      _editedConta = Conta.fromMap(widget.conta.toMap());

      _descController.text = _editedConta.descricao;
      _estabController.text = _editedConta.estabelecimento;
      _valorController.text = _editedConta.valor;
      _contaParceladaController.text = _editedConta.contaParcelada;
      _qntdParcelasController.text = _editedConta.qntdParcelas;
      _situacaoController.text = _editedConta.qntdParcelas;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text(_editedConta.descricao ?? "Nova Conta"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            if(_editedConta.descricao != null && _editedConta.descricao.isNotEmpty) {
              Navigator.pop(context, _editedConta); // remove a tela atual e volta para a anterior passando o contato editado
            } else {
              FocusScope.of(context).requestFocus(_descricaoFocus);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.green,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _descController,
                focusNode: _descricaoFocus,
                decoration: InputDecoration(labelText: "Descrição"),
                onChanged: (text) {
                  _contaEdited = true;
                  setState(() {
                    _editedConta.descricao = text;
                  });
                },
              ),
              TextField(
                controller: _estabController,
                decoration: InputDecoration(labelText: "Estabelecimento"),
                onChanged: (text) {
                  _contaEdited = true;
                  _editedConta.estabelecimento = text;
                },
              ),
              TextField(
                controller: _valorController,
                decoration: InputDecoration(labelText: "Valor"),
                onChanged: (text) {
                  _contaEdited = true;
                  _editedConta.valor = text;
                },
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _contaParceladaController,
                decoration: InputDecoration(labelText: "Conta Parcelada"),
                onChanged: (text) {
                  _contaEdited = true;
                  _editedConta.contaParcelada = text;
                },
              ),
              TextField(
                controller: _qntdParcelasController,
                decoration: InputDecoration(labelText: "Quantidade Parcelas"),
                onChanged: (text) {
                  _contaEdited = true;
                  _editedConta.qntdParcelas = text;
                },
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _situacaoController,
                decoration: InputDecoration(labelText: "Situacao"),
                onChanged: (text) {
                  _contaEdited = true;
                  _editedConta.situacao = text;
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _requestPop() {
    if(_contaEdited){
      showDialog(context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Descartar Alterações?"),
              content: Text("Se sair as alterações serão perdidas."),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancelar"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("Sim"),
                  onPressed: () {
                    // aqui o pop é dado duas vezes para ele sair do:
                    // Dialog, e depois do
                    // contact_page, e ir direto para nossa HomePage
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                )
              ],
            );
          }
      );
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
