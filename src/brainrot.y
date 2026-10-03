%{
#include <stdio.h>
#include <stdlib.h>
#include <deque>
#include <memory>
#include <vector>

extern "C" int yywrap();

struct Node
{
    char op;
    std::vector<Node*> body;
    explicit Node(char op_) : op(op_) {}
};

typedef std::vector<Node*> NodeList;

static std::vector<std::unique_ptr<Node> > pool;
static NodeList* root = NULL;
static int errors = 0;

static Node* make_node(char op)
{
    std::unique_ptr<Node> node(new Node(op));
    Node* raw = node.get();
    pool.push_back(std::move(node));
    return raw;
}

static Node* as_node(void* value)
{
    return static_cast<Node*>(value);
}

static NodeList* as_list(void* value)
{
    return static_cast<NodeList*>(value);
}

#include "brainrot.lexer.c"

static std::deque<unsigned char> tape(1, 0);
static int ptr = 0;

static void move_ptr(int delta)
{
    if (delta > 0)
    {
        ++ptr;
        if (ptr == static_cast<int>(tape.size()))
            tape.push_back(0);
    }
    else if (delta < 0)
    {
        if (ptr == 0)
            tape.push_front(0);
        else
            --ptr;
    }
}

static void run_list(const NodeList& list);

static void run_node(const Node* node)
{
    switch (node->op)
    {
        case '+':
            tape[ptr]++;
            break;
        case '-':
            tape[ptr]--;
            break;
        case '>':
            move_ptr(1);
            break;
        case '<':
            move_ptr(-1);
            break;
        case '.':
            putchar(tape[ptr]);
            break;
        case ',':
        {
            int ch = getchar();
            if (ch != EOF)
                tape[ptr] = static_cast<unsigned char>(ch);
            break;
        }
        case '[':
            while (tape[ptr] != 0)
                run_list(node->body);
            break;
        default:
            break;
    }
}

static void run_list(const NodeList& list)
{
    for (NodeList::const_iterator it = list.begin(); it != list.end(); ++it)
        run_node(*it);
}

void yyerror(const char* error)
{
    errors++;
    fprintf(stderr,
            "Parse error %d: %s at line %d, in statement: %s \n",
            errors,
            error,
            line,
            yytext);
    exit(1);
}

extern "C" int yywrap()
{
    return 1;
}
%}

%union {
    void* node;
    void* list;
}

%token INCVAL DECVAL INCPTR DECPTR INPUT OUTPUT WHILESTART WHILEEND
%type <list> program
%type <node> command
%start unit

%%
unit
    : program
        {
            root = as_list($1);
        }
    ;

program
    : /* empty */
        {
            $$ = new NodeList();
        }
    | program command
        {
            as_list($1)->push_back(as_node($2));
            $$ = $1;
        }
    ;

command
    : INCVAL    { $$ = make_node('+'); }
    | DECVAL    { $$ = make_node('-'); }
    | INCPTR    { $$ = make_node('>'); }
    | DECPTR    { $$ = make_node('<'); }
    | INPUT     { $$ = make_node(','); }
    | OUTPUT    { $$ = make_node('.'); }
    | WHILESTART program WHILEEND
        {
            Node* loop = make_node('[');
            NodeList* body = as_list($2);
            loop->body = *body;
            delete body;
            $$ = loop;
        }
    ;
%%

int main(int argc, char *argv[])
{
    if (argc == 2)
    {
        yyin = fopen(argv[1], "r");
        if (yyin == NULL)
        {
            fprintf(stderr, "Error opening file (%s).\n", argv[1]);
            return 1;
        }
    }
    else if (argc == 1)
    {
        yyin = stdin;
    }
    else
    {
        fprintf(stderr, "Too many arguments (%d).\n", argc - 1);
        return 1;
    }

    if (yyparse() != 0)
        return 1;

    if (root != NULL)
    {
        run_list(*root);
        delete root;
        root = NULL;
    }

    fflush(stdout);

    if (yyin != NULL && yyin != stdin)
        fclose(yyin);

    return 0;
}
