import 'dart:developer';
import 'dart:typed_data';

import 'package:laundrivr/src/data/ble_adapter.dart';
import 'package:laundrivr/src/data/store/ble_functional_data_store.dart';
import 'package:laundrivr/src/data/utils/cscsw_constants.dart';
import 'package:laundrivr/src/data/utils/cscsw_utils.dart';

import 'enum/ble_data_machine_process_enum.dart';

class BleDataMachine {
  final BleAdapter _bleFunctionalTest;

  /// A list of the bytes that have been received (buffer)
  final List<int> _receivedBytes = [];

  /// The current state of the data machine
  DataMachineProcess _state = DataMachineProcess.start;

  final BleFunctionalDataStore _bleFunctionalDataStore =
      BleFunctionalDataStore();

  /// The data machine constructor
  BleDataMachine(this._bleFunctionalTest);

  /// Writes the given data to the BLE device
  writeData(List<List<int>> data) {
    // log data being sent
    log("Sending data: ${data.map((e) => e.map((e) => e.toRadixString(16)).join(" ")).join(" ")}");
    // write data to the machine
    _bleFunctionalTest.writeData(data);
  }

  /// A function that accepts data from the remote machine
  onDataReceived(List<int> data) async {
    log("data received: $data");

    // print the data as hex
    log("data received as hex: ${CscswUtils.convertBytesToHexString(data)}");

    // add the data to the buffer
    _receivedBytes.addAll(data);

    // if received bytes is empty, return
    if (_receivedBytes.isEmpty) {
      return;
    }

    // check to see if the full packet is valid before processing
    bool isValidPacket = _receivedBytes.length - 5 ==
        CscswUtils.getCompletePacketLengthFromData(_receivedBytes);

    // if its not a valid packet, return
    if (!isValidPacket) {
      return;
    }

    // make a copy of the buffer
    List<int> packet = List.from(_receivedBytes);
    // clear the buffer
    _receivedBytes.clear();

    // log the packet data
    log("packet received: $packet");

    // add a two seconds delay
    await Future.delayed(const Duration(seconds: 1));

    // based on the state, call the appropriate function in a case switch
    switch (_state) {
      case DataMachineProcess.start:
        break;
      case DataMachineProcess.vendorId:
        _processVendorId(packet);
        break;
      case DataMachineProcess.getPrice:
        _processGetPrice(packet);
        break;
      case DataMachineProcess.startCycleExtend:
        break;
    }
  }

  /// The start function that asks the machine for the vendor id
  void start() {
    // create the vendor id packet (asks the CSCSW machine to confirm the vendor id)
    List<int> packet = Uint8List(CscswConstants.cscswVendorId.length + 4);
    List<int> vendorIdBytes = CscswConstants.cscswVendorId.codeUnits;
    List<int> ttiBytes = "TTI".codeUnits;

    List.copyRange(packet, 0, vendorIdBytes);
    // recreate the above line using the copyOfRange function
    List.copyRange(packet, vendorIdBytes.length, ttiBytes);
    packet[vendorIdBytes.length + ttiBytes.length] = 1;

    // set the current process step to the next, which is the vendor id one
    _state = DataMachineProcess.vendorId;

    // format the packet and split it into 20 byte chunks
    List<List<int>> formattedPacket = CscswUtils.splitBytesIntoChunks(
        CscswUtils.formatPacket(packet, "VI"), 20);

    // write the packet to the machine
    writeData(formattedPacket);
  }

  /// Processes the vendor id packet
  void _processVendorId(List<int> data) {
    // construct a packet to get ask the CSCSW machine for price data
    List<int> getPriceData = Uint8List(4);

    for (int i = 0; i < 4; ++i) {
      getPriceData[i] = CscswConstants.token[i + 6];
    }

    if (data.length >= 9) {
      // set the machine type
      List.copyRange(_bleFunctionalDataStore.machineType, 0, data, 9, 10);
    }

    // update the state
    _state = DataMachineProcess.getPrice;

    // format the packet and split it into 20 byte chunks
    List<List<int>> chunksToSend = CscswUtils.splitBytesIntoChunks(
        CscswUtils.formatPacket(getPriceData, "GP"), 20);
    // write the packet to the machine
    writeData(chunksToSend);
  }

  /// Processes the price data
  void _processGetPrice(List<int> data) {
    // log that the price data has been received
    log("price data received: $data");
    // a byte array with the status of the machine
    List<int> statusArray = Uint8List(1);
    // copy the "vend price" data to the data store
    List.copyRange(_bleFunctionalDataStore.vendPrice, 0, data, 6, 8);
    // copy the data to the status array
    List.copyRange(statusArray, 0, data, 8, 9);

    // and integer (1 or 0) representing whether a retry is needed to fetch the price
    int retryPriceRequest = statusArray[0] & 2;

    // set the pulse money
    _bleFunctionalDataStore.pulseMoney = CscswUtils.getPriceFromPacket(data);

    // convert the status array to a binary string
    String statusBinaryString = statusArray[0].toRadixString(2);
    // make a string builder for the current status
    StringBuffer currentStatus = StringBuffer();

    // insert leading zeros to the binary string
    for (int i = 0; i < 8 - statusBinaryString.length; ++i) {
      // insert before, not after
      currentStatus.write("0");
    }

    // add the binary string to the current status
    currentStatus.write(statusBinaryString);

    // write the current status to a string
    String currentStatusString = currentStatus.toString();

    // set the machine status variables
    _bleFunctionalDataStore.startButtonIsEnabled =
        "1" == currentStatusString.substring(5, 6);
    _bleFunctionalDataStore.startButtonIsPressed =
        "1" == currentStatusString.substring(4, 5);
    _bleFunctionalDataStore.canDoTopOff =
        "1" == currentStatusString.substring(3, 4);
    _bleFunctionalDataStore.canDoSuperCycle =
        "1" == currentStatusString.substring(2, 3);

    // create a packet that asks the machine to start/extend
    List<int> seData = Uint8List(
        _bleFunctionalDataStore.vendPrice.length + CscswConstants.token.length);
    List.copyRange(seData, 0, _bleFunctionalDataStore.vendPrice);
    List.copyRange(
        seData, _bleFunctionalDataStore.vendPrice.length, CscswConstants.token);

    // update the state
    _state = DataMachineProcess.startCycleExtend;

    // format the packet and split it into 20 byte chunks
    List<List<int>> chunksToSend = CscswUtils.splitBytesIntoChunks(
        CscswUtils.formatPacket(seData, "SE"), 20);
    // log the chunks to send
    log("se chunks to send: $chunksToSend");
    // write the packet to the machine
    writeData(chunksToSend);
  }
}
