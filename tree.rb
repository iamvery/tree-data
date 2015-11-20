

Tree = Struct.new(:data) do

  def parse
    build_tree[:nodes]
  end

  def build_tree(tree = { nodes: [] }, list = data)
    node, *tail = list
    add_node(tree, node)
    build_tree(tree, tail) if tail.length > 0
    return tree
  end

  def add_node(tree, node)
    parent_level = node[:level] - 1
    sub_tree = rightmost_child_at_level(tree, parent_level)
    sub_tree[:nodes] << { sequence: node[:sequence], nodes: [] }
  end

  def rightmost_child_at_level(sub_tree, traversals_remaining)
    traversals_remaining.times.reduce(sub_tree) { |sub_tree| sub_tree[:nodes].last }
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
