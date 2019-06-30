const Contract = artifacts.require("Repository");

contract("Repository", function(accounts) {
  const OWNER = accounts[0];
  const ALICE = accounts[1];
  const BOB = accounts[2];

  let contractInstance;

  beforeEach(async function () {
    contractInstance = await Contract.new();
  });

  describe("Repository tests", () => {
    it("should add stock", async function () {
      await contractInstance.add(100, "0x01");
      const actual = await contractInstance._inventory(0);
      assert.equal(Number(actual[0]), 100, "Stock not correct");
    });

    it("should sum total stock", async function () {
      await contractInstance.add(200, "0x02");
      const actual = await contractInstance.totalStock();
      assert.equal(Number(actual), 200, "Total stock not correct");
    });
  });
});