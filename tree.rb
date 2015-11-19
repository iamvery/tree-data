Tree = Struct.new(:data) do
  def parse
    build_tree[:nodes]
  end

  def build_tree(tree = { nodes: [] }, list = data)
    element, *tail = list
    add_node(tree, element)
    build_tree(tree, tail) if tail.length > 0
    tree
  end

  def add_node(tree, element)
    parent = find_location(element[:level] - 1, tree)
    parent[:nodes] << { sequence: element[:sequence], nodes: [] }
  end

  def find_location(traversals_remaining, location)
    return location if traversals_remaining == 0
    find_location(traversals_remaining - 1, location[:nodes].last)
  end
end

RSpec.describe Tree do
  describe "#parse" do
    it "parses single-level trees" do
      data = [
        { level: 1, sequence: 1 },
        { level: 1, sequence: 2 },
      ]

      tree = described_class.new(data)

      expect(tree.parse).to eq([
        { sequence: 1, nodes: [] },
        { sequence: 2, nodes: [] },
      ])
    end

    it "parses complex tree data" do
      data = [
        { level: 1, sequence: 1 },
        { level: 2, sequence: 2 },
        { level: 2, sequence: 3 },
        { level: 3, sequence: 4 },
        { level: 3, sequence: 5 },
        { level: 1, sequence: 6 },
        { level: 2, sequence: 7 },
        { level: 2, sequence: 8 },
        { level: 3, sequence: 9 },
        { level: 2, sequence: 10 },
      ]

      tree = described_class.new(data)

      expect(tree.parse).to eq([
        {
          sequence: 1,
          nodes: [
            { sequence: 2, nodes: [] },
            {
              sequence: 3,
              nodes: [
                { sequence: 4, nodes: [] },
                { sequence: 5, nodes: [] },
              ],
            },
          ],
        },
        {
          sequence: 6,
          nodes: [
            { sequence: 7, nodes: [] },
            {
              sequence: 8,
              nodes: [
                { sequence: 9, nodes: [] },
              ],
            },
            { sequence: 10, nodes: [] },
          ],
        }
      ])
    end
  end
end
