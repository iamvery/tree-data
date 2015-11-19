import sys

test_trees = [
        [
        (1, "one"),
        (1, "two"),
        (2, "three"),
        (2, "four"),
        (1, "five"),
        (2, "six"),
        (3, "seven"),
        (1, "eight"),
        ],

    [
        (1, 1 ),
        (2, 2 ),
        (3, 3 ),
        (3, 4 ),
        (2, 5 ),
        (1, 6 ),
        (2, 7 ),
        (2, 8 ),
    ]
    ]

class TreeParser:
    first = None
    second = None
    working_list = None

    def __init__(self, node_list):
        self.working_list = list(node_list)

    def chomp(self):
        if not self.working_list: 
            first = second = None
        
        self.first = self.working_list[0]
        del self.working_list[0]
        self.second = self.working_list[0] if self.working_list else None

    def parse_tree(self):
        self.chomp()
        toplevel_nodes = []
        initial_level = -sys.maxint - 1
            
        self.parse(initial_level, toplevel_nodes)

        return toplevel_nodes

    def parse(self, level, curr_nodes):

        while self.first:
            first_level, first_data = self.first

            if first_level <= level:
                # means we need to pop the stack.
                return

            first_nodes = []
            new_node = (first_data, first_nodes)
            curr_nodes.append(new_node)

            # what next?
            if not self.second: 
                return
            second_level, second_data = self.second

            if second_level > first_level:
                # first has children, so parse them
                self.chomp()
                self.parse(first_level, first_nodes)
            elif second_level == first_level:
                # first has no children, more nodes at this level
                self.chomp()
                continue
            elif second_level < first_level:
                # done with this level, so return
                self.chomp()
                return

for tree in test_trees:
    print tree
    parser = TreeParser(tree)
    print parser.parse_tree()
