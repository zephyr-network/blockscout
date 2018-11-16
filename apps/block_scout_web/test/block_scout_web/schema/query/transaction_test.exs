defmodule BlockScoutWeb.Schema.Query.TransactionTest do
  use BlockScoutWeb.ConnCase

  describe "transaction field" do
    test "with valid argument 'hash', returns all expected fields", %{conn: conn} do
      block = insert(:block)

      transaction =
        :transaction
        |> insert()
        |> with_block(block, status: :ok)

      query = """
      query ($hash: FullHash!) {
        transaction(hash: $hash) {
          hash
          block_number
          cumulative_gas_used
          error
          gas
          gas_price
          gas_used
          index
          input
          nonce
          r
          s
          status
          v
          value
          from_address_hash
          to_address_hash
          created_contract_address_hash
        }
      }
      """

      variables = %{"hash" => to_string(transaction.hash)}

      conn = get(conn, "/graphql", query: query, variables: variables)

      assert json_response(conn, 200) == %{
               "data" => %{
                 "transaction" => %{
                   "hash" => to_string(transaction.hash),
                   "block_number" => transaction.block_number,
                   "cumulative_gas_used" => to_string(transaction.cumulative_gas_used),
                   "error" => transaction.error,
                   "gas" => to_string(transaction.gas),
                   "gas_price" => to_string(transaction.gas_price.value),
                   "gas_used" => to_string(transaction.gas_used),
                   "index" => transaction.index,
                   "input" => to_string(transaction.input),
                   "nonce" => to_string(transaction.nonce),
                   "r" => to_string(transaction.r),
                   "s" => to_string(transaction.s),
                   "status" => transaction.status |> to_string() |> String.upcase(),
                   "v" => transaction.v,
                   "value" => to_string(transaction.value.value),
                   "from_address_hash" => to_string(transaction.from_address_hash),
                   "to_address_hash" => to_string(transaction.to_address_hash),
                   "created_contract_address_hash" => nil
                 }
               }
             }
    end

    test "errors for non-existent transaction hash", %{conn: conn} do
      transaction = build(:transaction)

      query = """
      query ($hash: FullHash!) {
        transaction(hash: $hash) {
          status
        }
      }
      """

      variables = %{"hash" => to_string(transaction.hash)}

      conn = get(conn, "/graphql", query: query, variables: variables)

      assert %{"errors" => [error]} = json_response(conn, 200)
      assert error["message"] == "Transaction not found."
    end

    test "errors if argument 'hash' is missing", %{conn: conn} do
      query = """
      {
        transaction {
          status
        }
      }
      """

      conn = get(conn, "/graphql", query: query)

      assert %{"errors" => [error]} = json_response(conn, 200)
      assert error["message"] == ~s(In argument "hash": Expected type "FullHash!", found null.)
    end

    test "errors if argument 'hash' is not a 'FullHash'", %{conn: conn} do
      query = """
      query ($hash: FullHash!) {
        transaction(hash: $hash) {
          status
        }
      }
      """

      variables = %{"hash" => "0x000"}

      conn = get(conn, "/graphql", query: query, variables: variables)

      assert %{"errors" => [error]} = json_response(conn, 200)
      assert error["message"] =~ ~s(Argument "hash" has invalid value)
    end
  end

  describe "transaction internal_transactions field" do
    test "returns all expected internal_transaction fields", %{conn: conn} do
      address = insert(:address)
      contract_address = insert(:contract_address)

      block = insert(:block)

      transaction =
        :transaction
        |> insert(from_address: address)
        |> with_contract_creation(contract_address)
        |> with_block(block)

      internal_transaction_attributes = %{
        transaction: transaction,
        index: 0,
        from_address: address,
        call_type: :call
      }

      internal_transaction =
        :internal_transaction_create
        |> insert(internal_transaction_attributes)
        |> with_contract_creation(contract_address)

      query = """
      query ($hash: FullHash!, $first: Int!) {
        transaction(hash: $hash) {
          internal_transactions(first: $first) {
            edges {
              node {
                call_type
                created_contract_code
                error
                gas
                gas_used
                index
                init
                input
                output
                trace_address
                type
                value
                block_number
                transaction_index
                created_contract_address_hash
                from_address_hash
                to_address_hash
                transaction_hash
              }
            }
          }
        }
      }
      """

      variables = %{
        "hash" => to_string(transaction.hash),
        "first" => 1
      }

      conn = get(conn, "/graphql", query: query, variables: variables)

      assert json_response(conn, 200) == %{
               "data" => %{
                 "transaction" => %{
                   "internal_transactions" => %{
                     "edges" => [
                       %{
                         "node" => %{
                           "call_type" => internal_transaction.call_type |> to_string() |> String.upcase(),
                           "created_contract_code" => to_string(internal_transaction.created_contract_code),
                           "error" => internal_transaction.error,
                           "gas" => to_string(internal_transaction.gas),
                           "gas_used" => to_string(internal_transaction.gas_used),
                           "index" => internal_transaction.index,
                           "init" => to_string(internal_transaction.init),
                           "input" => nil,
                           "output" => nil,
                           "trace_address" => Jason.encode!(internal_transaction.trace_address),
                           "type" => internal_transaction.type |> to_string() |> String.upcase(),
                           "value" => to_string(internal_transaction.value.value),
                           "block_number" => internal_transaction.block_number,
                           "transaction_index" => internal_transaction.transaction_index,
                           "created_contract_address_hash" => to_string(internal_transaction.created_contract_address_hash),
                           "from_address_hash" => to_string(internal_transaction.from_address_hash),
                           "to_address_hash" => nil,
                           "transaction_hash" => to_string(internal_transaction.transaction_hash),
                         }
                       }
                     ]
                   }
                 }
               }
             }
    end

    test "with transaction with zero internal transactions"
    test "internal transactions are ordered by ascending index"
    test "complexity correlates to first or last argument"
    test "with 'last' and 'count' arguments"
    test "pagination support with 'first' and 'after' arguments"
  end
end
