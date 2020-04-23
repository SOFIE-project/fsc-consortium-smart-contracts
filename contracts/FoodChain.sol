pragma solidity ^0.4.22;
pragma experimental ABIEncoderV2;

contract FoodChain {
    enum BoxStates {
        ASSIGNED,
        BOX_PRODUCT, 
        HANDOVER_FARM_TRANSPORT,
        HANDOVER_TRANSPORT_WAREHOUSE,
        BOX_WAREHOUSE,
        BOX_WAREHOUSE_PACKETIZED,
        HANDOVER_WAREHOUSE_TRANSPORT,
        HANDOVER_TRANSPORT_SUPERMARKET
    }
    
    enum EntityTypes { FARM, TRANSPORT, WAREHOUSE }
    enum PlatformTypes { FARMING, TRANSPORT, WAREHOUSE }
    enum ActorTypes { PRODUCER, TRANSPORTER, WAREHOUSE_EMPLOYEE, SM_EMPLOYEE }
    
    struct Entity {
        string id;                  // hashed id of either the crop/transport/warehouse id
        string name;
        address platform;
        EntityTypes entityType;
        string metadata;
        uint timestamp;
    }
    
    struct Platform {
        address id;                 // wallet address (public key)
        string name;
        PlatformTypes platformType;
        string metadata;
        uint timestamp;
    }
    
    struct Actor {
        string id;                  // keycloak uuid
        address platform;           // platform of the actor
        ActorTypes actorType;
        string metadata;
        uint timestamp;
    }
    
    struct Box {
        string id;                  // rfid
        address platform;           // assigned platform
        string metadata;
        uint timestamp;
    }
    
    struct BoxSession {
        bytes32 id;      // The generated sessionId
        string boxId;    // The id of the box
        string actorId;  // The actor that is holding the box
        address platform; // The platform  that has the box
        BoxStates state; // The transition state of the box
        string metadata; // Metadata of the box session
        uint timestamp;  // Session timestamp
    }
    
    address owner;
    mapping(address => Platform) platforms;
    mapping(string => Actor) actors;
    mapping(string => Entity) entities;
    mapping(string => Box) boxes;
    mapping(string => BoxSession) boxSessions;  // Maps a boxId to a session
    
    event LogPlatformRegistered(address id, string name, PlatformTypes platformType, string metadata, uint timestamp);
    event LogPlatformRemoved(address id, string name, PlatformTypes platformType, string metadata, uint timestamp);
    event LogActorRegistered(string id, address platform, ActorTypes actorType, string metadata, uint timestamp);
    event LogActorRemoved(string id, address platform, ActorTypes actorType, string metadata, uint timestamp);
    event LogEntityRegistered(string id, string name, address platform, EntityTypes entityType, string metadata, uint timestamp);
    event LogEntityRemoved(string id, string name, address platform, EntityTypes entityType, string metadata, uint timestamp);
    event LogBoxRegistered(string id, address platform, string metadata, uint timestamp);
    event LogBoxSession(bytes32 sessionId, string boxId, string actorId, address platform, string metadata, uint timestamp);
    event LogBoxProduct(bytes32 sessionId, string actorId, address platform, string boxId, string payload, string cropId, uint timestamp);
    event LogBoxWarehouse(bytes32 sessionId, string actorId, address platform, string boxId, string payload, string warehouseId, uint timestamp);
    event LogPacketizeProduct(bytes32 sessionId, string actorId, address platform, string boxId, string payload, string warehouseId, uint timestamp);
    event LogHandoverFarmTransport(bytes32 sessionId, string sourceActorId, address sourcePlatform, string destinationActorId, address destinationPlatform, string boxId, string payload, uint timestamp);
    event LogHandoverTransportWarehouse(bytes32 sessionId, string sourceActorId, address sourcePlatform, string destinationActorId, address destinationPlatform, string boxId, string payload, uint timestamp);
    event LogHandoverWarehouseTransport(bytes32 sessionId, string sourceActorId, address sourcePlatform, string destinationActorId, address destinationPlatform, string boxId, string payload, uint timestamp);
    event LogHandoverTransportSupermarket(bytes32 sessionId, string sourceActorId, address sourcePlatform, string destinationActorId, string boxId, string payload, uint timestamp);
    
    
    constructor() public {
        owner = msg.sender; // supervisor address
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the supervisor can call this function"
        );
        _;
    }
    
    modifier onlyPlatform(address platform) {
        require(
            platform == address(0) || platforms[platform].timestamp > 0,
            "Only registered platforms can call this function"
        );
        _;
    }
    
    modifier onlyActor(string actorId) {
        require(
            actors[actorId].timestamp > 0,
            "Only registered actors can call this function"
        );
        _;
    }
    
    modifier onlyPlatformActor(address platform, string actorId) {
        require(
            actors[actorId].platform == platform,
            "Only actors of given platform can call this function"
        );
        _;
    }
    
    modifier onlyBox(string boxId) {
        require(
            boxes[boxId].timestamp > 0,
            "Only registered boxes can call this function"
        );
        _;
    }
    
    modifier onlyBoxSession(string boxId) {
        require(
            boxSessions[boxId].timestamp > 0,
            "Only boxes with active session can call this function"
        );
        _;
    }
    
    function updateBoxState(
        string boxId,
        string actorId,
        address platform,
        BoxStates state
    ) internal {
        boxSessions[boxId].actorId = actorId;
        boxSessions[boxId].platform = platform;
        boxSessions[boxId].state = state;
        boxSessions[boxId].timestamp = now;
    }
    
    // Registers a new IoT platform
    function registerPlatform(
        address id, 
        string name, 
        PlatformTypes platformType, 
        string metadata
    ) public onlyOwner {
        require(platforms[id].timestamp == 0, "Platform already registered");
        platforms[id] = Platform(id, name, platformType, metadata, now);
        emit LogPlatformRegistered(id, name, platformType, metadata, now);
    }
    
    // Removes a registered IoT platform
    function removePlatform(
        address id
    ) public onlyOwner onlyPlatform(id) {
        Platform memory platform = platforms[id];
        delete platforms[id];
        emit LogPlatformRemoved(id, platform.name, platform.platformType, platform.metadata, now);
    }
    
    // Registers an actor for an IoT Platform
    function registerActor(        
        string id,
        address platform,
        ActorTypes actorType,
        string metadata
    ) public onlyOwner onlyPlatform(platform){
        require(actors[id].timestamp == 0, "Actor is already registered");
        actors[id] = Actor(id, platform, actorType, metadata, now);
        emit LogActorRegistered(id, platform, actorType, metadata, now);        
    }
    
    // Removes an actor
    function removeActor(
        string id,
        address platform
    ) public onlyOwner onlyPlatformActor(platform, id) {
        Actor memory actor = actors[id];
        delete actors[id];
        emit LogActorRemoved(id, platform, actor.actorType, actor.metadata, now);
    }
    
    // Registers a new entity
    function registerEntity(
        string id,
        string name,
        address platform,
        EntityTypes entityType,
        string metadata
    ) public onlyOwner onlyPlatform(platform) {
        require(entities[id].timestamp == 0, "Entity is already registered");
        entities[id] = Entity(id, name, platform, entityType, metadata, now);
        emit LogEntityRegistered(id, name, platform, entityType, metadata, now);
    }
    
    // Removes an entity
    function removeEntity(
        string id
    ) public onlyOwner {
        require(entities[id].timestamp > 0, "Entity does not exist");
        Entity memory entity = entities[id];
        delete entities[id];
        emit LogEntityRemoved(id, entity.name, entity.platform, entity.entityType, entity.metadata, now);
    }
    
    // Registers a new box for a Platform
    function registerBox(
        string id,
        address platform,
        string metadata
    ) public onlyOwner onlyPlatform(platform){
        boxes[id] = Box(id, platform, metadata, now);
        emit LogBoxRegistered(id, platform, metadata, now);
    }
    
    // Registers multiple boxes to a given actor 
    function registerBoxSession(
        string[] boxIds, 
        string actorId,
        address platform,
        string metadata
    ) public onlyOwner onlyPlatformActor(platform, actorId){
        for(uint i=0; i<boxIds.length; i++) {
            string memory boxId = boxIds[i];
            
            // Generate a unique session id
            bytes32 sessionId = keccak256(
                abi.encodePacked(boxId, actorId, platform, now)
            );
            
            boxSessions[boxId] = BoxSession(sessionId, boxId, actorId, platform, BoxStates.ASSIGNED, metadata, now);
            emit LogBoxSession(sessionId, boxId, actorId, platform, metadata, now);
        }
    }
    
    // Register farm product information to the given boxes
    function boxProduct(
        string[] boxIds,
        string actorId,
        address platform,
        string cropId,
        string payload
    ) public onlyOwner onlyPlatformActor(platform, actorId) {
        for(uint i=0; i<boxIds.length; i++){
            string memory boxId = boxIds[i];
            BoxSession memory boxSession = boxSessions[boxId];
            
            require(
                boxSession.timestamp > 0,
                "Box must have an active session"
            );
            
            updateBoxState(boxId, actorId, platform, BoxStates.BOX_PRODUCT);
            emit LogBoxProduct(boxSession.id, actorId, platform, boxId, payload, cropId, now);
        }
    }
    
    // Handover between a producer actor and a transport actor
    function handoverFarmTransport(
        string[] boxIds,
        string sourceActorId, 
        address sourcePlatform, 
        string destinationActorId, 
        address destinationPlatform, 
        string payload
    ) public onlyOwner onlyPlatformActor(sourcePlatform, sourceActorId) onlyPlatformActor(destinationPlatform, destinationActorId) {
        for(uint i=0; i<boxIds.length; i++) {
            string memory boxId = boxIds[i];
            BoxSession memory boxSession = boxSessions[boxId];
            
            require(
                boxSession.timestamp > 0,
                "Box must have an active session"
            );
            
            updateBoxState(boxId, destinationActorId, destinationPlatform, BoxStates.HANDOVER_FARM_TRANSPORT);
            emit LogHandoverFarmTransport(boxSession.id, sourceActorId, sourcePlatform, destinationActorId, destinationPlatform, boxId, payload, now);
        }
    }
    
    // Handover between a transport actor and a warehouse actor
    function handoverTransportWarehouse(
        string[] boxIds,
        string sourceActorId, 
        address sourcePlatform, 
        string destinationActorId, 
        address destinationPlatform, 
        string[] payloads
    ) public onlyOwner onlyPlatformActor(sourcePlatform, sourceActorId) onlyPlatformActor(destinationPlatform, destinationActorId) {
        require(
            boxIds.length == payloads.length,
            "length of boxes must match payloads length"
        );

        for(uint i=0; i<boxIds.length; i++) {
            string memory boxId = boxIds[i];
            BoxSession memory boxSession = boxSessions[boxId];
            
            require(
                boxSession.timestamp > 0,
                "Box must have an active session"
            );
            
            updateBoxState(boxId, destinationActorId, destinationPlatform, BoxStates.HANDOVER_TRANSPORT_WAREHOUSE);
            emit LogHandoverTransportWarehouse(boxSession.id, sourceActorId, sourcePlatform, destinationActorId, destinationPlatform, boxId, payloads[i], now);
        }
    }
    
    // Register warehouse information about the given boxes
    function boxWarehouse(
        string[] boxIds,
        string actorId,
        address platform,
        string warehouseId,
        string[] payloads
    ) public onlyOwner onlyPlatformActor(platform, actorId) {
        require(
            boxIds.length == payloads.length,
            "length of boxes must match payloads length"
        );
        
        for(uint i=0; i<boxIds.length; i++) {
            string memory boxId = boxIds[i];
            BoxSession memory boxSession = boxSessions[boxId];
            
            require(
                boxSession.timestamp > 0,
                "Box must have an active session"
            );
            
            updateBoxState(boxId, actorId, platform, BoxStates.BOX_WAREHOUSE);
            emit LogBoxWarehouse(boxSession.id, actorId, platform, boxId, payloads[i], warehouseId, now);
        }
    }
    
    // Register packetazation information about the boxes
    function packetizeProduct(
        string[] boxIds,
        string actorId,
        address platform,
        string warehouseId,
        string[] payloads
    ) public onlyOwner onlyPlatformActor(platform, actorId) {
        require(
            boxIds.length == payloads.length,
            "Length of boxes must match payloads length"
        );
        
        for(uint i=0; i<boxIds.length; i++) {
            string memory boxId = boxIds[i];
            BoxSession memory boxSession = boxSessions[boxId];
            
            require(
                boxSession.timestamp > 0,
                "Box must have an active session"
            );
            
            updateBoxState(boxId, actorId, platform, BoxStates.BOX_WAREHOUSE_PACKETIZED);
            emit LogPacketizeProduct(boxSession.id, actorId, platform, boxId, payloads[i], warehouseId, now);
        }
    }
    
    // Handover between a warehouse actor and a transport actor
    function handovertWarehouseTransport(
        string[] boxIds,
        string sourceActorId, 
        address sourcePlatform, 
        string destinationActorId, 
        address destinationPlatform, 
        string[] payloads
    ) public onlyOwner onlyPlatformActor(sourcePlatform, sourceActorId) onlyPlatformActor(destinationPlatform, destinationActorId) {
        require(
            boxIds.length == payloads.length,
            "Length of boxes must match payloads length"
        );
        
        for(uint i=0; i<boxIds.length; i++) {
            string memory boxId = boxIds[i];
            BoxSession memory boxSession = boxSessions[boxId];
            
            require(
                boxSession.timestamp > 0,
                "Box must have an active session"
            );
            
            updateBoxState(boxId, destinationActorId, destinationPlatform, BoxStates.HANDOVER_WAREHOUSE_TRANSPORT);
            emit LogHandoverWarehouseTransport(boxSession.id, sourceActorId, sourcePlatform, destinationActorId, destinationPlatform, boxId, payloads[i], now);
        }
    }
    
    // Handover between a transport actor and a supermarket actor
    function handoverTransportSupermarket(
        string[] boxIds,
        string sourceActorId, 
        address sourcePlatform, 
        string destinationActorId, 
        string[] payloads
    ) public onlyOwner onlyPlatformActor(sourcePlatform, sourceActorId) onlyActor(destinationActorId) {
        require(
            boxIds.length == payloads.length,
            "length of boxes must match payloads length"
        );

        for(uint i=0; i<boxIds.length; i++) {
            string memory boxId = boxIds[i];
            BoxSession memory boxSession = boxSessions[boxId];
            
            require(
                boxSession.timestamp > 0,
                "Box must have an active session"
            );
            
            updateBoxState(boxId, destinationActorId, address(0), BoxStates.HANDOVER_TRANSPORT_SUPERMARKET);
            emit LogHandoverTransportSupermarket(boxSession.id, sourceActorId, sourcePlatform, destinationActorId, boxId, payloads[i], now);
        }
    }
    
    // Getters

    function getPlatform(address platformId) public view returns (
        address id,
        string name,
        PlatformTypes platformType,
        string metadata,
        uint timestamp
    ){
        Platform storage platform = platforms[platformId];
        
        return (
            platform.id,
            platform.name,
            platform.platformType,
            platform.metadata,
            platform.timestamp
        );
    }
    
    function getEntity(string _id) public view returns (
        string id,
        string name,
        address platform,
        EntityTypes entityType,
        string metadata,
        uint timestamp
    ){
        Entity storage entity = entities[_id];
        
        return (
            entity.id,
            entity.name,
            entity.platform,
            entity.entityType,
            entity.metadata,
            entity.timestamp
        );
    } 
    
    function getActor(string actorId) public view returns (
        string id,               
        address platform,
        ActorTypes actorType,
        string metadata,
        uint timestamp
    ){
        Actor storage actor = actors[actorId];
        
        return (
            actor.id,
            actor.platform,
            actor.actorType,
            actor.metadata,
            actor.timestamp
        );
    }
    
    function getBox(string _boxId) public view returns (
        string boxId,
        bytes32 sessionId,
        address assignedPlatform,
        string currentActorId,
        address currentPlatform,
        BoxStates currentState,
        string boxMetadata,
        string sessionMetadata,
        uint creationTimestamp,
        uint updateTimestamp
    ){
        Box storage box = boxes[_boxId];
        BoxSession storage boxSession = boxSessions[_boxId];
        
        return (
            box.id,
            boxSession.id,
            box.platform,
            boxSession.actorId,
            boxSession.platform,
            boxSession.state,
            box.metadata,
            boxSession.metadata,
            box.timestamp,
            boxSession.timestamp
        );
    }
}