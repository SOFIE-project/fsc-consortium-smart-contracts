const truffleAssert = require('truffle-assertions')
const FoodChain = artifacts.require('FoodChain')

let platform = [
    "0xb5707BdcD820694303496B74d56895902a009943",
    "SynFieldIoT",
    0,
    "",

]

let entity = [
    "0x7c8c0582d21a968b9aa25d45e0e719f1fe93aa4458f5d5939d507b861e308328",
    "Integrated Farm 1",
    platform[0],
    0,
    "{\"location\": \"Kiato, Greece\", \"establishmentDate\": \"2018-05-02\", \"productType\": \"Grapes\"}"
]

let actor1 = [
    "ef1b7932-52a3-4977-a12a-6fa54c365e21",
    platform[0],
    0,
    ""
]

contract('FoodChain', accounts => {
    let foodChainContract;
    let owner = accounts[0];

    it("should allow the registration of a new IoT platform", async () => {
        let tx = await foodChainContract.registerPlatform(...platform, {from: owner})

        truffleAssert.eventEmitted(tx, 'LogPlatformRegistered', (ev) => {
            return ev.id = platform[0]
        })
    })

    it("should allow the registration of a new IoT Entity", async () => {
        await foodChainContract.registerPlatform(...platform, {from: owner})
        let tx = await foodChainContract.registerEntity(...entity, {from: owner})

        truffleAssert.eventEmitted(tx, 'LogEntityRegistered', (ev) => {
            return ev.id = entity[0]
        })
    })

    it("should allow the registration of a new IoT actor", async () => {
        await foodChainContract.registerPlatform(...platform, {from: owner})
        let tx = await foodChainContract.registerActor(...actor1, {from: owner})

        truffleAssert.eventEmitted(tx, 'LogActorRegistered', (ev) => {
            return ev.id = actor1[0]
        })
    })


    beforeEach(async () => {
        foodChainContract = await FoodChain.new({from: owner})
    })
})