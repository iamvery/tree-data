Tree = Struct.new(:data) do
  def parse
    def build_intermediate_node(parent, level, sequence)
        # Intermediate node tracks parent and level directly in the node.
        # We'll strip out this book-keeping data later.
        {parent: parent, level: level, sequence: sequence, children: []}
    end

    root = build_intermediate_node(nil, 0, :root)
    current = root
    data.each do |item|
        item_level = item[:level]
        while current[:level] >= item_level do
            current = current[:parent]
        end
        item_node = build_intermediate_node(current, item_level, item[:sequence])
        current[:children] << item_node
        current = item_node
    end

    # Here's where we strip out the book-keeping data and rename
    # :children to :nodes.
    tree = project_final_tree(root)

    # The expected return value is actually a forest (list of trees),
    # not a tree in itself. We get that by decapitating the tree -
    # grab the children of the root, and pitch out the root node.
    tree[:nodes]
  end

  def project_final_tree(tree)
    # Note that this is currently recursive, so it might overflow the stack.
    # It could be transformed to a while loop and the book-keeping data
    # moved from the stack to an explicit data structure to avoid that.
    { sequence: tree[:sequence], nodes: tree[:children].map do |tree|
        project_final_tree(tree)
      end}
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
