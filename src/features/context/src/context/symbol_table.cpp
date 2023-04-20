#include <context/symbol_table.hpp>

// SymbolInfo

SymbolInfo::SymbolInfo(const std::string &dataType) : dataType(dataType) {}
SymbolInfo::SymbolInfo(std::string &&dataType) : dataType(std::move(dataType)) {}

// VariableInfo

VariableInfo::VariableInfo(const std::string &dataType, const valueType &data) : SymbolInfo(dataType), valueContainer(data) {}
VariableInfo::VariableInfo(const std::string &dataType, valueType &&data) : SymbolInfo(dataType), valueContainer(std::move(data)) {}

VariableInfo::VariableInfo(VariableInfo &&other) : SymbolInfo(std::move(other.dataType)), valueContainer(std::move(other.valueContainer)) {}
VariableInfo::VariableInfo(const VariableInfo &other) : SymbolInfo(other.dataType), valueContainer(other.valueContainer) {}

VariableInfo &VariableInfo::operator=(VariableInfo &&other)
{
    if (this != &other)
    {
        dataType = std::move(other.dataType);
        valueContainer = std::move(other.valueContainer);
    }

    return *this;
}

VariableInfo &VariableInfo::operator=(const VariableInfo &other)
{
    if (this != &other)
    {
        dataType = other.dataType;
        valueContainer = other.valueContainer;
    }

    return *this;
}

std::string VariableInfo::getType()
{
    return dataType;
}

std::unique_ptr<SymbolInfo> VariableInfo::clone()
{
    return std::make_unique<VariableInfo>(*this);
}

// FunctionInfo

FunctionInfo::FunctionInfo(std::string dataType, std::vector<std::string> parameterList) : SymbolInfo(dataType), parameters(parameterList) {}

FunctionInfo::FunctionInfo(FunctionInfo &&other) : SymbolInfo(std::move(other.dataType)), parameters(std::move(other.parameters)) {}

FunctionInfo::FunctionInfo(const FunctionInfo &other) : SymbolInfo(other.dataType), parameters(other.parameters) {}

FunctionInfo &FunctionInfo::operator=(FunctionInfo &&other)
{
    if (this != &other)
    {
        dataType = std::move(other.dataType);
        parameters = std::move(other.parameters);
    }

    return *this;
}

FunctionInfo &FunctionInfo::operator=(const FunctionInfo &other)
{
    if (this != &other)
    {
        dataType = other.dataType;
        parameters = other.parameters;
    }

    return *this;
}

std::string FunctionInfo::getType()
{
    return dataType;
}

std::unique_ptr<SymbolInfo> FunctionInfo::clone()
{
    return std::make_unique<FunctionInfo>(*this);
}