pragma solidity ^0.4.22;

import "./InterledgerSenderKSIInterface.sol";

contract FoodChainKSIAdapter is InterledgerSenderKSIInterface {
    address owner;
    mapping(uint256 => bytes) ksiIds;
    
    event LogInterledgerEventCommitted(uint256 id, bytes data);
    event LogInterledgerEventAborted(uint256 id, uint256 reason);
    
    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can call this function"
        );
        _;
    }
    
    /**
     * @dev Function will be called by the FSC supervisor component to notify the KSI interledger component.
     * @param id The identifier of  the data (internal to the supervisor)
     * @param data The data to relay to KSI
     */
    function registerInterledgerKSIEvent(
        uint256 id,
        bytes memory data
    ) public onlyOwner {
        emit InterledgerEventSending(id, data);
    }
    
    function interledgerCommit(uint256 id, bytes memory data) public {
        ksiIds[id] = data;
        emit LogInterledgerEventCommitted(id, data);
    }
    
    function interledgerAbort(uint256 id, uint256 reason) public {
        emit LogInterledgerEventAborted(id, reason);
    }

    /**
     * @dev Function called to retrieve a KSI id based on an interledger transaction id
     * @param id The interledger transaction id
     * @return bytes The KSI id (uuid) that was created in the transaction
     */
    function retrieveKSIId(uint256 id) public view returns (bytes memory) {
        return ksiIds[id];
    }
}