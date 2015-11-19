Tree = Struct.new(:data) do
  def parse
    #
  end
end

RSpec.describe Tree do
  it "parses" do
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
    expect(tree.parse).to eq(
      [
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
            { sequence: 8, nodes: [] }
          ],
        }
      ]
    )
  end
end
