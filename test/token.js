//Unit tests for ggctoken.sol
//No longer valid
const Token = artifacts.require("GGCToken");

contract.skip("GGCToken", function(accounts) {
  const OWNER = accounts[0];
  const ALICE = accounts[1];
  const BOB = accounts[2];

  let tokenInstance;

  beforeEach(async function () {
    tokenInstance = await Token.new();
  });

  describe("ERC20 tests", () => {
    it("should test ERC20 public properties", async function () {
      const name = await tokenInstance.name();
      assert.equal(name, "GGC Token", "Name should be GGC Token");

      const symbol = await tokenInstance.symbol();
      assert.equal(symbol, "GGC", "Symbol should be GGC");
    });

    it("total supply should be 0", async function () {
      const actual = await tokenInstance.totalSupply();
      assert.equal(actual.valueOf(), 0, "Total supply should be 0");
    });

    it("owner balance should be 0", async function () {
      const actual = await tokenInstance.balanceOf(OWNER);
      assert.equal(actual.valueOf(), 0, "Balance should be 0");
    });
  });

  describe("Owner / Ownable tests", () => {
    it("should set owner to account 0", async function () {
      const owner = await tokenInstance.owner();
      assert.equal(owner, accounts[0], "Owner should be account 0");
    });

    it("Owner should be able to change owner", async function () {
      const owner = await tokenInstance.owner();
      assert.equal(owner, accounts[0], "Owner should be account 0");

      await tokenInstance.changeOwner(accounts[1]);
      const new_owner = await tokenInstance.owner();

      assert.equal(new_owner, accounts[1], "Owner should be account 1");
    });
  });

  describe("Balance", () => {
    it("should have balance of", async function () {
      await tokenInstance.mint(100);
      const totalSupply = await tokenInstance.totalSupply();
      assert.equal(100, Number(totalSupply), "Total supply should be 100");

      await tokenInstance.transfer(ALICE, 50);
      const aliceBalance = await tokenInstance.balanceOf(ALICE);
      assert.equal(50, Number(aliceBalance), "Balance should be 50");

      const ownerBalance = await tokenInstance.balanceOf(OWNER);
      assert.equal(50, Number(ownerBalance), "Balance should be 50");

      await tokenInstance.transferFrom(ALICE, BOB, 25, { from: BOB });
      const bobBalance = await tokenInstance.balanceOf(BOB);

      assert.equal(0, Number(bobBalance), "Balance should still be zero");
    });
  });

  describe("Mint and burn tests", () => {
    it("owner should be able to mint tokens", async function () {
      await tokenInstance.mint(100);
      const totalSupply = await tokenInstance.totalSupply();
      assert.equal(100, Number(totalSupply), "Total supply should be 100");

      await tokenInstance.transfer(ALICE, 50);
      const aliceBalance = await tokenInstance.balanceOf(ALICE);
      assert.equal(50, Number(aliceBalance), "Balance should be 50");

      const ownerBalance = await tokenInstance.balanceOf(OWNER);
      assert.equal(50, Number(ownerBalance), "Balance should be 50");

      await tokenInstance.transferFrom(ALICE, BOB, 25, { from: BOB });
      const bobBalance = await tokenInstance.balanceOf(BOB);

      assert.equal(0, Number(bobBalance), "Balance should still be zero");
    });
  });
});