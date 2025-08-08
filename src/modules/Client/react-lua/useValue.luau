local require = require(script.Parent.loader).load(script)

local React = require("react")

return function(valueObject)
	value, updateValue = React.useState(valueObject.Value)

	valueObject.Changed:Connect(function(newValue)
		updateValue(value)
	end)

	return value
end
