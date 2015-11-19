Tree = Struct.new(:data) do
  def parse(nodes = data)
    return [] if nodes.empty?

    parent_node = nodes.first
    parent_nodes = nodes.select { |node| node[:level] == parent_node[:level] }

    node_families = parent_nodes.map do |parent_node|
      parent_node_index = nodes.index(parent_node)
      remaining_nodes = nodes[(parent_node_index + 1)..-1]
      descendant_nodes = remaining_nodes.take_while { |node| node[:level] > parent_node[:level] }

      [parent_node, descendant_nodes]
    end

    node_families.map do |parent_node, descendant_nodes|
      { sequence: parent_node[:sequence], nodes: parse(descendant_nodes) }
    end
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
        { level: 3, sequence: 3 },
        { level: 3, sequence: 4 },
        { level: 2, sequence: 5 },
        { level: 1, sequence: 6 },
        { level: 2, sequence: 7 },
        { level: 2, sequence: 8 },
      ]

      tree = described_class.new(data)

      expect(tree.parse).to eq([
        {
          sequence: 1,
          nodes: [
            {
              sequence: 2,
              nodes: [
                { sequence: 3, nodes: [] },
                { sequence: 4, nodes: [] },
              ],
            },
            { sequence: 5, nodes: [] },
          ],
        },
        {
          sequence: 6,
          nodes: [
            { sequence: 7, nodes: [] },
            { sequence: 8, nodes: [] },
          ],
        }
      ])
    end
  end
end
