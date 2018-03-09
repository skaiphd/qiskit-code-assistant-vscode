grammar Qasm;

startProgram
    : mainProgram EOF
    ;

mainProgram
    : ibmDefinition
    | ibmDefinition program
    | library
    | // Epsilon
    ;

ibmDefinition
    : IbmQasm Real Semi include
    | IbmQasm Real Semi
    ;

include
    : Include Qelib Semi
    ;

library
    : declaration
    | library declaration
    ;

program
    : statement
    | program statement
    ;

statement
    : declaration
    | qoperation
    ;

declaration
    : qregDeclaration
    | cregDeclaration
    | gateDeclaration
    ;

qoperation
    : unitaryOperation Semi
    | opaque Semi
    | measure Semi
    | barrier Semi
    | resetOperation Semi
    ;

unitaryOperation
    : U LeftParen expList RightParen primary 
    | Cx primary Comma primary
    | Id primaryList
    | Id LeftParen RightParen primaryList
    | Id LeftParen expList RightParen primaryList
    ;

opaque
    : Opaque Id gateScope bitList
    | Opaque Id gateScope LeftParen RightParen bitList
    | Opaque Id gateScope LeftParen gateIdList RightParen bitList
    ;

measure
    : Measure primary Assign primary
    ;

barrier
    : Barrier primaryList
    ;

resetOperation
    : Reset primary
    ;

primaryList
    : primary
    | primaryList Comma primary
    ;

primary 
    : Id
    | indexedId
    ;

indexedId
    : Id LeftBrace Int RightBrace
    ;

qregDeclaration
    : Qreg Id LeftBrace Int RightBrace Semi
    ;

cregDeclaration
    : Creg Id LeftBrace Int RightBrace Semi
    ;

gateDeclaration
    : Gate Id gateScope bitList gateBody
    | Gate Id gateScope LeftParen RightParen bitList gateBody
    | Gate Id gateScope LeftParen gateIdList RightParen bitList gateBody
    ;

gateScope
    : // Epsilon
    ; 

bitList 
    : bit
    | bitList Comma bit
    ;

bit
    : Id
    ;

gateBody
    : LeftCurlyBrace gateOpList RightCurlyBrace
    ;

gateOpList
    : // Epsilon
    | gateOp
    | gateOpList gateOp
    ;

gateOp
    : U LeftParen expList RightParen Id Semi
    | Cx Id Comma Id Semi
    | Id idList Semi
    | Id LeftParen RightParen idList Semi
    | Id LeftParen expList RightParen idList Semi
    | Barrier idList Semi
    ;

gateIdList
    : gate
    | gateIdList Comma gate
    ;

gate
    : Id
    ;

expList
    : expression
    | expList Comma expression
    ;

expression 
    : multiplicativeExpression
    | expression Pow multiplicativeExpression
    ;

multiplicativeExpression
    : additiveExpression
    | multiplicativeExpression Mult multiplicativeExpression
    | multiplicativeExpression Div multiplicativeExpression
    ;

additiveExpression
    : prefixExpression
    | additiveExpression Sum additiveExpression
    | additiveExpression Subs additiveExpression
    ;

prefixExpression
    : unary
    | Sum prefixExpression
    | Subs prefixExpression
    ;

unary  
    : Int
    | Real
    | Pi
    | Id  // variable ref
    | LeftParen expression RightParen
    | Id LeftParen expression RightParen  // function ref
    ;

idList 
    : Id
    | idList Comma Id
    ;

// terminals

Comment: '//' ~[\r\n]* -> skip;
WhiteSpace: [ \t\n\r] -> skip;

Real: [0-9]+'.'[0-9]+;
Int: [0-9]+;
IbmQasm: 'OPENQASM' | 'IBMQASM';
Include: 'include';
Qelib: 'QELIB.INC';
Qreg: 'qreg';
Creg: 'creg';
U: 'U';
Cx: 'CX';
Measure: 'measure';
Barrier: 'barrier';
Reset: 'reset';
Opaque: 'opaque';
Assign: '->';
Semi: ';';
Comma: ',';
LeftCurlyBrace: '{';
RightCurlyBrace: '}';
LeftBrace: '[';
RightBrace: ']';
LeftParen: '(';
RightParen: ')';
Pow: '^';
Mult: '*';
Div: '/';
Sum: '+';
Subs: '-';
Pi: 'pi';
Gate: 'gate';
Id: [a-z][a-zA-Z0-9]*;