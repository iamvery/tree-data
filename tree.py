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
    curr = None
    working_list = None

    def __init__(self, node_list):
        self.working_list = list(node_list)

    def chomp(self):
        if not self.working_list: 
            self.curr = None
        else:
            self.curr = self.working_list[0]
            del self.working_list[0]

    def parse_tree(self):
        self.chomp()
        toplevel_nodes = []
        initial_level = -sys.maxint - 1
            
        self.parse(initial_level, toplevel_nodes)

        return toplevel_nodes

    def parse(self, parent_level, parent_nodes):
        while self.curr:
            curr_level, first_data = self.curr

            if curr_level <= parent_level:
                # means we need to pop the stack.
                return

            first_nodes = []
            new_node = (first_data, first_nodes)
            parent_nodes.append(new_node)

            # what next?
            self.chomp()
            if not self.curr: 
                # nothing left to do
                return
            next_level, next_data = self.curr

            if next_level > curr_level:
                # curr has children, so parse them
                self.parse(curr_level, first_nodes)
            elif next_level == curr_level:
                # curr has no children, more nodes at this level
                continue
            elif next_level < curr_level:
                # done with this level, so return
                return

for tree in test_trees:
    print tree
    parser = TreeParser(tree)
    print parser.parse_tree()
