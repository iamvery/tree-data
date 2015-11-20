require 'rspec'

class Tree
  attr_reader :data
  def initialize(data)
    @data = data
    @look_ahead = nil
  end

  def parse_node(parent, node)
    node[:nodes] = [] unless node.key?(:nodes)
    parent[:nodes] << node unless parent[:nodes].include?(node)
    return parent if @look_ahead.nil?
    if (node[:level] == @look_ahead[:level])
      next_node = @look_ahead
      @look_ahead = @data.pop
      parse_node(parent, next_node)
    elsif node[:level] < @look_ahead[:level]
      next_node = @look_ahead
      @look_ahead = @data.pop
      parse_node(node, next_node)
      parse_node(parent, node)
    elsif node[:level] > @look_ahead[:level]
      return
    end
    parent[:nodes]
  end

  def parse
    @data = @data.reverse
    node = @data.pop
    @look_ahead = @data.pop
    parse_node({ level: 0, sequence: 0, nodes: [] }, node).each do|x|
      delete_level(x)
    end
  end

  def delete_level(node)
    node.delete(:level)
    node[:nodes].each do |x|
      delete_level(x)
    end
  end
  RSpec.describe Tree do
    describe '#parse' do
      it 'parses single-level trees' do
        data = [
          { level: 1, sequence: 1 },
          { level: 1, sequence: 2 }
        ]

        tree = described_class.new(data)

        expect(tree.parse).to eq([
          { sequence: 1, nodes: [] },
          { sequence: 2, nodes: [] }
        ])
      end

      it 'parses complex tree data' do
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
          { level: 2, sequence: 10 }
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
                  { sequence: 5, nodes: [] }
                ]
              }
            ]
          },
          {
            sequence: 6,
            nodes: [
              { sequence: 7, nodes: [] },
              {
                sequence: 8,
                nodes: [
                  { sequence: 9, nodes: [] }
                ]
              },
              { sequence: 10, nodes: [] }
            ]
          }
        ])
      end
    end
  end
end
