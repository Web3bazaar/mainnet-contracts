const Web3BazaarBatch = artifacts.require("Web3BazaarEscrow");


contract('Web3Bazzar ', (accounts) => {

    it('should read empty open trades', async () => {
        const BazaarEscrowInstance = await Web3BazaarBatch.deployed();
        const openTrades = await BazaarEscrowInstance.tradePerUser.call(accounts[0]);
        console.log('openTrades : ', openTrades );
        assert.equal(openTrades.length, 0 , "Open trades for that wallet should be empty");
    });

      // it('should read empty open trades', async () => {
      //   const BazaarEscrowInstance = await Web3BazaarBatch.deployed();
      //   const openTrades = await BazaarEscrowInstance.tradePerUser.call(accounts[0]);
      //   //console.log('openTrades : ', openTrades );
      //   assert.equal(openTrades, [], "Open trades for that wallet should be empty");
      // });


});