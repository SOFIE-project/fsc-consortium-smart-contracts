const truffleAssert = require('truffle-assertions')
const FoodChainAdapter = artifacts.require('FoodChainAdapter')

let payload = [
    1,
    "E280113020002064DBD800AB",
    "0x413b4325b54cee71dc7c1ecee1435c8ac632e107e923cb7221e0aa80922da945",
    [
        "0xe882f7ff255814141995a7647c8f2c1d5cbab36504c39eed184fd3edd5544d5f", 
        "0x90400a77f2ac838227d9249e6f7cc159af604af1ce481c99d81270af6cac9e79", 
        "0xda4b6f3764ec69ee8a937a63ade3fa4a8294331ae1b79abff322195b17e7ff0a", 
        "0x3f9ae1d3b2333ce01823ed779a6a2119f189af8591ef139b41c14726995fcbcc", 
        "0x143d097ceed41b8af42d7186469f402064bfba235a12088afafbfccd6ce40e8b", 
        "0xf598e1cc720782f21da4bfe074eba26a99b22b0a9842dcddd197f7822ed72998", 
        "0xfd45b31dfc75074451434d8fc63c9164d3f692788df3edb49c10e94cb64b6384", 
        "0x63ad2fb28345e0fffa22c3eef858d4fb1d2b30c04aca5ee4b16a72f85aea7700"
    ]

]

contract('FoodChainAdapter', accounts => {
    let foodChainAdapterContract;
    let owner = accounts[0];

    it("should allow the registration of an interledger payload", async () => {
        let tx = await foodChainAdapterContract.registerInterledgerEvent(...payload, {from: owner})

        truffleAssert.eventEmitted(tx, 'InterledgerEventSending', (ev) => {
            return ev.id = payload[0]
        })
    })

    it("should allow interledger to commit a payload", async () => {
        await foodChainAdapterContract.registerInterledgerEvent(...payload, {from: owner})
        let tx = await foodChainAdapterContract.interledgerCommit(payload[0], {from: accounts[1]})

        truffleAssert.eventEmitted(tx, 'InterledgerEventCommited', (ev) => {
            return ev.id = payload[0]
        })
    })

    it("should allow interledger to abort a payload", async () => {
        await foodChainAdapterContract.registerInterledgerEvent(...payload, {from: owner})
        let tx = await foodChainAdapterContract.interledgerAbort(payload[0], 0, {from: accounts[1]})

        truffleAssert.eventEmitted(tx, 'InterledgerEventAborted', (ev) => {
            return ev.id = payload[0]
        })
    })

    beforeEach(async () => {
        foodChainAdapterContract = await FoodChainAdapter.new({from: owner})
    })
})