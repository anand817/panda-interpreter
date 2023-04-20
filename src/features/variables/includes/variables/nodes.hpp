#ifndef VARIABLE_NODES_H
#define VARIABLE_NODES_H

#include <base/nodes.hpp>
#include <context/object.hpp>
#include <expressions/nodes.hpp>

class VariableDeclarationNode : public DeclarationNode
{
public:
    VariableDeclarationNode(const TypeNode &type, const IdentifierNode &identifier);

    virtual std::vector<std::string> generateCode();
    virtual bool analyze();
    virtual void run();
};

class VariableDefinitionNode : public VariableDeclarationNode
{
private:
    ExpressionNode *expressionNode; // needed pointer for polymorphism

public:
    VariableDefinitionNode(const TypeNode &type, const IdentifierNode &identifiery, ExpressionNode *const &expressionNode);

    virtual std::vector<std::string> generateCode();
    virtual bool analyze();
    virtual void run();

    ~VariableDefinitionNode();
};

#endif // VARIABLE_NODES_H