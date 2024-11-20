// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract IoTDeviceManager {
    struct Device {
        string deviceId;
        address owner;
        string data;          // Información de los datos del sensor
        uint256 timestamp;
        string sensorType;
        string location;
        string client;
        bool isActive;
        uint256 installationDate;
        string protocolType;
        string brand;
        string model;
    }

    mapping(string => Device) private devices;
    string[] private deviceIds;

    event DeviceUpdated(string deviceId, string data, uint256 timestamp);

    // Registro de un nuevo dispositivo
    function registerDevice(
        string memory _deviceId,
        string memory _sensorType,
        string memory _location,
        string memory _client,
        uint256 _installationDate,
        string memory _protocolType,
        string memory _brand,
        string memory _model
    ) public {
        require(bytes(devices[_deviceId].deviceId).length == 0, "Device already registered");

        devices[_deviceId] = Device({
            deviceId: _deviceId,
            owner: msg.sender,
            data: "",
            timestamp: block.timestamp,
            sensorType: _sensorType,
            location: _location,
            client: _client,
            isActive: true,
            installationDate: _installationDate,
            protocolType: _protocolType,
            brand: _brand,
            model: _model
        });

        deviceIds.push(_deviceId);
    }

    // Actualización de datos del sensor
    function updateDeviceData(string memory _deviceId, string memory _data) public {
        require(bytes(devices[_deviceId].deviceId).length != 0, "Device not found.");
        require(devices[_deviceId].owner == msg.sender, "No eres el propietario del dispositivo.");

        devices[_deviceId].data = _data;
        devices[_deviceId].timestamp = block.timestamp;

        emit DeviceUpdated(_deviceId, _data, block.timestamp);
    }

    // Función auxiliar para convertir uint256 a string
    function uintToString(uint256 _value) private pure returns (string memory) {
        if (_value == 0) {
            return "0";
        }
        uint256 temp = _value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (_value != 0) {
            buffer[--digits] = bytes1(uint8(48 + _value % 10));
            _value /= 10;
        }
        return string(buffer);
    }

    // Obtener información detallada del dispositivo con descripción
    function getDevice(string memory _deviceId)
        public
        view
        returns (
            string memory ownerDescription,
            string memory dataDescription,
            string memory timestampDescription,
            string memory sensorTypeDescription,
            string memory locationDescription,
            string memory clientDescription,
            string memory isActiveDescription,
            string memory installationDateDescription,
            string memory protocolTypeDescription,
            string memory brandDescription,
            string memory modelDescription
        )
    {
        require(bytes(devices[_deviceId].deviceId).length != 0, "Device not found.");

        Device memory device = devices[_deviceId];

        // Definir descripciones legibles
        ownerDescription = string(abi.encodePacked("Propietario del dispositivo: ", addressToString(device.owner)));
        dataDescription = string(abi.encodePacked("Datos del sensor: ", device.data));
        
        // Convertir timestamp a string y concatenar sin caracteres especiales
        string memory timestampStr = uintToString(device.timestamp);
        timestampDescription = string(abi.encodePacked("Ultima actualizacion (timestamp): ", timestampStr));
        
        sensorTypeDescription = string(abi.encodePacked("Tipo de sensor: ", device.sensorType));
        locationDescription = string(abi.encodePacked("Ubicacion: ", device.location));
        clientDescription = string(abi.encodePacked("Cliente asociado: ", device.client));
        isActiveDescription = device.isActive ? "Estado del dispositivo: Activo" : "Estado del dispositivo: Inactivo";
        installationDateDescription = string(abi.encodePacked("Fecha de instalacion: ", uintToString(device.installationDate)));
        protocolTypeDescription = string(abi.encodePacked("Tipo de protocolo: ", device.protocolType));
        brandDescription = string(abi.encodePacked("Marca del dispositivo: ", device.brand));
        modelDescription = string(abi.encodePacked("Modelo del dispositivo: ", device.model));

        return (
            ownerDescription,
            dataDescription,
            timestampDescription,
            sensorTypeDescription,
            locationDescription,
            clientDescription,
            isActiveDescription,
            installationDateDescription,
            protocolTypeDescription,
            brandDescription,
            modelDescription
        );
    }

    // Función auxiliar para convertir address a string
    function addressToString(address _address) private pure returns (string memory) {
        bytes32 value = bytes32(uint256(uint160(_address)));
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(42);
        str[0] = '0';
        str[1] = 'x';
        for (uint i = 0; i < 20; i++) {
            str[2+i*2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3+i*2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }

    // Cambiar el estado del dispositivo (activo/inactivo)
    function toggleDeviceStatus(string memory _deviceId, bool _isActive) public {
        require(bytes(devices[_deviceId].deviceId).length != 0, "Device not found.");
        require(devices[_deviceId].owner == msg.sender, "No eres el propietario del dispositivo.");
        devices[_deviceId].isActive = _isActive;
    }

    // Función pública para obtener el estado de un dispositivo (solo algunos datos)
    function getDeviceStatus(string memory _deviceId)
        public
        view
        returns (
            string memory, 
            bool
        )
    {
        require(bytes(devices[_deviceId].deviceId).length != 0, "Device not found.");

        Device memory device = devices[_deviceId];
        return (
            device.deviceId, // Devuelve el ID del dispositivo
            device.isActive  // Devuelve si el dispositivo está activo
        );
    }
}
