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
def parse_tree(tree_list):
    working_list = list(tree_list)
    window = [None]

    toplevel_nodes = []

    def chomp():
        if not working_list: 
            return None, None
        
        first = working_list[0]
        del working_list[0]
        second = working_list[0] if working_list else None
        window[0] = first, second

    def parse(level, curr_nodes):
        first, second = window[0]

        while first:
            first_level, first_data = first

            if first_level <= level:
                # means we need to pop the stack.
                return

            first_nodes = []
            new_node = (first_data, first_nodes)
            curr_nodes.append(new_node)

            # what next?
            if not second: 
                return
            second_level, second_data = second

            if second_level > first_level:
                # parse first's nodes
                chomp()
                parse(first_level, first_nodes)
                first, second = window[0]
            elif second_level == first_level:
                # keep going at this level
                chomp()
                first, second = window[0]
                continue
            elif second_level < first_level:
                chomp()
                first, second = window[0]
                return


    chomp()
    initial_level = -sys.maxint - 1

    parse(initial_level, toplevel_nodes)

    return toplevel_nodes

for tree in test_trees:
    print tree
    print parse_tree(tree)
