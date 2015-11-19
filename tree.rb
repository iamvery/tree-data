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
    # updated during the tree walk
    final_tree = nil

    # worklist - tracks the state we need to rewrite the tree
    frontier = [{converted_parent: nil, children: [tree]}]
    while frontier.size > 0
        # walk the tree breadth-first (.pop would be depth-first)
        item = frontier.shift
        parent = item[:converted_parent]
        children = item[:children]

        children.each do |child|
            # rewrite the child to the final-tree form
            converted = { sequence: child[:sequence], nodes: [] }

            # add the child's own children to the frontier,
            # so we process them eventually
            frontier << {
                converted_parent: converted,
                children: child[:children]
                }

            if parent then
                # add the converted node to the final tree we're in
                # the middle of building
                parent[:nodes] << converted
            else
                # no parent, so it must be the root
                # save a reference so we can return it from the method
                final_tree = converted
            end
        end
    end
    final_tree
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
