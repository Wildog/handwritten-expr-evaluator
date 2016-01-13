#include    "stdio.h"
#include    "stdlib.h"
#include    "engine.h"
#define     STACK_INIT_SIZE 50
#define     STACK_INCREMENT 10
#define     ERROR           -1
#define     OVERFLOW        -2
#define     NUMTYPE         1
#define     CHARTYPE        2

typedef struct {
    double  *base;
    double  *top;
    int     size;
} Stack;

int main() {
    void dataAnalyze(const mxArray *, char **);
    void compute(char **);
    
    Engine *ep;
    mxArray *result = NULL; // Matlab 返回的识别结果
    char *str = NULL;       // 识别结果分析后的字符串

    printf("加载 Matlab 引擎...\n");
    if (!(ep = engOpen(""))) {
        fprintf(stderr, "\n无法启动 Matlab!\n");
        return ERROR;
    }

    printf("从 Matlab 获取数据...\n");
    engEvalString(ep, "Array = getPicChar;");

    if ((result = engGetVariable(ep,"Array")) == NULL) {
        printf("无法获取结果!\n");
    } else {
        dataAnalyze(result, &str);
    }

    printf("%s\n", str);
    compute(&str);

    printf("按回车以结束.");
    fgetc(stdin);
    return 0;
}

/* 从 Matlab 获取识别结果, 分析并存储 */
void dataAnalyze(const mxArray *array_ptr, char **str) {
    double *pr; 
    int num, i, total_num_of_elements; 

    pr = mxGetPr(array_ptr);
    total_num_of_elements = mxGetNumberOfElements(array_ptr);
    *str = (char*)malloc((total_num_of_elements+1)*sizeof(char));

    for (i=0; i<total_num_of_elements; i++) {
        num = (int)*pr;
        switch (num) {
            case 1: (*str)[i] = '1'; break;
            case 2: (*str)[i] = '2'; break;
            case 3: (*str)[i] = '3'; break;
            case 4: (*str)[i] = '4'; break;
            case 5: (*str)[i] = '5'; break;
            case 6: (*str)[i] = '6'; break;
            case 7: (*str)[i] = '7'; break;
            case 8: (*str)[i] = '8'; break;
            case 9: (*str)[i] = '9'; break;
            case 10: (*str)[i] = '0'; break;
            case 11: (*str)[i] = '+'; break;
            case 12: (*str)[i] = '-'; break;
            case 13: (*str)[i] = '/'; break;
            case 14: (*str)[i] = '*'; break;
            case 15: (*str)[i] = '^'; break;
            case 16: (*str)[i] = '('; break;
            case 17: (*str)[i] = ')'; break;
            default: break;
        }
        pr++;
    } 
    (*str)[i] = '\0';
}

/* 从 str 获取运算数或运算符, 一次一个*/
int reached_num_end = 0;    //单个运算数获取完毕标记
int reached_end = 0;        //字符串获取完毕标记
int c;
int lasttype;
int getUnit(char **str) {
    int n;
    if (reached_num_end) {
        reached_num_end = 0;
        lasttype = CHARTYPE;
        if (c == '\0') reached_end = 1;
        return c;
    } 
    else {
        c = *(*str)++;
        n = 0;
        while (c <= '9' && c >= '0') {
            n = 10 * n + (c - '0');
            c = *(*str)++;
            reached_num_end = 1;
        }
        if (reached_num_end) {
            lasttype = NUMTYPE;
            return n;
        } else { 
            //如[...num))...], 读到第二个')'时, reached_num_end 为 0;
            lasttype = CHARTYPE;
            if (c == '\0') reached_end = 1;
            return c;
        }
    }
}

/* 比较运算符优先级 */
char precede(char a, char b) {
    int convert(char);
    /*                  |       运算符b (所遇运算符)    |   */
    /*                  | + | - | * | / | ^ | ( | ) |\0 |   // 运算符a (栈顶运算符) */
    char table[8][8] = {{'>','>','<','<','<','<','>','>'},  // +
                        {'>','>','<','<','<','<','>','>'},  // -    
                        {'>','>','>','>','<','<','>','>'},  // *    
                        {'>','>','>','>','<','<','>','>'},  // /    
                        {'<','<','<','<','<','<','>','>'},  // ^    
                        {'<','<','<','<','<','<','=','>'},  // (    
                        {'>','>','>','>','>','e','>','e'},  // )
                        {'<','<','<','<','<','<','e','='}}; // \n
    return table[convert(a)][convert(b)];
}

