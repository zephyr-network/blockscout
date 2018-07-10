defmodule Indexer.SequenceTest do
  use ExUnit.Case

  alias Indexer.Sequence

  describe "pop/1" do
    # first pops the head of the list and not of the queue
    # and pops the head of the queue at the end
    test "always pops the head the queue first in :infinite mode" do
      initial_ranges = [5..7, 3..5, 1..3]

      {:ok, pid} = Sequence.start_link(initial_ranges, 4, 1)

      sequence_state = state(pid)
      assert sequence_state.queue == {[1..3], [5..7, 3..5]}

      range = Sequence.pop(pid)
      sequence_state = state(pid)

      assert range == 5..7
      assert sequence_state.queue == {[1..3], [3..5]}

      range = Sequence.pop(pid)
      sequence_state = state(pid)

      assert range == 3..5
      assert sequence_state.queue == {[], [1..3]}

      range = Sequence.pop(pid)
      sequence_state = state(pid)

      assert range == 1..3
      assert sequence_state.queue == {[], []}
    end

    # first pops the head of the list and not of the queue
    # and pops the head of the queue at the end
    test "always pops the head the queue first in :finite mode" do
      initial_ranges = [5..7, 3..5, 1..3]
      {:ok, pid} = Sequence.start_link(initial_ranges, 4, 1)
      Sequence.cap(pid)

      sequence_state = state(pid)

      assert sequence_state.queue == {[1..3], [5..7, 3..5]}
      assert sequence_state.mode == :finite

      sequence_state = state(pid)
      assert sequence_state.queue == {[1..3], [5..7, 3..5]}

      range = Sequence.pop(pid)
      sequence_state = state(pid)

      assert range == 5..7
      assert sequence_state.queue == {[1..3], [3..5]}

      range = Sequence.pop(pid)
      sequence_state = state(pid)

      assert range == 3..5
      assert sequence_state.queue == {[], [1..3]}

      range = Sequence.pop(pid)
      sequence_state = state(pid)

      assert range == 1..3
      assert sequence_state.queue == {[], []}
    end

    test "an empty queue in :infinite sum of current and step is positive" do
      # defines a new current (current + step) -> 7
      # removes 1 to the current to define the "last" -> 6
      # returns a new range that cosnsists in current..last  -> 4..6
      initial_ranges = []
      {:ok, pid} = Sequence.start_link(initial_ranges, 4, 3)

      sequence_state = state(pid)

      assert sequence_state.queue == {[], []}
      assert sequence_state.mode == :infinite

      range = Sequence.pop(pid)

      assert range == 4..6
    end

    test "an empty queue in :infinite sum of current and step is positive even when step is negative" do
      # defines a new current (current + step) -> 1
      # adds 1 to the current to define the "last" -> 2
      # returns a new range that cosnsists in current..last  -> 4..2
      initial_ranges = []
      {:ok, pid} = Sequence.start_link(initial_ranges, 4, -3)

      sequence_state = state(pid)

      assert sequence_state.queue == {[], []}
      assert sequence_state.mode == :infinite

      range = Sequence.pop(pid)

      sequence_state = state(pid)

      assert sequence_state.queue == {[], []}
      assert sequence_state.mode == :infinite
      assert range == 4..2
    end

    test "an empty queue in :infinite sum of current and step is negative" do
      # returns a range from the current to 0
      # turns mode to finite
      initial_ranges = []
      {:ok, pid} = Sequence.start_link(initial_ranges, 4, -5)

      sequence_state = state(pid)

      assert sequence_state.queue == {[], []}
      assert sequence_state.mode == :infinite

      range = Sequence.pop(pid)

      sequence_state = state(pid)

      assert range == 4..0
      assert sequence_state.current == 0
      assert sequence_state.mode == :finite
      assert sequence_state.queue == {[], []}
    end

    test "an empty queue in :finite mode returns :halt" do
      initial_ranges = []
      {:ok, pid} = Sequence.start_link(initial_ranges, 4, -5)
      Sequence.cap(pid)
      sequence_state = state(pid)

      assert sequence_state.queue == {[], []}
      assert sequence_state.mode == :finite

      response = Sequence.pop(pid)

      assert response == :halt
    end
  end

  describe "start_link/3" do
    test "state definiton" do
      initial_ranges = [1..4]
      range_start = 5
      step = 1

      {:ok, pid} = Sequence.start_link(initial_ranges, range_start, step)

      sequece_state = state(pid)

      assert sequece_state.current == range_start
      assert sequece_state.step == step
      assert sequece_state.mode == :infinite
      assert sequece_state.queue == {initial_ranges, []}
    end

    test "always define the mode as :infinite" do
      {:ok, pid} = Sequence.start_link([1..4], 5, 1)

      %Sequence{mode: mode} = state(pid)

      assert mode == :infinite
    end

    test "the last element in initial_ranges get to be the first one of the queue" do
      initial_ranges = [5..7, 3..5, 1..3]

      {:ok, pid} = Sequence.start_link(initial_ranges, 5, 1)

      %Sequence{queue: queue} = state(pid)

      assert queue == {[1..3], [5..7, 3..5]}
    end
  end

  describe "inject_range/2" do
    test "adds a new range at the head of the queue" do
      {:ok, pid} = Sequence.start_link([1..2], 5, 1)

      response = Sequence.inject_range(pid, 3..4)
      sequece_state = state(pid)

      assert response == :ok
      assert sequece_state.queue == {[3..4], [1..2]}
    end
  end

  describe "cap/1" do
    test "changes mode to :finite" do
      {:ok, pid} = Sequence.start_link([1..2], 5, 1)

      assert :ok = Sequence.cap(pid)
      assert state(pid).mode == :finite
    end
  end

  defp state(sequencer) do
    Agent.get(sequencer, & &1)
  end
end
