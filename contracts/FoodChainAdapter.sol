pragma solidity ^0.4.22;

import "./InterledgerSenderInterface.sol";

contract FoodChainAdapter is InterledgerSenderInterface {
    address owner;
    
    event LogInterledgerEventCommitted(uint256 id);
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
     * @dev Function will be called by the FSC supervisor component to notify the interledger component.
     * @param id The identifier of  the data (internal to the supervisor)
     * @param boxId The relevant box id
     * @param sessionId The relevant box session id
     * @param signatures The generated signatures of the given session
     */
    function registerInterledgerEvent(
        uint256 id, 
        string boxId, 
        string sessionId, 
        bytes32[8] signatures
    ) public onlyOwner {
        bytes memory data = abi.encode(boxId, sessionId, signatures);
        emit InterledgerEventSending(id, data);
    }
    
    function interledgerCommit(uint256 id) public {
        emit LogInterledgerEventCommitted(id);
    }
    
    function interledgerAbort(uint256 id, uint256 reason) public {
        emit LogInterledgerEventAborted(id, reason);
    }
}