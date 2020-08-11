pragma solidity ^0.4.22;

/**
 * This is the abstract interface to be implemented by potential data sender
 */
contract InterledgerSenderKSIInterface {
    // Event for sending data to another ledger
    event InterledgerEventSending(uint256 id, bytes data);

    /**
     * @dev Function that will be called when the recipient has accepted the data 
     * @param id The identifier of data sending event
     */
    function interledgerCommit(uint256 id, bytes memory data) public;

    /**
     * @dev Function that will be called when the recipient has rejected the data, 
     *      or there have been an error.
     * @param id The identifier of data sending event
     * @param reason The error code indicating the reason for failure
     */
    function interledgerAbort(uint256 id, uint256 reason) public;
}