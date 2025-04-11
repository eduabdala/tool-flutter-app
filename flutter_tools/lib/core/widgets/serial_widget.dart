import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../services/serial_handler.dart';

class SerialCommunicationPanel extends StatefulWidget {
  final List<Widget> extraButtons;

  const SerialCommunicationPanel({
    super.key,
    this.extraButtons = const [],
  });

  @override
  _SerialCommunicationPanelState createState() =>
      _SerialCommunicationPanelState();
}

class _SerialCommunicationPanelState extends State<SerialCommunicationPanel>
    with SingleTickerProviderStateMixin {
  String? _selectedPort;
  int? _selectedBaudRate;
  final PanelController _panelController = PanelController();
  bool _isPanelOpen = false;
  bool isConnected = false;
  bool isPdMode = false;

  late TabController _tabController;
  SerialHandler? _serialHandler;
  String _commandResponse = '';

  List<String> availablePorts = [];
  List<int> availableBaudRates = [
    110,
    300,
    600,
    1200,
    2400,
    4800,
    9600,
    14400,
    19200,
    38400,
    57600,
    115200,
    128000,
    256000
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAvailablePorts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    if (_serialHandler != null && isConnected) {
      _serialHandler!
          .closeConnection();
    }
    super.dispose();
  }

  void _loadAvailablePorts() {
    availablePorts = SerialHandler.listAvailablePorts();
    if (availablePorts.isNotEmpty) {
      setState(() {
        _selectedPort =
            availablePorts.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      controller: _panelController,
      maxHeight: 300,
      minHeight: 40,
      panelBuilder: (sc) => _buildPanel(sc),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16.0),
        topRight: Radius.circular(16.0),
      ),
      onPanelOpened: () {
        setState(() {
          _isPanelOpen = true;
        });
      },
      onPanelClosed: () {
        setState(() {
          _isPanelOpen = false;
        });
      },
      body: Container(),
    );
  }

  Widget _buildPanel(ScrollController sc) {
    return Padding(
      padding: const EdgeInsets.all(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildTogglePanelButton(),
          _buildTabBar(),
          Expanded(child: _buildTabBarView())
        ],
      ),
    );
  }

  Widget _buildTogglePanelButton() {
    return IconButton(
      icon: Icon(
        _isPanelOpen ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
        size: 20,
      ),
      onPressed: () {
        if (_isPanelOpen) {
          _panelController.close();
        } else {
          _panelController.open();
        }
      },
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: 'Serial Communication'),
        Tab(text: 'Terminal'),
      ],
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildSerialCommunicationTab(),
        _buildTerminalTab(),
      ],
    );
  }

  Widget _buildSerialCommunicationTab() {
    return Column(
      children: [
        _buildSerialCommunicationControls(),
        const SizedBox(height: 10),
        ...widget.extraButtons,
      ],
    );
  }

  Widget _buildSerialCommunicationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPortDropdown(),
        const SizedBox(width: 10),
        _buildBaudRateDropdown(),
        const SizedBox(width: 10),
        _buildConnectionButton(),
        const SizedBox(width: 10),
        _buildModeButton(),
      ],
    );
  }

  Widget _buildPortDropdown() {
    return DropdownButton<String>(
      hint: const Text('Port'),
      value: _selectedPort,
      items: availablePorts.map((port) {
        return DropdownMenuItem<String>(
          value: port,
          child: Text(port),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedPort = value;
        });
      },
    );
  }

  Widget _buildBaudRateDropdown() {
    return DropdownButton<int>(
      hint: const Text('Baudrate'),
      value: _selectedBaudRate ?? 115200,
      items: availableBaudRates.map((baudRate) {
        return DropdownMenuItem<int>(
          value: baudRate,
          child: Text(baudRate.toString()),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedBaudRate = value;
        });
      },
    );
  }

  Widget _buildConnectionButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isConnected ? Colors.green : Colors.red,
        foregroundColor: Colors.white,
      ),
      onPressed: () async {
        setState(() {
          isConnected = !isConnected;
        });

        if (_selectedPort != null && _selectedBaudRate != null) {
          _serialHandler =
              SerialHandler(_selectedPort!, baudRate: _selectedBaudRate!);
          int result = await _serialHandler!.openConnection();
          if (result == 0) {
            setState(() {
              isConnected = true;
            });
          } else {
            setState(() {
              isConnected = false;
            });
          }
        } else {
          setState(() {
            isConnected = false;
          });
          print("Selecione uma porta e uma taxa de transmissão válidas.");
        }
      },
      child: Text(isConnected ? "Connected" : "Disconnected"),
    );
  }

  Widget _buildModeButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isPdMode ? Colors.blue : Colors.purple,
        foregroundColor: Colors.white,
      ),
      onPressed: () {
        setState(() {
          isPdMode = !isPdMode;
        });
      },
      child: Text(isPdMode ? "PD" : "CLI"),
    );
  }

  Widget _buildTerminalTab() {
    return Column(
      children: [
        _buildCommandInput(),
        const SizedBox(height: 10),
        _buildSendCommandButton(),
        const SizedBox(height: 20),
        _buildCommandResponse(),
      ],
    );
  }

  Widget _buildCommandInput() {
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Digite um comando',
        border: OutlineInputBorder(),
      ),
      onSubmitted: (command) {
        print('Comando enviado: $command');
        _sendCommand(command);
      },
    );
  }

  Widget _buildSendCommandButton() {
    return ElevatedButton(
      onPressed: () {
        print('Comando enviado');
      },
      child: Text('Enviar Comando'),
    );
  }

  Widget _buildCommandResponse() {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              Text(_commandResponse, style: TextStyle(fontFamily: 'Courier')),
        ),
      ),
    );
  }

  void _sendCommand(String command) {
    if (_serialHandler != null && isConnected) {
      _serialHandler!.sendData(command).then((response) {
        setState(() {
          _commandResponse = response!;
        });
      });
    }
  }
}