int convert(char x) {
    int result = 0;
    switch (x) {
        case '+'  : result = 0; break;
        case '-'  : result = 1; break;
        case '*'  : result = 2; break;
        case '/'  : result = 3; break;
        case '^'  : result = 4; break;
        case '('  : result = 5; break;
        case ')'  : result = 6; break;
        case '\0' : result = 7; break;
        default: 
            printf("非法运算符!\n");
            exit(ERROR);
            break;
    }
    return result;
}

/* 计算表达式并显示结果 */
void compute(char **str) {
    Stack   *initStack(void);
    double  operate(double, int, double);
    double  getTop(Stack *stack);
    double  pop(Stack *stack);
    void    push(Stack *stack, double element);
    char    precede(char a, char b);
    int     getUnit(char **str);
    Stack *oprtStack;
    Stack *oprnStack;
    oprnStack = initStack();
    oprtStack = initStack();
    int curr, theta;
    double a, b, result;
    reached_num_end = reached_end = 0; 
    curr = getUnit(str);
    printf("中间结果:\n");
    while (!reached_end) {
        if (lasttype == NUMTYPE) {
            push(oprnStack, curr);
            curr = getUnit(str);
        }
        else {
            if (oprtStack->top == oprtStack->base) {
                push(oprtStack, curr);
                curr = getUnit(str);
            } else {
                switch (precede(getTop(oprtStack), curr)) {
                    case '<' :
                        push(oprtStack, curr);
                        curr = getUnit(str);
                        break;
                    case '=' :
                        pop(oprtStack);
                        curr = getUnit(str);
                        break;
                    case '>' :
                        theta = pop(oprtStack);
                        b = pop(oprnStack);
                        a = pop(oprnStack);
                        result = operate(a, theta, b);
                        printf("--%g%c%g=%g--\n", a, theta, b, result);
                        push(oprnStack, result);
                        //curr 暂时不变, 暂停获取新运算符
                        break;
                    default :
                        printf("非法表达式!");
                        return;
                }
            }
        }
    }
    while (oprtStack->top != oprtStack->base) {
        b = pop(oprnStack);
        a = pop(oprnStack);
        theta = pop(oprtStack);
        result = operate(a, theta, b);
        push(oprnStack, result);
        printf("--%g%c%g=%g--\n", a, theta, b, result);
    }
    printf("最终结果: %g\n", result);
}

/* 单次运算 */
double operate(double a, int oprt, double b) {
    double power(double, int);
    double result = 0;
    switch(oprt) {
        case '+': result = (a + b); break;
        case '-': result = (a - b); break;
        case '*': result = (a * b); break;
        case '/': result = (a / b); break;
        case '^': result = power(a, b); break;
        default:
            printf("非法运算符!\n");
            exit(ERROR);
            break;
    }
    return result;
}

/* 幂运算 */
double power(double x, int n) {
    if (n == 0)
        return 1;
    if (n == 1)
        return x;
    if (n % 2 == 1 && n > 1)
        return power(x * x, n / 2) * x;
    else
        return power(x * x, n / 2);
}

/* 栈操作 */
Stack *initStack() {
    Stack *stack;
    stack = (Stack*)malloc(sizeof(Stack));
    stack->base = (double*)malloc(STACK_INIT_SIZE * sizeof(double));
    if (!stack->base) exit(OVERFLOW);
    stack->top = stack->base;
    stack->size = STACK_INIT_SIZE;
    return stack;
}

double getTop(Stack *stack) {
    if (stack->top == stack->base) exit(ERROR);
    return *(stack->top - 1);
}

void push(Stack *stack, double element) {
    if (stack->top - stack->base >= stack->size) {
        stack->base = (double*)realloc(stack->base, (stack->size + STACK_INCREMENT) * sizeof(double));
        if (!stack->base) exit(OVERFLOW);
        stack->top = stack->base + stack->size;
        stack->size += STACK_INCREMENT;
    }
    *stack->top++ = element;
}

double pop(Stack *stack) {
    if (stack->top == stack->base) exit(ERROR);
    return *--stack->top;
}
