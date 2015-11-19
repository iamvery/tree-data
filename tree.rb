Tree = Struct.new(:data) do
  def make_node(ent)
    { sequence: ent[:sequence], nodes: [] }
  end

  # Walks back up a prepared stack, forming the tree at each level.
  def collapse(stack, level)
    # Iterate the difference between the last tree level and this level.
    (stack.length - level).times do |idx|
      # Pop a leaf at a time.
      leaf = stack.pop
      # Append the leafs to the parent node.
      stack[-1][-1][:nodes] = leaf
    end
    stack
  end

  def parse
    stack = []
    data.each do |ent|
      node = make_node(ent)
      level = ent[:level]

      # Collapse all leafs below the current level
      collapse(stack, level)    if stack.length > level

      # Add an empty level
      stack     << []           if stack.length < level

      # stack.length must equal level at this point, so just add our node.
      stack[-1] << node
    end

    # Final collapse, should result in [[:tree]]
    return collapse(stack, 1).pop
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
